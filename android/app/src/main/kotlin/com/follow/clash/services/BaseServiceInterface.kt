package com.follow.clash.services

import android.app.Notification
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.follow.clash.FlClashApplication
import com.follow.clash.R
import com.follow.clash.extensions.NOTIFICATION_CHANNEL
import com.follow.clash.extensions.PACKAGE_NAME
import com.follow.clash.extensions.startForeground
import com.follow.clash.models.StartForegroundParams

interface BaseServiceInterface {
    fun start(): Int
    fun stop()

    fun startForeground(service: android.app.Service, params: StartForegroundParams) {
        val context = FlClashApplication.getAppContext()
        val applicationId = context.packageName

        val mainIntent = Intent().apply {
            setClassName(applicationId, "${PACKAGE_NAME}.MainActivity")
            setPackage(applicationId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val mainPendingIntent = PendingIntent.getActivity(
            context, 0, mainIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val stopIntent = Intent().apply {
            setClassName(applicationId, "${PACKAGE_NAME}.TempActivity")
            setPackage(applicationId)
            action = "${applicationId}.action.STOP"
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
        }
        val stopPendingIntent = PendingIntent.getActivity(
            context, 1, stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL)
            .setSmallIcon(R.drawable.ic)
            .setContentTitle(params.title)
            .setContentIntent(mainPendingIntent)
            .addAction(0, params.stopText, stopPendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .build()

        service.startForeground(notification)
    }
}
