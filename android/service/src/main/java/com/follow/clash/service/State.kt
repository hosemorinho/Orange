package com.follow.clash.service

import android.net.VpnService
import android.os.ParcelFileDescriptor
import com.follow.clash.common.LeafBridge
import com.follow.clash.common.LeafPreferences
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import kotlinx.coroutines.flow.MutableStateFlow

object State {
    var options: VpnOptions? = null
    var notificationParamsFlow: MutableStateFlow<NotificationParams?> = MutableStateFlow(
        NotificationParams()
    )

    /** The TUN ParcelFileDescriptor from VpnService.Builder.establish(). */
    @Volatile var tunPfd: ParcelFileDescriptor? = null

    @Volatile var vpnService: VpnService? = null
        set(value) {
            field = value
            // Update LeafBridge's VPN service reference for socket protection
            LeafBridge.vpnService = value
        }

    /**
     * Whether the service should be running.
     * Mirrors LeafPreferences.shouldRun for quick access from service.
     */
    var shouldRun: Boolean
        get() = LeafPreferences.shouldRun
        set(value) {
            LeafPreferences.shouldRun = value
        }

    /**
     * Current leaf runtime status.
     */
    enum class LeafStatus {
        STOPPED,
        STARTING,
        RUNNING,
        ERROR
    }

    @Volatile var leafStatus: LeafStatus = LeafStatus.STOPPED
        private set

    @Volatile var leafErrorMessage: String = ""

    fun setLeafStatus(status: LeafStatus, errorMessage: String = "") {
        leafStatus = status
        leafErrorMessage = errorMessage
    }

    /**
     * Get current core status as Map.
     */
    fun getCoreStatus(): Map<String, Any> {
        return mapOf(
            "isRunning" to (leafStatus == LeafStatus.RUNNING),
            "shouldRun" to shouldRun,
            "status" to leafStatus.name,
            "errorMessage" to leafErrorMessage,
            "selectedNode" to LeafPreferences.selectedNodeTag,
            "mode" to LeafPreferences.mode,
            "lastStartTime" to LeafPreferences.lastStartTime
        )
    }

    fun ensureOptionsFromPrefs() {
        if (options != null) return
        val raw = LeafPreferences.vpnOptionsJson
        if (raw.isEmpty()) return
        try {
            options = Gson().fromJson(raw, VpnOptions::class.java)
        } catch (_: Exception) {
            // Ignore malformed cached options.
        }
    }
}
