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
import java.io.FileOutputStream
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
            // Process config to inject local TUN fd
            // The config from Flutter contains fd as a placeholder
            // We need to replace it with the actual fd number from local tunPfd
            val processedConfig = processConfigWithTunFd(configJson, tunPfd)

            // Save config to file for leaf to read
            val configFile = File(context.filesDir, CONFIG_FILE_NAME)
            FileOutputStream(configFile).use { it.write(processedConfig.toByteArray()) }

            // Cache config in preferences for recovery
            LeafPreferences.configJson = processedConfig

            // Load libleaf.so if not already loaded
            try {
                System.loadLibrary("leaf")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "Failed to load libleaf.so", e)
                notifyError("Failed to load leaf library: ${e.message}")
                return false
            }

            // Start leaf via LeafBridge JNI
            val rtId = LeafBridge.leafRunWithOptions(
                rtId = 0, // 0 = create new runtime
                configPath = configFile.absolutePath,
                autoReload = true,
                multiThread = true,
                autoThreads = true,
                threads = 0, // auto threads
                stackSize = 0 // default stack size
            )

            if (rtId < 0) {
                Log.e(TAG, "startLeaf: leafRunWithOptions returned $rtId")
                notifyError("Failed to start leaf: return code $rtId")
                return false
            }

            leafRtId = rtId
            isRunning = true
            LeafPreferences.shouldRun = true
            LeafPreferences.lastStartTime = System.currentTimeMillis()

            // Enable socket protection
            try {
                LeafBridge.enableProtection()
            } catch (e: Exception) {
                Log.w(TAG, "enableProtection failed", e)
            }

            notifyStatusChanged()
            GlobalState.log("Leaf started successfully with rtId=$rtId (TUN fd=${tunPfd.fd})")
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
    private fun processConfigWithTunFd(configJson: String, tunPfd: android.os.ParcelFileDescriptor): String {
        return try {
            val json = JsonParser.parseString(configJson) as JsonObject

            // Find inbounds array and update TUN fd
            if (json.has("inbounds")) {
                val inbounds = json.getAsJsonArray("inbounds")
                for (i in 0 until inbounds.size()) {
                    val inbound = inbounds.get(i) as JsonObject
                    if (inbound.has("protocol") && inbound.get("protocol").asString == "tun") {
                        // Replace fd with local tunPfd fd
                        inbound.addProperty("fd", tunPfd.fd)
                        Log.d(TAG, "Injected TUN fd=${tunPfd.fd} into config")
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
    @Synchronized
    fun stopLeaf(): Boolean {
        if (!isRunning) {
            return true
        }

        return try {
            if (leafRtId >= 0) {
                LeafBridge.leafShutdown(leafRtId)
            }
            leafRtId = -1
            isRunning = false
            LeafPreferences.shouldRun = false
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

            val processedConfig = processConfigWithTunFd(configJson, tunPfd)

            // Save new config to file
            val configFile = File(context.filesDir, CONFIG_FILE_NAME)
            FileOutputStream(configFile).use { it.write(processedConfig.toByteArray()) }

            // Cache config in preferences
            LeafPreferences.configJson = processedConfig

            // Reload via JNI
            val result = LeafBridge.leafReload(leafRtId)
            if (result < 0) {
                Log.e(TAG, "reloadLeaf: leafReload returned $result")
                notifyError("Failed to reload leaf: return code $result")
                return false
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
     * Note: This requires the config to have the node available.
     * For now, we just update the preference - actual node switching
     * would need to be implemented in the leaf config generation.
     */
    fun selectNode(nodeTag: String): Boolean {
        selectedNodeTag = nodeTag
        LeafPreferences.selectedNodeTag = nodeTag
        notifyStatusChanged()
        return true
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
        private const val CONFIG_FILE_NAME = "leaf_config.yaml"

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
