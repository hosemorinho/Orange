package com.follow.clash.plugins

import com.follow.clash.RunState
import com.follow.clash.State
import com.follow.clash.common.Components
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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/service"
        )
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
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
            try {
                com.follow.clash.core.LeafBridge.enableProtection()
                result.success(null)
            } catch (e: Throwable) {
                com.follow.clash.common.XBoardLog.e("ServicePlugin", "enableSocketProtection failed", e)
                result.error("SOCKET_PROTECTION_FAILED", e.message, null)
            }
        }

        "disableSocketProtection" -> {
            try {
                com.follow.clash.core.LeafBridge.disableProtection()
            } catch (e: Throwable) {
                com.follow.clash.common.XBoardLog.e("ServicePlugin", "disableSocketProtection failed", e)
            }
            result.success(null)
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
        val pfd = com.follow.clash.service.State.tunPfd
        if (pfd == null) {
            result.success(null)
            return
        }
        try {
            val dupPfd = pfd.dup()
            val fd = dupPfd.detachFd()
            result.success(fd)
        } catch (e: Exception) {
            com.follow.clash.common.XBoardLog.e("ServicePlugin", "handleGetTunFd dup failed", e)
            result.success(null)
        }
    }
}
