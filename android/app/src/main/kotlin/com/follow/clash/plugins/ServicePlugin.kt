package com.follow.clash.plugins

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import com.follow.clash.RunState
import com.follow.clash.State
import com.follow.clash.common.Components
import com.follow.clash.common.LeafPreferences
import com.follow.clash.common.XBoardLog
import com.follow.clash.core.ICoreService
import com.follow.clash.core.ICoreServiceCallback
import com.follow.clash.invokeMethodOnMainThread
import com.follow.clash.models.SharedState
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    private lateinit var flutterMethodChannel: MethodChannel
    private var coreService: ICoreService? = null
    private var isBound = false

    // AIDL connection to :core process
    private val coreServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            XBoardLog.i("ServicePlugin", "CoreService connected")
            coreService = ICoreService.Stub.asInterface(service)
            isBound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            XBoardLog.i("ServicePlugin", "CoreService disconnected")
            coreService = null
            isBound = false
            // Notify Flutter about disconnection
            onServiceDisconnected("CoreService disconnected")
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/service"
        )
        flutterMethodChannel.setMethodCallHandler(this)

        // Bind to CoreService in :core process
        bindCoreService(flutterPluginBinding.applicationContext)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
        unbindCoreService(flutterPluginBinding.applicationContext)
    }

    private fun bindCoreService(context: Context) {
        val intent = Intent(context, com.follow.clash.service.CoreService::class.java)
        try {
            context.bindService(intent, coreServiceConnection, Context.BIND_AUTO_CREATE)
        } catch (e: Exception) {
            XBoardLog.e("ServicePlugin", "Failed to bind CoreService", e)
        }
    }

    private fun unbindCoreService(context: Context) {
        if (isBound) {
            try {
                context.unbindService(coreServiceConnection)
            } catch (e: Exception) {
                // Ignore
            }
            isBound = false
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        "init" -> {
            handleInit(result)
        }

        "shutdown" -> {
            handleShutdown(result)
        }

        "getRunTime" -> {
            handleGetRunTime(result)
        }

        "syncState" -> {
            handleSyncState(call, result)
        }

        "start" -> {
            handleStart(result)
        }

        "stop" -> {
            handleStop(result)
        }

        "getTunFd" -> {
            handleGetTunFd(result)
        }

        "enableSocketProtection" -> {
            // In dual-process mode, this is handled by :core via AIDL
            // But we still need local protection for the UI process
            try {
                com.follow.clash.core.LeafBridge.enableProtection()
                result.success(null)
            } catch (e: Throwable) {
                XBoardLog.e("ServicePlugin", "enableSocketProtection failed", e)
                result.error("SOCKET_PROTECTION_FAILED", e.message, null)
            }
        }

        "disableSocketProtection" -> {
            try {
                com.follow.clash.core.LeafBridge.disableProtection()
            } catch (e: Throwable) {
                XBoardLog.e("ServicePlugin", "disableSocketProtection failed", e)
            }
            result.success(null)
        }

        // --- Core status callbacks from :core process ---
        "coreStatus" -> {
            // Called when core status changes in :core process
            val args = call.arguments as? Map<*, *>
            if (args != null) {
                flutterMethodChannel.invokeMethodOnMainThread<Any>("coreStatus", args)
            }
            result.success(null)
        }

        "coreError" -> {
            // Called when core encounters an error
            val message = call.arguments as? String ?: ""
            flutterMethodChannel.invokeMethodOnMainThread<Any>("coreError", message)
            result.success(null)
        }

        // --- Dual-process core service methods ---

        "startCore" -> {
            // Start core service via AIDL
            launch {
                try {
                    val configJson = call.argument<String>("configJson") ?: ""
                    val success = coreService?.startLeaf(configJson) ?: false
                    result.success(success)
                } catch (e: Exception) {
                    XBoardLog.e("ServicePlugin", "startCore failed", e)
                    result.error("START_CORE_FAILED", e.message, null)
                }
            }
        }

        "stopCore" -> {
            // Stop core service via AIDL
            launch {
                try {
                    val success = coreService?.stopLeaf() ?: false
                    result.success(success)
                } catch (e: Exception) {
                    XBoardLog.e("ServicePlugin", "stopCore failed", e)
                    result.error("STOP_CORE_FAILED", e.message, null)
                }
            }
        }

        "syncConfig" -> {
            // Sync config to core via AIDL
            launch {
                try {
                    val configJson = call.argument<String>("configJson") ?: ""
                    val success = coreService?.reloadLeaf(configJson) ?: false
                    result.success(success)
                } catch (e: Exception) {
                    XBoardLog.e("ServicePlugin", "syncConfig failed", e)
                    result.error("SYNC_CONFIG_FAILED", e.message, null)
                }
            }
        }

        "getCoreStatus" -> {
            // Get core status via AIDL
            launch {
                try {
                    val status = coreService?.status ?: emptyMap<String, Any>()
                    result.success(status)
                } catch (e: Exception) {
                    XBoardLog.e("ServicePlugin", "getCoreStatus failed", e)
                    result.success(emptyMap<String, Any>())
                }
            }
        }

        "getCoreTunFd" -> {
            // Deprecated - no longer needed in dual-process mode
            // TUN fd is handled locally in :core process
            result.success(-1)
        }

        "isTunReady" -> {
            // Check if TUN is ready in :core process
            try {
                val ready = coreService?.isTunReady() ?: false
                result.success(ready)
            } catch (e: Exception) {
                XBoardLog.e("ServicePlugin", "isTunReady failed", e)
                result.success(false)
            }
        }

        else -> {
            result.notImplemented()
        }
    }

    private fun handleShutdown(result: MethodChannel.Result) {
        State.shutdown()
        result.success(true)
    }

    private fun handleStart(result: MethodChannel.Result) {
        State.handleStartService()
        // Wait for VPN to actually establish (or fail) before returning to Flutter.
        // Without this, _setupConfig() calls getTunFd() before VPN is ready → null →
        // leaf starts without TUN → VPN later captures all traffic → network death.
        launch {
            try {
                val success = withTimeoutOrNull(60_000L) {
                    State.startResultDeferred?.await()
                } ?: false
                result.success(success)
            } catch (e: Exception) {
                result.success(false)
            }
        }
    }

    private fun handleStop(result: MethodChannel.Result) {
        State.handleStopService()
        result.success(true)
    }

    private fun onServiceDisconnected(message: String) {
        State.runStateFlow.tryEmit(RunState.STOP)
        State.startResultDeferred?.complete(false)
        flutterMethodChannel.invokeMethodOnMainThread<Any>("crash", message)
    }

    private fun handleSyncState(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments<String>()!!
        State.sharedState = Gson().fromJson(data, SharedState::class.java)
        State.syncState()
        result.success("")
    }


    fun handleInit(result: MethodChannel.Result) {
        State.onServiceDisconnected = ::onServiceDisconnected
        result.success("")
    }

    private fun handleGetRunTime(result: MethodChannel.Result) {
        launch {
            State.handleSyncState()
            result.success(State.runTime)
        }
    }

    private fun handleGetTunFd(result: MethodChannel.Result) {
        // In dual-process mode, we don't need to get fd here
        // :core process will use its local tunPfd
        // Return -1 as placeholder - :core will replace with actual fd
        if (coreService != null && isBound) {
            // Check if TUN is ready in :core
            try {
                val ready = coreService?.isTunReady() ?: false
                if (ready) {
                    // Return 0 as placeholder - :core will replace with actual fd
                    result.success(0)
                    return
                }
            } catch (e: Exception) {
                XBoardLog.e("ServicePlugin", "isTunReady check failed", e)
            }
        }
        result.success(null)
    }
}
