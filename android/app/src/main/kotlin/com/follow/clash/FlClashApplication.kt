package com.follow.clash

import android.app.Application
import android.content.Context

class FlClashApplication : Application() {
    companion object {
        private lateinit var appContext: Context

        fun getAppContext(): Context = appContext
    }

    override fun onCreate() {
        super.onCreate()
        appContext = applicationContext
    }
}
