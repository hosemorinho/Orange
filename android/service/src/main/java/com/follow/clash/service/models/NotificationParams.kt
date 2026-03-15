package com.follow.clash.service.models

import android.os.Parcelable
import com.follow.clash.common.GlobalState
import kotlinx.parcelize.Parcelize

@Parcelize
data class NotificationParams(
    val title: String = GlobalState.appName,
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
) : Parcelable
