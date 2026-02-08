package com.follow.clash.services

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

class FlClashService : Service(), BaseServiceInterface {

    override fun start(): Int {
        return 0
    }

    override fun stop() {
        stopSelf()
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): FlClashService = this@FlClashService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }
}
