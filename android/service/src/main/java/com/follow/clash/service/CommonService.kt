package com.follow.clash.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.getSystemService
import com.follow.clash.common.GlobalState
import com.follow.clash.common.LeafPreferences
import com.follow.clash.service.modules.NetworkObserveModule
import com.follow.clash.service.modules.NotificationModule
import com.follow.clash.service.modules.SuspendModule
import com.follow.clash.service.modules.moduleLoader
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

class CommonService : Service(), IBaseService,
    CoroutineScope by CoroutineScope(Dispatchers.Default) {

    private val self: CommonService
        get() = this

    private val loader = moduleLoader {
        install(NetworkObserveModule(self))
        install(NotificationModule(self))
        install(SuspendModule(self))
    }

    // Flag to track if this is an auto-recovery start
    private var isAutoRecovery = false

    override fun onCreate() {
        super.onCreate()
        // Initialize LeafPreferences in case it's not initialized (for :core process)
        if (!LeafPreferences.initGuard()) {
            try {
                LeafPreferences.init(this)
            } catch (_: Exception) {
                // Already initialized
            }
        }
        State.refreshNotificationParamsFromPrefs()
        handleCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Return START_STICKY to auto-restart if killed
        when (intent?.action) {
            ACTION_STOP -> {
                // User explicitly stopped - clear shouldRun
                LeafPreferences.shouldRun = false
                GlobalState.log("CommonService: User stopped, shouldRun=false")
                stop()
                return START_NOT_STICKY
            }
            ACTION_START -> {
                // Explicit start from UI
                LeafPreferences.shouldRun = true
                LeafPreferences.lastStartTime = System.currentTimeMillis()
                isAutoRecovery = false
            }
            else -> {
                // Check if we should auto-recover
                if (LeafPreferences.shouldRun) {
                    isAutoRecovery = true
                    GlobalState.log("CommonService: Auto-recovering from shouldRun=true")
                } else {
                    // No work to do, stop the service
                    return START_NOT_STICKY
                }
            }
        }

        // Start as foreground service
        startForeground(GlobalState.NOTIFICATION_ID, createNotification())

        // Start the service normally
        start()

        return START_STICKY
    }

    override fun onDestroy() {
        handleDestroy()
        super.onDestroy()
    }

    override fun onLowMemory() {
        super.onLowMemory()
    }

    private fun createNotification(): Notification {
        State.refreshNotificationParamsFromPrefs()
        val params = State.notificationParamsFlow.value ?: com.follow.clash.service.models.NotificationParams()
        val startTime = LeafPreferences.lastStartTime.takeIf { it > 0L } ?: System.currentTimeMillis()
        val channel = NotificationChannel(
            GlobalState.NOTIFICATION_CHANNEL,
            "Orange Proxy",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Proxy service notification"
            setShowBadge(false)
        }

        val notificationManager = getSystemService<NotificationManager>()
        notificationManager?.createNotificationChannel(channel)

        val stopIntent = Intent(this, CommonService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, GlobalState.NOTIFICATION_CHANNEL)
            .setContentTitle("")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setWhen(startTime)
            .setShowWhen(true)
            .setUsesChronometer(true)
            .setChronometerCountDown(false)
            .setOngoing(true)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                params.stopText,
                stopPendingIntent
            )
            .build()
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): CommonService = this@CommonService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun start() {
        try {
            loader.load()
        } catch (_: Exception) {
            stop()
        }
    }

    override fun stop() {
        loader.cancel()
        stopSelf()
    }

    companion object {
        const val ACTION_START = "com.follow.clash.action.START"
        const val ACTION_STOP = "com.follow.clash.action.STOP"
    }
}
