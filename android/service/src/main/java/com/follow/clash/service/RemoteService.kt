package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.ParcelFileDescriptor
import com.follow.clash.common.GlobalState
import com.follow.clash.common.ServiceDelegate
import com.follow.clash.common.intent
import com.follow.clash.service.State.delegate
import com.follow.clash.service.State.intent
import com.follow.clash.service.State.runLock
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.withLock

class RemoteService : Service(),
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private fun resetVpnState() {
        try {
            State.tunPfd?.close()
        } catch (_: Exception) {
        }
        State.tunPfd = null
        State.tunFd = null
        State.vpnService = null
    }

    private fun buildDelegate(serviceIntent: Intent): ServiceDelegate<IBaseService> {
        return ServiceDelegate(serviceIntent, ::handleServiceDisconnected) { binder ->
            when (binder) {
                is VpnService.LocalBinder -> binder.getService()
                is CommonService.LocalBinder -> binder.getService()
                else -> throw IllegalArgumentException("Invalid binder type")
            }
        }
    }

    private fun needsDelegateRebuild(serviceIntent: Intent): Boolean {
        return delegate == null || intent?.component != serviceIntent.component
    }

    private fun vpnStartedSuccessfully(): Boolean {
        return State.tunPfd != null && State.tunFd != null && State.vpnService != null
    }

    private fun handleStopService(result: IResultInterface) {
        launch {
            runLock.withLock {
                runCatching {
                    delegate?.useService { service ->
                        service.stop()
                    }
                }.onFailure {
                    GlobalState.log("handleStopService failed: ${it.message}")
                }
                delegate?.unbind()
                resetVpnState()
                State.runTime = 0
                result.onResult(0)
            }
        }
    }

    private fun handleServiceDisconnected(message: String) {
        GlobalState.log("Background service disconnected: $message")
        intent = null
        delegate = null
        State.runTime = 0
        resetVpnState()
    }

    private fun handleStartService(runTime: Long, result: IResultInterface) {
        launch {
            runLock.withLock {
                try {
                    val options = State.options
                    val nextIntent = when (State.options?.enable == true) {
                        true -> VpnService::class.intent
                        false -> CommonService::class.intent
                    }
                    if (needsDelegateRebuild(nextIntent)) {
                        delegate?.unbind()
                        delegate = buildDelegate(nextIntent)
                        intent = nextIntent
                    }
                    // stop() may unbind the delegate; always bind before useService.
                    delegate?.bind()
                    val started = delegate?.useService { service ->
                        service.start()
                        when (options?.enable == true) {
                            true -> vpnStartedSuccessfully()
                            false -> true
                        }
                    }?.getOrElse {
                        GlobalState.log("startService RPC failed: ${it.message}")
                        false
                    } ?: false
                    if (!started) {
                        runCatching {
                            delegate?.useService { service ->
                                service.stop()
                            }
                        }
                        delegate?.unbind()
                        resetVpnState()
                        State.runTime = 0
                        result.onResult(0)
                        return@withLock
                    }
                    State.runTime = when (runTime != 0L) {
                        true -> runTime
                        false -> System.currentTimeMillis()
                    }
                    result.onResult(State.runTime)
                } catch (e: Exception) {
                    GlobalState.log("handleStartService failed: ${e.message}")
                    resetVpnState()
                    result.onResult(0)
                }
            }
        }
    }

    private val binder = object : IRemoteInterface.Stub() {
        override fun invokeAction(data: String, callback: ICallbackInterface) {
            // No-op: Go core RPC removed; actions are handled by Dart via MethodChannel.
            launch {
                runCatching {
                    callback.onResult(
                        ByteArray(0),
                        true,
                        object : IAckInterface.Stub() {
                            override fun onAck() {}
                        },
                    )
                }
            }
        }

        override fun quickSetup(
            initParamsString: String,
            setupParamsString: String,
            callback: ICallbackInterface,
            onStarted: IVoidInterface
        ) {
            // No-op: Go core RPC removed; setup is handled by Dart via MethodChannel.
            onStarted()
            launch {
                runCatching {
                    callback.onResult(
                        ByteArray(0),
                        true,
                        object : IAckInterface.Stub() {
                            override fun onAck() {}
                        },
                    )
                }
            }
        }

        override fun updateNotificationParams(params: NotificationParams?) {
            State.notificationParamsFlow.tryEmit(params)
        }


        override fun startService(
            options: VpnOptions,
            runtime: Long,
            result: IResultInterface,
        ) {
            GlobalState.log("remote startService")
            State.options = options
            handleStartService(runtime, result)
        }

        override fun stopService(result: IResultInterface) {
            handleStopService(result)
        }

        override fun setEventListener(eventListener: IEventInterface?) {
            GlobalState.log("RemoveEventListener ${eventListener == null}")
            // No-op: Go core event listener removed; events are handled by Dart via MethodChannel.
        }

        override fun getRunTime(): Long {
            return State.runTime
        }

        override fun getTunFd(): ParcelFileDescriptor? {
            return try {
                State.tunPfd?.dup()
            } catch (e: Exception) {
                GlobalState.log("getTunFd failed: $e")
                null
            }
        }

        override fun protectSocket(fd: ParcelFileDescriptor?): Boolean {
            if (fd == null) return false
            return try {
                val result = State.vpnService?.protect(fd.fd) ?: false
                fd.close()
                result
            } catch (e: Exception) {
                GlobalState.log("protectSocket failed: $e")
                try { fd.close() } catch (_: Exception) {}
                false
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onDestroy() {
        GlobalState.log("Remote service destroy")
        super.onDestroy()
    }
}
