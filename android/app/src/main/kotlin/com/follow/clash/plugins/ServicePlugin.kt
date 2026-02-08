package com.follow.clash.plugins

import com.follow.clash.RunState
import com.follow.clash.Service
import com.follow.clash.State
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
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
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit

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

        "invokeAction" -> {
            handleInvokeAction(call, result)
        }

        "quickSetup" -> {
            handleQuickSetup(call, result)
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

        else -> {
            result.notImplemented()
        }
    }

    private fun handleInvokeAction(call: MethodCall, result: MethodChannel.Result) {
        launch {
            val data = call.arguments<String>()!!
            var responded = false
            Service.invokeAction(data) {
                responded = true
                result.success(it)
            }.onFailure {
                if (!responded) {
                    result.success(null)
                }
            }
        }
    }

    private fun handleQuickSetup(call: MethodCall, result: MethodChannel.Result) {
        launch {
            val payloadMap = when (val args = call.arguments) {
                is Map<*, *> -> args
                is String -> runCatching {
                    Gson().fromJson(args, Map::class.java) as? Map<*, *>
                }.getOrNull()
                else -> null
            }

            val initParamsString = payloadMap?.get("initParamsString")?.toString().orEmpty()
            val setupParamsString = payloadMap?.get("setupParamsString")?.toString().orEmpty()

            if (initParamsString.isEmpty() || setupParamsString.isEmpty()) {
                result.success("quickSetup invalid arguments")
                return@launch
            }

            GlobalState.log(
                "ServicePlugin.quickSetup: initLen=${initParamsString.length}, setupLen=${setupParamsString.length}"
            )

            var responded = false
            Service.bind(forceRebind = false)
            Service.quickSetup(
                initParamsString = initParamsString,
                setupParamsString = setupParamsString,
                onStarted = null,
                onResult = {
                    responded = true
                    result.success(it)
                }
            ).onFailure {
                GlobalState.log("ServicePlugin.quickSetup failed: ${it.message}")
                if (!responded) {
                    val message = it.message?.takeIf { msg -> msg.isNotEmpty() }
                        ?: "quickSetup failed: android service unavailable"
                    result.success(message)
                }
            }
        }
    }

    private fun handleShutdown(result: MethodChannel.Result) {
        Service.unbind()
        result.success(true)
    }

    private fun handleStart(result: MethodChannel.Result) {
        State.handleStartService()
        result.success(true)
    }

    private fun handleStop(result: MethodChannel.Result) {
        State.handleStopService()
        result.success(true)
    }

    val semaphore = Semaphore(10)

    fun handleSendEvent(value: String?) {
        launch(Dispatchers.Main) {
            semaphore.withPermit {
                flutterMethodChannel.invokeMethod("event", value)
            }
        }
    }

    private fun onServiceDisconnected(message: String) {
        State.runStateFlow.tryEmit(RunState.STOP)
        flutterMethodChannel.invokeMethodOnMainThread<Any>("crash", message)
    }

    private fun handleSyncState(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments<String>()!!
        State.sharedState = Gson().fromJson(data, SharedState::class.java)
        launch {
            State.syncState()
            result.success("")
        }
    }


    fun handleInit(result: MethodChannel.Result) {
        Service.bind()
        launch {
            Service.setEventListener {
                handleSendEvent(it)
            }.onSuccess {
                result.success("")
            }.onFailure {
                result.success(it.message)
            }

        }
        Service.onServiceDisconnected = ::onServiceDisconnected
    }

    private fun handleGetRunTime(result: MethodChannel.Result) {
        launch {
            State.handleSyncState()
            result.success(State.runTime)
        }
    }
}
