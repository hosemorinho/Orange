package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.IBinder

/**
 * Android Service host for the ICoreService binder.
 *
 * The actual core logic lives in [CoreService] (AIDL Stub). This host exists so
 * clients can bind using the normal Android service lifecycle.
 */
class CoreServiceHost : Service() {
    private val binder = CoreService()

    override fun onCreate() {
        super.onCreate()
        binder.init(applicationContext)
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }
}
