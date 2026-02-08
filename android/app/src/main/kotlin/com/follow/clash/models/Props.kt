package com.follow.clash.models

import com.google.gson.annotations.SerializedName
import java.net.InetAddress

enum class AccessControlMode {
    @SerializedName("acceptSelected")
    ACCEPT_SELECTED,

    @SerializedName("rejectSelected")
    REJECT_SELECTED,
}

data class AccessControlProps(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
)

data class VpnOptions(
    val enable: Boolean,
    val port: Int,
    val ipv6: Boolean,
    val dnsHijacking: Boolean,
    val accessControlProps: AccessControlProps,
    val allowBypass: Boolean,
    val systemProxy: Boolean,
    val bypassDomain: List<String>,
    val stack: String,
    val routeAddress: List<String>,
)

data class CIDR(val address: InetAddress, val prefixLength: Int)

data class SharedState(
    val startTip: String = "Starting VPN...",
    val stopTip: String = "Stopping VPN...",
    val currentProfileName: String = "FlClash",
    val stopText: String = "Stop",
    val onlyStatisticsProxy: Boolean = false,
    val vpnOptions: VpnOptions? = null,
    val setupParams: SetupParams? = null,
)

data class SetupParams(
    @SerializedName("test-url")
    val testUrl: String,
    @SerializedName("selected-map")
    val selectedMap: Map<String, String>,
)

data class StartForegroundParams(
    val title: String,
    val stopText: String,
)

fun VpnOptions.getIpv4RouteAddress(): List<CIDR> {
    return routeAddress.filter { it.isIpv4() }.map { it.toCIDR() }
}

fun VpnOptions.getIpv6RouteAddress(): List<CIDR> {
    return routeAddress.filter { it.isIpv6() }.map { it.toCIDR() }
}

fun String.isIpv4(): Boolean {
    val parts = split("/")
    if (parts.size != 2) throw IllegalArgumentException("Invalid CIDR format")
    val address = InetAddress.getByName(parts[0])
    return address.address.size == 4
}

fun String.isIpv6(): Boolean {
    val parts = split("/")
    if (parts.size != 2) throw IllegalArgumentException("Invalid CIDR format")
    val address = InetAddress.getByName(parts[0])
    return address.address.size == 16
}

fun String.toCIDR(): CIDR {
    val parts = split("/")
    if (parts.size != 2) throw IllegalArgumentException("Invalid CIDR format")
    val ipAddress = parts[0]
    val prefixLength = parts[1].toIntOrNull() ?: throw IllegalArgumentException("Invalid prefix length")
    val address = InetAddress.getByName(ipAddress)
    val maxPrefix = if (address.address.size == 4) 32 else 128
    if (prefixLength < 0 || prefixLength > maxPrefix) {
        throw IllegalArgumentException("Invalid prefix length for IP version")
    }
    return CIDR(address, prefixLength)
}
