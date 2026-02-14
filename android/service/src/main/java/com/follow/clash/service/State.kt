package com.follow.clash.service

import android.net.VpnService
import android.os.ParcelFileDescriptor
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow

object State {
    var options: VpnOptions? = null
    var notificationParamsFlow: MutableStateFlow<NotificationParams?> = MutableStateFlow(
        NotificationParams()
    )

    /** The TUN ParcelFileDescriptor from VpnService.Builder.establish(). */
    @Volatile var tunPfd: ParcelFileDescriptor? = null

    @Volatile var vpnService: VpnService? = null
}
