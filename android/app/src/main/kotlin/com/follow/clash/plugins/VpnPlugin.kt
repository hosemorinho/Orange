package com.follow.clash.plugins

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.IBinder
import androidx.core.content.getSystemService
import com.follow.clash.FlClashApplication
import com.follow.clash.GlobalState
import com.follow.clash.RunState
import com.follow.clash.awaitResult
import com.follow.clash.core.Core
import com.follow.clash.extensions.PACKAGE_NAME
import com.follow.clash.invokeMethodOnMainThread
import com.follow.clash.models.VpnOptions
import com.follow.clash.services.FlClashService
import com.follow.clash.services.FlClashVpnService
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.InetSocketAddress

class VpnPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private lateinit var channel: MethodChannel
    private var vpnService: FlClashVpnService? = null
    private var commonService: FlClashService? = null
    private var serviceConnection: ServiceConnection? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpn")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                launch { handleStart(call, result) }
            }

            "stop" -> {
                launch { handleStop(result) }
            }

            else -> result.notImplemented()
        }
    }

    private suspend fun handleStart(call: MethodCall, result: MethodChannel.Result) {
        try {
            val data = call.arguments<String>()!!
            val options = Gson().fromJson(data, VpnOptions::class.java)

            if (options.enable) {
                val appPlugin = GlobalState.getCurrentAppPlugin()
                if (appPlugin != null) {
                    withContext(Dispatchers.Main) {
                        appPlugin.prepare(true) {
                            startVpnService(options)
                        }
                    }
                } else {
                    startVpnService(options)
                }
            } else {
                startCommonService()
            }

            withContext(Dispatchers.Main) {
                result.success(true)
            }
        } catch (e: Exception) {
            GlobalState.log("VpnPlugin handleStart error: $e")
            withContext(Dispatchers.Main) {
                result.success(false)
            }
        }
    }

    private suspend fun startVpnService(options: VpnOptions) {
        val context = FlClashApplication.getAppContext()
        val intent = Intent(context, FlClashVpnService::class.java)

        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
                val service = (binder as FlClashVpnService.LocalBinder).getService()
                vpnService = service
                launch {
                    try {
                        val fd = service.startVpn(options)
                        Core.startTun(
                            fd,
                            protect = service::protect,
                            resolverProcess = service::resolverProcess,
                            options.stack,
                            service.address(options),
                            service.dns(options),
                        )
                        startNetworkMonitoring()

                        val params = channel.awaitResult<Map<String, Any>>("getStartForegroundParams")
                        if (params != null) {
                            val title = params["title"] as? String ?: "FlClash"
                            val stopText = params["stopText"] as? String ?: "Stop"
                            service.startForeground(
                                service,
                                com.follow.clash.models.StartForegroundParams(title, stopText)
                            )
                        }

                        GlobalState.runStateFlow.tryEmit(RunState.START)
                    } catch (e: Exception) {
                        GlobalState.log("startVpn error: $e")
                        GlobalState.runStateFlow.tryEmit(RunState.STOP)
                    }
                }
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                vpnService = null
                GlobalState.runStateFlow.tryEmit(RunState.STOP)
            }
        }
        serviceConnection = connection
        context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }

    private fun startCommonService() {
        val context = FlClashApplication.getAppContext()
        val intent = Intent(context, FlClashService::class.java)

        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
                val service = (binder as FlClashService.LocalBinder).getService()
                commonService = service
                launch {
                    val params = channel.awaitResult<Map<String, Any>>("getStartForegroundParams")
                    if (params != null) {
                        val title = params["title"] as? String ?: "FlClash"
                        val stopText = params["stopText"] as? String ?: "Stop"
                        service.startForeground(
                            service,
                            com.follow.clash.models.StartForegroundParams(title, stopText)
                        )
                    }
                    GlobalState.runStateFlow.tryEmit(RunState.START)
                }
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                commonService = null
                GlobalState.runStateFlow.tryEmit(RunState.STOP)
            }
        }
        serviceConnection = connection
        context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }

    private suspend fun handleStop(result: MethodChannel.Result) {
        try {
            stopNetworkMonitoring()
            Core.stopTun()
            vpnService?.stop()
            commonService?.stop()
            vpnService = null
            commonService = null
            val context = FlClashApplication.getAppContext()
            serviceConnection?.let {
                try {
                    context.unbindService(it)
                } catch (_: Exception) {
                }
            }
            serviceConnection = null
            GlobalState.runStateFlow.tryEmit(RunState.STOP)
            withContext(Dispatchers.Main) {
                result.success(true)
            }
        } catch (e: Exception) {
            GlobalState.log("VpnPlugin handleStop error: $e")
            withContext(Dispatchers.Main) {
                result.success(false)
            }
        }
    }

    private fun startNetworkMonitoring() {
        val context = FlClashApplication.getAppContext()
        val connectivityManager = context.getSystemService<ConnectivityManager>() ?: return

        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                channel.invokeMethodOnMainThread<Any>("dnsChanged", null)
            }

            override fun onLinkPropertiesChanged(
                network: Network,
                linkProperties: android.net.LinkProperties
            ) {
                channel.invokeMethodOnMainThread<Any>("dnsChanged", null)
            }
        }
        networkCallback = callback
        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        connectivityManager.registerNetworkCallback(request, callback)
    }

    private fun stopNetworkMonitoring() {
        val context = FlClashApplication.getAppContext()
        val connectivityManager = context.getSystemService<ConnectivityManager>() ?: return
        networkCallback?.let {
            try {
                connectivityManager.unregisterNetworkCallback(it)
            } catch (_: Exception) {
            }
        }
        networkCallback = null
    }
}
