package com.follow.clash

import android.app.Application
import android.content.Context
import com.follow.clash.common.GlobalState
import com.follow.clash.common.XBoardLog

class Application : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
        // Load libleaf.so here BEFORE Dart engine starts.
        // Dart FFI's DynamicLibrary.open('libleaf.so') uses dlopen() which
        // does NOT register the library with JNI. If Dart loads first and
        // System.loadLibrary("leaf") runs later, the duplicate load causes
        // a native crash in nativeSetProtectSocketCallback().
        // Loading here ensures JNI_OnLoad runs first and JNI methods resolve.
        try {
            System.loadLibrary("leaf")
        } catch (e: UnsatisfiedLinkError) {
            XBoardLog.e("Application", "Failed to preload libleaf.so", e)
        }
    }
}
