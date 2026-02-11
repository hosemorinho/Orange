package com.follow.clash.core

import android.util.Log
import com.follow.clash.Service
import kotlinx.coroutines.runBlocking

/**
 * JNI bridge to libleaf.so (Rust proxy core).
 *
 * Loads the leaf native library and provides socket protection
 * via JNI callback mechanism.
 *
 * Leaf calls [protectSocket] from native code when it needs to
 * protect a socket from being routed through the VPN tunnel.
 *
 * Since the VPN service runs in the :remote process and leaf runs
 * in the :app process via FFI, socket protection is forwarded
 * across the process boundary via AIDL.
 */
object LeafBridge {
    private const val TAG = "LeafBridge"

    private var protectionEnabled = false

    init {
        System.loadLibrary("leaf")
    }

    /**
     * Enable socket protection via the remote VPN service.
     * Must be called before starting leaf when using TUN mode.
     * Registers the JNI callback so leaf's Rust code can call [protectSocket].
     */
    fun enableProtection() {
        protectionEnabled = true
        nativeSetProtectSocketCallback()
    }

    /**
     * Disable socket protection (e.g., when VPN is stopped).
     */
    fun disableProtection() {
        protectionEnabled = false
    }

    /**
     * Called from native code (Rust/JNI) when leaf needs to protect a socket fd.
     * Forwards the request to the VPN service in the :remote process via AIDL.
     *
     * This method blocks the calling (native) thread until protection completes.
     *
     * @param fd The raw file descriptor of the socket to protect.
     * @return true if protection succeeded, false otherwise.
     */
    @JvmStatic
    fun protectSocket(fd: Int): Boolean {
        if (!protectionEnabled) {
            Log.w(TAG, "protectSocket called but protection not enabled")
            return false
        }
        return try {
            runBlocking {
                Service.protectSocket(fd)
            }
        } catch (e: Exception) {
            Log.w(TAG, "protectSocket failed for fd=$fd: $e")
            false
        }
    }

    // -- Native methods (implemented in leaf-ffi) --

    /**
     * Register the [protectSocket] method as the socket protection callback.
     * Leaf will call it whenever it creates a new socket that needs protection.
     */
    private external fun nativeSetProtectSocketCallback()

    // The following are convenience wrappers around leaf-ffi functions.
    // On Android, these can be called directly from Kotlin without going
    // through Dart FFI (useful for the :remote process).

    /**
     * Start leaf with a config file path. Blocks the calling thread.
     * Must be called on a background thread.
     */
    external fun leafRunWithOptions(
        rtId: Int,
        configPath: String,
        autoReload: Boolean,
        multiThread: Boolean,
        autoThreads: Boolean,
        threads: Int,
        stackSize: Int,
    ): Int

    /** Reload config (DNS, outbounds, routing rules). */
    external fun leafReload(rtId: Int): Int

    /** Graceful shutdown. */
    external fun leafShutdown(rtId: Int): Boolean

    /** Validate a config file. */
    external fun leafTestConfig(configPath: String): Int
}
