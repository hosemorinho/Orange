package com.follow.clash.common


import android.app.Application
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

object GlobalState : CoroutineScope by CoroutineScope(Dispatchers.Default) {

    const val NOTIFICATION_CHANNEL = "Orange"

    const val NOTIFICATION_ID = 1

    val packageName: String
        get() = application.packageName

    val RECEIVE_BROADCASTS_PERMISSIONS: String
        get() = "${packageName}.permission.RECEIVE_BROADCASTS"


    private var _application: Application? = null

    val application: Application
        get() = _application
            ?: throw IllegalStateException("GlobalState.application accessed before init(). Ensure Application.attachBaseContext() has run.")

    val isInitialized: Boolean
        get() = _application != null

    fun log(text: String) {
        Log.d("[Orange]", text)
    }

    fun init(application: Application) {
        _application = application
        LeafPreferences.init(application)
    }
}
