package com.follow.clash.plugins

import com.follow.clash.GlobalState
import com.follow.clash.RunState
import com.follow.clash.core.Core
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "service")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        "init" -> {
            result.success("")
        }

        "destroy" -> {
            result.success(true)
        }

        "invokeAction" -> {
            val data = call.arguments as String
            Core.invokeAction(data) { actionResult ->
                result.success(actionResult)
            }
        }

        "setEventListener" -> {
            Core.callSetEventListener { eventData ->
                channel.invokeMethod("event", eventData)
            }
            result.success(true)
        }

        "removeEventListener" -> {
            Core.callSetEventListener(null)
            result.success(true)
        }

        "quickSetup" -> {
            val initParams = call.argument<String>("initParams")!!
            val setupParams = call.argument<String>("setupParams")!!
            Core.quickSetup(initParams, setupParams) { setupResult ->
                result.success(setupResult)
            }
        }

        "startVpn" -> {
            GlobalState.runStateFlow.tryEmit(RunState.PENDING)
            GlobalState.getCurrentVPNPlugin()?.let { vpnPlugin ->
                vpnPlugin.onMethodCall(
                    MethodCall("start", call.arguments),
                    result
                )
            } ?: result.success(false)
        }

        "stopVpn" -> {
            GlobalState.getCurrentVPNPlugin()?.let { vpnPlugin ->
                vpnPlugin.onMethodCall(
                    MethodCall("stop", call.arguments),
                    result
                )
            } ?: result.success(false)
        }

        else -> {
            result.notImplemented()
        }
    }
}
