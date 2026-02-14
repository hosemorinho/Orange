package com.follow.clash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import com.follow.clash.common.LeafPreferences
import com.follow.clash.common.XBoardLog
import com.follow.clash.service.CommonService
import com.follow.clash.service.VpnService
import com.google.gson.Gson

/**
 * Restores proxy service after reboot/package update when the user left it running.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (
            action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_LOCKED_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            return
        }

        if (!LeafPreferences.initGuard()) {
            LeafPreferences.init(context.applicationContext)
        }

        if (!LeafPreferences.shouldRun) {
            XBoardLog.i("BootReceiver", "Skip restore: shouldRun=false")
            return
        }

        val options = runCatching {
            Gson().fromJson(LeafPreferences.vpnOptionsJson, com.follow.clash.service.models.VpnOptions::class.java)
        }.getOrNull()
        val enableVpn = options?.enable ?: true
        val target = if (enableVpn) VpnService::class.java else CommonService::class.java
        val actionStart = if (enableVpn) VpnService.ACTION_START else CommonService.ACTION_START

        val startIntent = Intent(context, target).apply {
            this.action = actionStart
        }

        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(startIntent)
            } else {
                context.startService(startIntent)
            }
            XBoardLog.i("BootReceiver", "Restore requested for ${target.simpleName}")
        }.onFailure {
            XBoardLog.e("BootReceiver", "Failed to restore service", it)
        }
    }
}
