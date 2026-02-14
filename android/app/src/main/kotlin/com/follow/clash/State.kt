package com.follow.clash

import android.content.Intent
import android.content.ComponentName
import android.content.Context
import android.content.ServiceConnection
import android.net.VpnService
import android.os.Build
import android.os.IBinder
import com.follow.clash.common.GlobalState
import com.follow.clash.common.LeafPreferences
import com.follow.clash.common.intent
import com.follow.clash.core.ICoreService
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.CommonService
import com.follow.clash.service.models.NotificationParams
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.resume

enum class RunState {
    START, PENDING, STOP
}

object State {

    val runLock = Mutex()

    var runTime: Long = 0

    var sharedState: SharedState = SharedState()

    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)

    var flutterEngine: FlutterEngine? = null

    val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>()

    val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>()

    /** Deferred that completes when VPN start finishes (true=success, false=failed/denied). */
    var startResultDeferred: CompletableDeferred<Boolean>? = null

    private var serviceIntent: Intent? = null

    /** Set by ServicePlugin to forward disconnect events to Flutter. */
    var onServiceDisconnected: ((String) -> Unit)? = null

    private data class BoundCoreService(
        val service: ICoreService,
        val connection: ServiceConnection
    )

    private fun resetVpnState() {
        com.follow.clash.service.State.vpnService = null
        try {
            com.follow.clash.service.State.tunPfd?.close()
        } catch (_: Exception) {
        }
        com.follow.clash.service.State.tunPfd = null
    }

    private suspend fun bindCoreService(timeoutMs: Long = 5_000L): BoundCoreService? {
        return withContext(Dispatchers.Main) {
            withTimeoutOrNull(timeoutMs) {
                suspendCancellableCoroutine { continuation ->
                    val app = GlobalState.application
                    lateinit var connection: ServiceConnection
                    connection = object : ServiceConnection {
                        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                            if (continuation.isCompleted) return
                            val core = ICoreService.Stub.asInterface(service)
                            continuation.resume(
                                if (core != null) BoundCoreService(core, connection) else null
                            )
                        }

                        override fun onServiceDisconnected(name: ComponentName?) {
                            if (!continuation.isCompleted) {
                                continuation.resume(null)
                            }
                        }

                        override fun onBindingDied(name: ComponentName?) {
                            if (!continuation.isCompleted) {
                                continuation.resume(null)
                            }
                        }

                        override fun onNullBinding(name: ComponentName?) {
                            if (!continuation.isCompleted) {
                                continuation.resume(null)
                            }
                        }
                    }

                    val bound = runCatching {
                        app.bindService(
                            Intent(app, com.follow.clash.service.CoreServiceHost::class.java),
                            connection,
                            Context.BIND_AUTO_CREATE
                        )
                    }.getOrDefault(false)

                    if (!bound) {
                        continuation.resume(null)
                        return@suspendCancellableCoroutine
                    }

                    continuation.invokeOnCancellation {
                        runCatching {
                            app.unbindService(connection)
                        }
                    }
                }
            }
        }
    }

    private suspend fun unbindCoreService(connection: ServiceConnection) {
        withContext(Dispatchers.Main) {
            runCatching {
                GlobalState.application.unbindService(connection)
            }
        }
    }

    private suspend fun waitForVpnTunReady(timeoutMs: Long = 20_000L): Boolean {
        val boundCore = bindCoreService() ?: return false
        return try {
            val deadline = System.currentTimeMillis() + timeoutMs
            while (System.currentTimeMillis() < deadline) {
                val ready = runCatching {
                    boundCore.service.isTunReady()
                }.getOrDefault(false)
                if (ready) {
                    return true
                }
                delay(200L)
            }
            false
        } finally {
            unbindCoreService(boundCore.connection)
        }
    }

    fun shutdown() {
        serviceIntent = null
    }

    private fun ensureStartDeferred() {
        if (startResultDeferred == null || startResultDeferred?.isCompleted == true) {
            startResultDeferred = CompletableDeferred()
        }
    }

    suspend fun handleToggleAction() {
        var action: (suspend () -> Unit)?
        runLock.withLock {
            action = when (runStateFlow.value) {
                RunState.PENDING -> null
                RunState.START -> ::handleStopServiceAction
                RunState.STOP -> ::handleStartServiceAction
            }
        }
        action?.invoke()
    }

    suspend fun handleSyncState() {
        runLock.withLock {
            val runState = when (runTime == 0L) {
                true -> RunState.STOP
                false -> RunState.START
            }
            runStateFlow.tryEmit(runState)
        }
    }

    suspend fun handleStartServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.STOP) {
                return
            }
            tilePlugin?.handleStart()
            if (flutterEngine != null) {
                return
            }
            startServiceWithPref()
        }

    }

    suspend fun handleStopServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.START) {
                return
            }
            tilePlugin?.handleStop()
            if (flutterEngine != null) {
                return
            }
            if (GlobalState.isInitialized) {
                GlobalState.application.showToast(sharedState.stopTip)
            }
            handleStopService()
        }
    }

    fun handleStartService() {
        ensureStartDeferred()
        val appPlugin = flutterEngine?.plugin<AppPlugin>()
        if (appPlugin != null) {
            appPlugin.requestNotificationsPermission {
                startService()
            }
            return
        }
        startService()
    }

    private fun startServiceWithPref() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                if (!GlobalState.isInitialized) {
                    GlobalState.log("startServiceWithPref: application not initialized yet")
                    return@launch
                }
                sharedState = GlobalState.application.sharedState
                setupAndStart()
            }
        }
    }

    fun syncState() {
        com.follow.clash.service.State.notificationParamsFlow.tryEmit(
            NotificationParams(
                title = sharedState.currentProfileName,
                stopText = sharedState.stopText,
                onlyStatisticsProxy = sharedState.onlyStatisticsProxy
            )
        )
    }

    private fun setupAndStart() {
        syncState()
        GlobalState.application.showToast(sharedState.startTip)
        startService()
    }

    /**
     * Core start logic (absorbed from RemoteService.handleStartService).
     * Selects VpnService or CommonService, binds, starts, verifies.
     */
    private suspend fun doStartService(options: com.follow.clash.service.models.VpnOptions): Long {
        val nextIntent = when (options.enable) {
            true -> com.follow.clash.service.VpnService::class.intent
            false -> CommonService::class.intent
        }
        serviceIntent = nextIntent
        com.follow.clash.service.State.options = options
        LeafPreferences.vpnOptionsJson = Gson().toJson(options)
        val startAction = when (options.enable) {
            true -> com.follow.clash.service.VpnService.ACTION_START
            false -> CommonService.ACTION_START
        }
        val startIntent = Intent(nextIntent).apply {
            action = startAction
        }
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                GlobalState.application.startForegroundService(startIntent)
            } else {
                GlobalState.application.startService(startIntent)
            }
        }.onFailure {
            GlobalState.log("startService intent failed: ${it.message}")
            return 0L
        }
        val started = when (options.enable) {
            true -> waitForVpnTunReady()
            false -> true
        }
        if (!started) {
            GlobalState.log("startService verify failed: vpn tun not ready")
            val stopAction = when (options.enable) {
                true -> com.follow.clash.service.VpnService.ACTION_STOP
                false -> CommonService.ACTION_STOP
            }
            runCatching {
                GlobalState.application.startService(Intent(nextIntent).apply {
                    action = stopAction
                })
            }
            resetVpnState()
            return 0L
        }
        val nextRunTime = when (runTime != 0L) {
            true -> runTime
            false -> System.currentTimeMillis()
        }
        return nextRunTime
    }

    private fun startService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    startResultDeferred?.complete(false)
                    return@launch
                }
                runStateFlow.tryEmit(RunState.PENDING)
                val options = sharedState.vpnOptions
                if (options == null) {
                    GlobalState.log("startService: vpnOptions is null")
                    runStateFlow.tryEmit(RunState.STOP)
                    startResultDeferred?.complete(false)
                    return@launch
                }
                appPlugin?.let {
                    it.prepare(options.enable) {
                        try {
                            val nextRunTime = doStartService(options)
                            if (nextRunTime <= 0L) {
                                throw IllegalStateException("service start failed")
                            }
                            runTime = nextRunTime
                            runStateFlow.tryEmit(RunState.START)
                            startResultDeferred?.complete(true)
                        } catch (e: Exception) {
                            GlobalState.log("VPN service start failed: ${e.message}")
                            runStateFlow.tryEmit(RunState.STOP)
                            startResultDeferred?.complete(false)
                        }
                    }
                } ?: run {
                    val intent = VpnService.prepare(GlobalState.application)
                    if (intent != null) {
                        runStateFlow.tryEmit(RunState.STOP)
                        startResultDeferred?.complete(false)
                        return@launch
                    }
                    try {
                        val nextRunTime = doStartService(options)
                        if (nextRunTime <= 0L) {
                            throw IllegalStateException("service start failed")
                        }
                        runTime = nextRunTime
                        runStateFlow.tryEmit(RunState.START)
                        startResultDeferred?.complete(true)
                    } catch (e: Exception) {
                        GlobalState.log("VPN service start failed (no plugin): ${e.message}")
                        runStateFlow.tryEmit(RunState.STOP)
                        startResultDeferred?.complete(false)
                    }
                }
            }
        }
    }

    fun handleStopService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.START) {
                    return@launch
                }
                try {
                    runStateFlow.tryEmit(RunState.PENDING)

                    // Set shouldRun=false when user explicitly stops
                    // This prevents auto-recovery after user-initiated stop
                    LeafPreferences.shouldRun = false
                    GlobalState.log("User stopped service, shouldRun=false")

                    val stopAction = when (com.follow.clash.service.State.options?.enable == true) {
                        true -> com.follow.clash.service.VpnService.ACTION_STOP
                        false -> CommonService.ACTION_STOP
                    }
                    serviceIntent?.let { intent ->
                        runCatching {
                            GlobalState.application.startService(Intent(intent).apply {
                                action = stopAction
                            })
                        }.onFailure {
                            GlobalState.log("stopService intent failed: ${it.message}")
                        }
                    }

                    resetVpnState()
                    runTime = 0
                    runStateFlow.tryEmit(RunState.STOP)
                } finally {
                    if (runStateFlow.value == RunState.PENDING) {
                        runStateFlow.tryEmit(RunState.START)
                    }
                }
            }
        }
    }
}
