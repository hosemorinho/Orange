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

    private val tokenPattern = Regex("([?&]token=)[^&\\s]+", RegexOption.IGNORE_CASE)
    private val urlPattern = Regex("https?://\\S+", RegexOption.IGNORE_CASE)
    private val ipPortPattern = Regex("\\b\\d{1,3}(?:\\.\\d{1,3}){3}:\\d+\\b")
    private val ipPattern = Regex("\\b\\d{1,3}(?:\\.\\d{1,3}){3}\\b")
    private val domainPattern = Regex(
        "\\b[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)*\\.(com|net|org|io|dev|cn|cc|me|info|xyz|top|cloud|app|co)\\b",
        RegexOption.IGNORE_CASE,
    )

    private fun sanitizeLog(text: String): String {
        var result = text
        result = result.replace(tokenPattern, "$1***")
        result = result.replace(urlPattern) { match ->
            if (match.value.startsWith("https", ignoreCase = true)) {
                "https://***"
            } else {
                "http://***"
            }
        }
        result = result.replace(ipPortPattern, "*.*.*.*:***")
        result = result.replace(ipPattern, "*.*.*.*")
        result = result.replace(domainPattern, "***.***")
        return result
    }

    fun log(text: String) {
        Log.d("[Orange]", sanitizeLog(text))
    }

    fun init(application: Application) {
        _application = application
    }
}
