package com.follow.clash.extensions

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ComponentName
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.os.Build

const val PACKAGE_NAME = "com.follow.clash"
const val NOTIFICATION_CHANNEL = "FlClash"
const val NOTIFICATION_ID = 1

enum class QuickAction {
    STOP,
    START,
    TOGGLE,
}

fun wrapAction(applicationId: String, action: String?): QuickAction? {
    return QuickAction.entries.firstOrNull { "${applicationId}.action.${it.name}" == action }
}

fun getActionIntent(applicationId: String, quickAction: QuickAction): Intent {
    return Intent().apply {
        component = ComponentName(applicationId, "${PACKAGE_NAME}.TempActivity")
        setPackage(applicationId)
        this.action = "${applicationId}.action.${quickAction.name}"
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
    }
}

fun getActionPendingIntent(applicationId: String, quickAction: QuickAction): PendingIntent {
    val intent = getActionIntent(applicationId, quickAction)
    return PendingIntent.getActivity(
        null,
        0,
        intent,
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )
}

fun Service.startForeground(notification: Notification) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val manager = getSystemService(NotificationManager::class.java)
        var channel = manager?.getNotificationChannel(NOTIFICATION_CHANNEL)
        if (channel == null) {
            channel = NotificationChannel(
                NOTIFICATION_CHANNEL,
                "SERVICE_CHANNEL",
                NotificationManager.IMPORTANCE_LOW
            )
            manager?.createNotificationChannel(channel)
        }
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startForeground(NOTIFICATION_ID, notification, FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
    } else {
        startForeground(NOTIFICATION_ID, notification)
    }
}
