package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
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
    private fun handleStopService(result: IResultInterface) {
        launch {
            runLock.withLock {
                delegate?.useService { service ->
                    service.stop()
                    delegate?.unbind()
                }
                State.runTime = 0
                result.onResult(0)
            }
        }
    }

    private fun handleServiceDisconnected(message: String) {
        GlobalState.log("Background service disconnected: $message")
        intent = null
        delegate = null
    }

    private fun handleStartService(runTime: Long, result: IResultInterface) {
        launch {
            runLock.withLock {
                val nextIntent = when (State.options?.enable == true) {
                    true -> VpnService::class.intent
                    false -> CommonService::class.intent
                }
                if (intent != nextIntent) {
                    delegate?.unbind()
                    delegate = ServiceDelegate(nextIntent, ::handleServiceDisconnected) { binder ->
                        when (binder) {
                            is VpnService.LocalBinder -> binder.getService()
                            is CommonService.LocalBinder -> binder.getService()
                            else -> throw IllegalArgumentException("Invalid binder type")
                        }
                    }
                    intent = nextIntent
                    delegate?.bind()
                }
                delegate?.useService { service ->
                    service.start()
                }
                State.runTime = when (runTime != 0L) {
                    true -> runTime
                    false -> System.currentTimeMillis()
                }
                result.onResult(State.runTime)
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
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onDestroy() {
        GlobalState.log("Remote service destroy")
        super.onDestroy()
    }
}