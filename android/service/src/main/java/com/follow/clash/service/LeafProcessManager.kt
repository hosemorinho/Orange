package com.follow.clash.service

import android.content.Context
import android.util.Log
import com.follow.clash.common.GlobalState
import com.follow.clash.common.LeafBridge
import com.follow.clash.common.LeafPreferences
import com.follow.clash.core.ICoreServiceCallback
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import java.io.File
import java.nio.charset.StandardCharsets
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Manages the Leaf proxy process in the :core service.
 * Handles lifecycle, config loading, node selection, and socket protection.
 *
 * In dual-process mode:
 * - Leaf runs in :core process (same as VpnService)
 * - TUN fd is obtained from local State.tunPfd
 * - No cross-process fd passing needed
 */
class LeafProcessManager(private val context: Context) : CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private val TAG = "LeafProcessManager"

    // Current leaf runtime ID (from JNI)
    @Volatile private var leafRtId: Int = -1
    @Volatile private var leafThread: Thread? = null
    @Volatile private var lastRunResult: Int = Int.MIN_VALUE

    // Current state
    @Volatile private var isRunning: Boolean = false
    @Volatile private var currentMode: String = "rule"
    @Volatile private var selectedNodeTag: String = ""

    // Registered IPC callbacks from UI process.
    private val callbacks = CopyOnWriteArrayList<ICoreServiceCallback>()

    /**
     * Set the callback for status changes.
     */
    fun registerCallback(cb: ICoreServiceCallback?) {
        if (cb == null) return
        val incomingBinder = cb.asBinder()
        val exists = callbacks.any { it.asBinder() == incomingBinder }
        if (!exists) {
            callbacks.add(cb)
        }
    }

    fun unregisterCallback(cb: ICoreServiceCallback?) {
        if (cb == null) return
        val binder = cb.asBinder()
        callbacks.removeAll { it.asBinder() == binder }
    }

    /**
     * Check if TUN is ready in :core process.
     */
    fun isTunReady(): Boolean {
        return State.tunPfd != null
    }

    /**
     * Ensure JNI symbols are available before any LeafBridge native call.
     */
    private fun ensureLeafLibraryLoaded(): Boolean {
        return try {
            System.loadLibrary("leaf")
            true
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "Failed to load libleaf.so", e)
            notifyError("Failed to load leaf library: ${e.message}")
            false
        }
    }

    /**
     * Configure leaf runtime asset location in :core process.
     * Without this, leaf defaults to /system/bin and can't find geo.mmdb.
     */
    private fun configureLeafAssetLocation(): Boolean {
        return try {
            val assetLocation = context.filesDir.absolutePath
            LeafBridge.leafSetEnv("ASSET_LOCATION", assetLocation)
            Log.i(TAG, "Configured ASSET_LOCATION=$assetLocation")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to configure ASSET_LOCATION", e)
            notifyError("Failed to configure ASSET_LOCATION: ${e.message}")
            false
        }
    }

    /**
     * Start leaf with the given config JSON.
     * In dual-process mode, uses local tunPfd from State.
     */
    @Synchronized
    fun startLeaf(configJson: String): Boolean {
        if (isRunning) {
            Log.w(TAG, "startLeaf: already running")
            return true
        }

        // Check if TUN is ready
        val tunPfd = State.tunPfd
        if (tunPfd == null) {
            Log.e(TAG, "startLeaf: TUN not ready (tunPfd is null)")
            notifyError("TUN not ready, start VPN first")
            return false
        }

        return try {
            // Build a validated/cached config with the current readable fd.
            val processedConfig = processConfigWithTunFd(configJson, tunPfd.fd)

            // Cache config in preferences for recovery
            LeafPreferences.configJson = processedConfig

            if (!ensureLeafLibraryLoaded()) {
                return false
            }
            if (!configureLeafAssetLocation()) {
                return false
            }

            // Validate config string early to avoid starting VPN without a working core.
            val testResult = LeafBridge.leafTestConfigString(processedConfig)
            if (testResult != 0) {
                Log.e(TAG, "startLeaf: config validation failed, code=$testResult")
                notifyError("Invalid leaf config: code $testResult")
                return false
            }

            // Leaf owns and closes the inbound TUN fd. Pass a detached duplicate to avoid
            // fdsan aborts from closing a fd still owned by ParcelFileDescriptor.
            val ownedTunFd = getTunFd()
            if (ownedTunFd < 0) {
                Log.e(TAG, "startLeaf: failed to obtain owned TUN fd")
                notifyError("Failed to duplicate TUN fd")
                return false
            }
            val runtimeConfig = processConfigWithTunFd(processedConfig, ownedTunFd)

            // Enable socket protection BEFORE starting leaf.
            // Leaf creates outbound sockets (DNS resolvers, etc.) immediately
            // on startup. Without protection, those sockets route through the
            // VPN tunnel → back to TUN → leaf → infinite loop → network death.
            try {
                LeafBridge.enableProtection()
            } catch (e: Exception) {
                Log.w(TAG, "enableProtection failed", e)
            }

            val runtimeId = DEFAULT_RUNTIME_ID
            lastRunResult = Int.MIN_VALUE

            // leafRunWithOptions is a blocking call by design. Run it in a dedicated
            // background thread so IPC start call can return immediately.
            val thread = Thread({
                val runResult = try {
                    LeafBridge.leafRunWithOptionsConfigString(
                        rtId = runtimeId,
                        config = runtimeConfig,
                        multiThread = true,
                        autoThreads = true,
                        threads = 0, // auto threads
                        stackSize = 0 // default stack size
                    )
                } catch (t: Throwable) {
                    Log.e(TAG, "leaf runtime thread crashed", t)
                    Int.MIN_VALUE
                }

                lastRunResult = runResult
                synchronized(this@LeafProcessManager) {
                    leafRtId = -1
                    isRunning = false
                    leafThread = null
                }
                if (runResult != 0) {
                    notifyError("Leaf runtime exited with code $runResult")
                }
                notifyStatusChanged()
                GlobalState.log("Leaf runtime exited with code=$runResult")
            }, "LeafRuntime-$runtimeId")

            thread.isDaemon = true
            leafThread = thread
            thread.start()

            // If runtime exits immediately, startup failed.
            Thread.sleep(200)
            if (!thread.isAlive) {
                val code = lastRunResult
                leafThread = null
                leafRtId = -1
                isRunning = false
                Log.e(TAG, "startLeaf: runtime exited during startup, code=$code")
                notifyError("Failed to start leaf: return code $code")
                return false
            }

            leafRtId = runtimeId
            isRunning = true
            LeafPreferences.shouldRun = true
            LeafPreferences.lastStartTime = System.currentTimeMillis()

            // Re-apply persisted selector choice after startup.
            val persistedNode = LeafPreferences.selectedNodeTag
            if (persistedNode.isNotEmpty()) {
                if (applyNodeSelection(runtimeId, persistedNode)) {
                    selectedNodeTag = persistedNode
                } else {
                    Log.w(TAG, "startLeaf: failed to apply persisted node=$persistedNode")
                }
            }

            notifyStatusChanged()
            GlobalState.log("Leaf started successfully with rtId=$runtimeId (owned TUN fd=$ownedTunFd)")
            true
        } catch (e: Exception) {
            Log.e(TAG, "startLeaf failed", e)
            notifyError("Failed to start leaf: ${e.message}")
            false
        }
    }

    @Synchronized
    fun startLeafFromFile(configPath: String): Boolean {
        return try {
            val config = File(configPath).readText(StandardCharsets.UTF_8)
            startLeaf(config)
        } catch (e: Exception) {
            Log.e(TAG, "startLeafFromFile failed: $configPath", e)
            notifyError("Failed to read config file: ${e.message}")
            false
        }
    }

    /**
     * Process config JSON to inject local TUN fd.
     * Replaces the fd number in config with the actual fd from local tunPfd.
     */
    private fun processConfigWithTunFd(configJson: String, tunFd: Int): String {
        return try {
            val json = JsonParser.parseString(configJson) as JsonObject

            // Find inbounds array and update TUN fd inside settings
            if (json.has("inbounds")) {
                val inbounds = json.getAsJsonArray("inbounds")
                for (i in 0 until inbounds.size()) {
                    val inbound = inbounds.get(i) as JsonObject
                    if (inbound.has("protocol") && inbound.get("protocol").asString == "tun") {
                        // Leaf reads fd from settings.fd, not from the inbound top level
                        val settings = if (inbound.has("settings")) {
                            inbound.getAsJsonObject("settings")
                        } else {
                            JsonObject().also { inbound.add("settings", it) }
                        }
                        settings.addProperty("fd", tunFd)
                        Log.d(TAG, "Injected TUN fd=$tunFd into config settings")
                    }
                }
            }

            json.toString()
        } catch (e: Exception) {
            Log.w(TAG, "Failed to process config with TUN fd, using original", e)
            configJson
        }
    }

    /**
     * Stop the running leaf instance.
     */
    fun stopLeaf(): Boolean {
        val rtId: Int
        val thread: Thread?
        synchronized(this) {
            if (!isRunning) {
                return true
            }
            rtId = leafRtId
            thread = leafThread
        }

        return try {
            if (rtId >= 0) {
                LeafBridge.leafShutdown(rtId)
            }
            if (thread != null && thread.isAlive && Thread.currentThread() !== thread) {
                thread.join(1_500)
            }
            synchronized(this) {
                leafThread = null
                leafRtId = -1
                isRunning = false
                LeafPreferences.shouldRun = false
            }
            notifyStatusChanged()
            GlobalState.log("Leaf stopped successfully")
            true
        } catch (e: Exception) {
            Log.e(TAG, "stopLeaf failed", e)
            notifyError("Failed to stop leaf: ${e.message}")
            false
        }
    }

    /**
     * Reload leaf with new config.
     */
    @Synchronized
    fun reloadLeaf(configJson: String): Boolean {
        if (!isRunning) {
            return startLeaf(configJson)
        }

        return try {
            val tunPfd = State.tunPfd
            if (tunPfd == null) {
                Log.e(TAG, "reloadLeaf: TUN not ready (tunPfd is null)")
                notifyError("TUN not ready, cannot reload")
                return false
            }

            val processedConfig = processConfigWithTunFd(configJson, tunPfd.fd)

            // Cache config in preferences
            LeafPreferences.configJson = processedConfig

            if (!ensureLeafLibraryLoaded()) {
                return false
            }
            if (!configureLeafAssetLocation()) {
                return false
            }

            val ownedTunFd = getTunFd()
            if (ownedTunFd < 0) {
                Log.e(TAG, "reloadLeaf: failed to obtain owned TUN fd")
                notifyError("Failed to duplicate TUN fd for reload")
                return false
            }
            val runtimeConfig = processConfigWithTunFd(processedConfig, ownedTunFd)

            // Reload via JNI
            val result = LeafBridge.leafReloadWithConfigString(leafRtId, runtimeConfig)
            if (result != 0) {
                Log.e(TAG, "reloadLeaf: leafReload returned $result")
                notifyError("Failed to reload leaf: return code $result")
                return false
            }

            if (selectedNodeTag.isNotEmpty()) {
                if (!applyNodeSelection(leafRtId, selectedNodeTag)) {
                    Log.w(TAG, "reloadLeaf: failed to re-apply selected node=$selectedNodeTag")
                }
            }

            notifyStatusChanged()
            GlobalState.log("Leaf reloaded successfully")
            true
        } catch (e: Exception) {
            Log.e(TAG, "reloadLeaf failed", e)
            notifyError("Failed to reload leaf: ${e.message}")
            false
        }
    }

    @Synchronized
    fun reloadLeafFromFile(configPath: String): Boolean {
        return try {
            val config = File(configPath).readText(StandardCharsets.UTF_8)
            reloadLeaf(config)
        } catch (e: Exception) {
            Log.e(TAG, "reloadLeafFromFile failed: $configPath", e)
            notifyError("Failed to read config file: ${e.message}")
            false
        }
    }

    /**
     * Get current status.
     */
    fun getStatus(): Map<String, Any> {
        return mapOf(
            "isRunning" to isRunning,
            "mode" to currentMode,
            "selectedNode" to selectedNodeTag,
            "leafRtId" to leafRtId
        )
    }

    /**
     * Get the currently selected node tag.
     */
    fun getSelectedNode(): String {
        return selectedNodeTag
    }

    /**
     * Select a new node by tag.
     * Applies selection to the running leaf selector outbound when available,
     * and always persists the requested tag for next startup/recovery.
     */
    fun selectNode(nodeTag: String): Boolean {
        if (nodeTag.isBlank()) {
            return false
        }
        if (isRunning && leafRtId >= 0) {
            if (!applyNodeSelection(leafRtId, nodeTag)) {
                notifyError("Failed to select node: $nodeTag")
                return false
            }
        }
        selectedNodeTag = nodeTag
        LeafPreferences.selectedNodeTag = nodeTag
        notifyStatusChanged()
        return true
    }

    private fun applyNodeSelection(rtId: Int, nodeTag: String): Boolean {
        if (!ensureLeafLibraryLoaded()) {
            return false
        }
        return try {
            val result = LeafBridge.leafSetOutboundSelected(
                rtId,
                SELECTOR_OUTBOUND_TAG,
                nodeTag
            )
            if (result != 0) {
                Log.e(TAG, "applyNodeSelection failed, code=$result, node=$nodeTag")
                return false
            }
            try {
                LeafBridge.leafCloseConnections(rtId)
            } catch (t: Throwable) {
                Log.w(TAG, "leafCloseConnections failed after node switch", t)
            }
            Log.i(TAG, "Applied node selection: $nodeTag")
            true
        } catch (t: Throwable) {
            Log.e(TAG, "applyNodeSelection crashed for node=$nodeTag", t)
            false
        }
    }

    /**
     * Protect a socket from VPN routing.
     * Called from VpnService via IPC.
     */
    fun protectSocket(fd: Int): Boolean {
        return try {
            LeafBridge.protectSocket(fd)
        } catch (e: Exception) {
            Log.e(TAG, "protectSocket failed for fd=$fd", e)
            false
        }
    }

    /**
     * Get the TUN file descriptor.
     */
    fun getTunFd(): Int {
        val pfd = State.tunPfd
        if (pfd == null) {
            return -1
        }
        return try {
            val dup = pfd.dup()
            dup.detachFd()
        } catch (e: Exception) {
            Log.e(TAG, "getTunFd failed", e)
            -1
        }
    }

    /**
     * Set the current mode.
     */
    fun setMode(mode: String) {
        currentMode = mode
        LeafPreferences.mode = mode
        notifyStatusChanged()
    }

    /**
     * Check and recover if shouldRun is true.
     * Called on service start.
     */
    fun checkRecovery(): Boolean {
        if (!LeafPreferences.shouldRun) {
            return false
        }

        val configJson = LeafPreferences.configJson
        if (configJson.isEmpty()) {
            Log.w(TAG, "checkRecovery: no cached config found")
            return false
        }

        Log.i(TAG, "checkRecovery: recovering with cached config")
        return startLeaf(configJson)
    }

    /**
     * Shutdown the manager completely.
     */
    fun shutdown() {
        stopLeaf()
    }

    private fun notifyStatusChanged() {
        callbacks.forEach { cb ->
            try {
                cb.onStatusChanged(isRunning, currentMode, selectedNodeTag)
            } catch (e: Exception) {
                Log.w(TAG, "notifyStatusChanged failed", e)
                callbacks.remove(cb)
            }
        }
    }

    private fun notifyError(message: String) {
        callbacks.forEach { cb ->
            try {
                cb.onError(message)
            } catch (e: Exception) {
                Log.w(TAG, "notifyError failed", e)
                callbacks.remove(cb)
            }
        }
    }

    companion object {
        private const val DEFAULT_RUNTIME_ID = 0
        private const val SELECTOR_OUTBOUND_TAG = "proxy"

        @Volatile
        private var instance: LeafProcessManager? = null

        fun getInstance(context: Context): LeafProcessManager {
            return instance ?: synchronized(this) {
                instance ?: LeafProcessManager(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }
}
