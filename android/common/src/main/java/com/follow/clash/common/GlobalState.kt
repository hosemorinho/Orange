package com.follow.clash.common


import android.app.Application
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

object GlobalState : CoroutineScope by CoroutineScope(Dispatchers.Default) {

    val NOTIFICATION_CHANNEL: String
        get() = "${packageName}.service"

    const val NOTIFICATION_ID = 1

    val packageName: String
        get() = application.packageName

    val appName: String
        get() = runCatching {
            val label = application.applicationInfo.loadLabel(application.packageManager)?.toString()
            if (label.isNullOrBlank()) packageName else label
        }.getOrElse { packageName }

    val RECEIVE_BROADCASTS_PERMISSIONS: String
        get() = "${packageName}.permission.RECEIVE_BROADCASTS"


    private var _application: Application? = null

    val application: Application
        get() = _application
            ?: throw IllegalStateException("GlobalState.application accessed before init(). Ensure Application.attachBaseContext() has run.")

    val isInitialized: Boolean
        get() = _application != null

    private fun logTag(): String {
        val tag = "[$appName]"
        return if (tag.length <= 23) tag else tag.take(23)
    }

    fun log(text: String) {
        Log.d(logTag(), text)
    }

    fun init(application: Application) {
        _application = application
        LeafPreferences.init(application)
    }
}
