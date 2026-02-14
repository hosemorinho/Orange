package com.follow.clash.common

import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Writes log messages to xboard.log (same file as Dart's DiskLogger).
 *
 * Format matches Dart side: [HH:MM:SS][LEVEL] message
 *
 * Falls back to logcat-only if the log file is not accessible.
 */
object XBoardLog {
    private const val TAG = "XBoardLog"
    private val timeFormat = SimpleDateFormat("HH:mm:ss", Locale.US)

    private fun logFile(): File? {
        if (!GlobalState.isInitialized) return null
        val dir = GlobalState.application.getExternalFilesDir(null) ?: return null
        return File(dir, "xboard.log")
    }

    private fun write(level: String, tag: String, message: String) {
        val ts = timeFormat.format(Date())
        val line = "[$ts][$level] [$tag] $message\n"
        try {
            logFile()?.appendText(line)
        } catch (_: Exception) {
            // Fall back to logcat only
        }
    }

    fun i(tag: String, message: String) {
        Log.i(tag, message)
        write("INFO", tag, message)
    }

    fun w(tag: String, message: String) {
        Log.w(tag, message)
        write("WARN", tag, message)
    }

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        if (throwable != null) {
            Log.e(tag, message, throwable)
        } else {
            Log.e(tag, message)
        }
        val full = if (throwable != null) {
            "$message\n  Error: ${throwable.message}\n  StackTrace:\n${throwable.stackTraceToString()}"
        } else {
            message
        }
        write("ERROR", tag, full)
    }
}
