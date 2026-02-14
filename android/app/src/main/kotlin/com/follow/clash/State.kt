package com.follow.clash

import android.content.Intent
import android.net.VpnService
import com.follow.clash.common.GlobalState
import com.follow.clash.common.LeafPreferences
import com.follow.clash.common.ServiceDelegate
import com.follow.clash.common.intent
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.CommonService
import com.follow.clash.service.IBaseService
import com.follow.clash.service.models.NotificationParams
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

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

    // --- Service delegate (absorbed from RemoteService) ---

    private var serviceDelegate: ServiceDelegate<IBaseService>? = null
    private var serviceIntent: Intent? = null

    /** Set by ServicePlugin to forward disconnect events to Flutter. */
    var onServiceDisconnected: ((String) -> Unit)? = null

    private fun buildDelegate(intent: Intent): ServiceDelegate<IBaseService> {
        return ServiceDelegate(intent, ::handleServiceDisconnected) { binder ->
            when (binder) {
                is com.follow.clash.service.VpnService.LocalBinder -> binder.getService()
                is CommonService.LocalBinder -> binder.getService()
                else -> throw IllegalArgumentException("Invalid binder type")
            }
        }
    }

    private fun needsDelegateRebuild(intent: Intent): Boolean {
        return serviceDelegate == null || serviceIntent?.component != intent.component
    }

    private fun vpnStartedSuccessfully(): Boolean {
        return com.follow.clash.service.State.tunPfd != null &&
                com.follow.clash.service.State.vpnService != null
    }

    private fun resetVpnState() {
        com.follow.clash.service.State.vpnService = null
        try {
            com.follow.clash.service.State.tunPfd?.close()
        } catch (_: Exception) {
        }
        com.follow.clash.service.State.tunPfd = null
    }

    private fun handleServiceDisconnected(message: String) {
        GlobalState.log("Background service disconnected: $message")
        serviceIntent = null
        serviceDelegate = null
        runTime = 0
        resetVpnState()
        onServiceDisconnected?.invoke(message)
    }

    fun shutdown() {
        serviceDelegate?.unbind()
        serviceDelegate = null
        serviceIntent = null
    }

    // --- End service delegate ---

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
        if (needsDelegateRebuild(nextIntent)) {
            serviceDelegate?.unbind()
            serviceDelegate = buildDelegate(nextIntent)
            serviceIntent = nextIntent
        }
        com.follow.clash.service.State.options = options
        serviceDelegate?.bind()
        val started = serviceDelegate?.useService { service ->
            service.start()
            when (options.enable) {
                true -> vpnStartedSuccessfully()
                false -> true
            }
        }?.getOrElse {
            GlobalState.log("startService failed: ${it.message}")
            false
        } ?: false
        if (!started) {
            runCatching {
                serviceDelegate?.useService { it.stop() }
            }
            serviceDelegate?.unbind()
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

                    runCatching {
                        serviceDelegate?.useService { it.stop() }
                    }.onFailure {
                        GlobalState.log("handleStopService failed: ${it.message}")
                    }
                    serviceDelegate?.unbind()
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
