package com.follow.clash.services

import android.content.Intent
import android.net.ConnectivityManager
import android.net.ProxyInfo
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.content.getSystemService
import com.follow.clash.GlobalState
import com.follow.clash.models.AccessControlMode
import com.follow.clash.models.VpnOptions
import com.follow.clash.models.getIpv4RouteAddress
import com.follow.clash.models.getIpv6RouteAddress
import com.follow.clash.models.toCIDR
import java.net.InetSocketAddress
import android.net.VpnService as SystemVpnService

class FlClashVpnService : SystemVpnService(), BaseServiceInterface {

    private val connectivity by lazy {
        getSystemService<ConnectivityManager>()
    }

    private val uidPackageNameMap = mutableMapOf<Int, String>()

    override fun protect(fd: Int): Boolean {
        return super.protect(fd)
    }

    fun resolverProcess(
        protocol: Int,
        source: InetSocketAddress,
        target: InetSocketAddress,
        uid: Int,
    ): String {
        val nextUid = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            connectivity?.getConnectionOwnerUid(protocol, source, target) ?: -1
        } else {
            uid
        }
        if (nextUid == -1) return ""
        if (!uidPackageNameMap.containsKey(nextUid)) {
            uidPackageNameMap[nextUid] = packageManager?.getPackagesForUid(nextUid)?.first() ?: ""
        }
        return uidPackageNameMap[nextUid] ?: ""
    }

    override fun start(): Int {
        return 0
    }

    fun startVpn(options: VpnOptions): Int {
        val fd = with(Builder()) {
            val cidr = IPV4_ADDRESS.toCIDR()
            addAddress(cidr.address, cidr.prefixLength)
            Log.d("addAddress", "address: ${cidr.address} prefixLength:${cidr.prefixLength}")

            val routeAddress = options.getIpv4RouteAddress()
            if (routeAddress.isNotEmpty()) {
                try {
                    routeAddress.forEach { i ->
                        Log.d("addRoute4", "address: ${i.address} prefixLength:${i.prefixLength}")
                        addRoute(i.address, i.prefixLength)
                    }
                } catch (_: Exception) {
                    addRoute(NET_ANY, 0)
                }
            } else {
                addRoute(NET_ANY, 0)
            }

            if (options.ipv6) {
                try {
                    val ipv6Cidr = IPV6_ADDRESS.toCIDR()
                    Log.d("addAddress6", "address: ${ipv6Cidr.address} prefixLength:${ipv6Cidr.prefixLength}")
                    addAddress(ipv6Cidr.address, ipv6Cidr.prefixLength)
                } catch (_: Exception) {
                    Log.d("addAddress6", "IPv6 is not supported.")
                }

                try {
                    val ipv6RouteAddress = options.getIpv6RouteAddress()
                    if (ipv6RouteAddress.isNotEmpty()) {
                        try {
                            ipv6RouteAddress.forEach { i ->
                                Log.d("addRoute6", "address: ${i.address} prefixLength:${i.prefixLength}")
                                addRoute(i.address, i.prefixLength)
                            }
                        } catch (_: Exception) {
                            addRoute("::", 0)
                        }
                    } else {
                        addRoute(NET_ANY6, 0)
                    }
                } catch (_: Exception) {
                    addRoute(NET_ANY6, 0)
                }
            }

            addDnsServer(DNS)
            if (options.ipv6) {
                addDnsServer(DNS6)
            }
            setMtu(9000)

            options.accessControlProps.let { accessControl ->
                if (accessControl.enable) {
                    when (accessControl.mode) {
                        AccessControlMode.ACCEPT_SELECTED -> {
                            (accessControl.acceptList + packageName).forEach {
                                addAllowedApplication(it)
                            }
                        }

                        AccessControlMode.REJECT_SELECTED -> {
                            (accessControl.rejectList - packageName).forEach {
                                addDisallowedApplication(it)
                            }
                        }
                    }
                }
            }

            setSession("FlClash")
            setBlocking(false)
            if (Build.VERSION.SDK_INT >= 29) {
                setMetered(false)
            }
            if (options.allowBypass) {
                allowBypass()
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.systemProxy) {
                GlobalState.log("Open http proxy")
                setHttpProxy(
                    ProxyInfo.buildDirectProxy("127.0.0.1", options.port, options.bypassDomain)
                )
            }
            establish()?.detachFd()
                ?: throw NullPointerException("Establish VPN rejected by system")
        }
        return fd
    }

    override fun stop() {
        stopSelf()
    }

    val address: (VpnOptions) -> String = { options ->
        buildString {
            append(IPV4_ADDRESS)
            if (options.ipv6) {
                append(",")
                append(IPV6_ADDRESS)
            }
        }
    }

    val dns: (VpnOptions) -> String = { options ->
        if (options.dnsHijacking) {
            NET_ANY
        } else {
            buildString {
                append(DNS)
                if (options.ipv6) {
                    append(",")
                    append(DNS6)
                }
            }
        }
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): FlClashVpnService = this@FlClashVpnService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    companion object {
        const val IPV4_ADDRESS = "172.19.0.1/30"
        const val IPV6_ADDRESS = "fdfe:dcba:9876::1/126"
        const val DNS = "172.19.0.2"
        const val DNS6 = "fdfe:dcba:9876::2"
        const val NET_ANY = "0.0.0.0"
        const val NET_ANY6 = "::"
    }
}
