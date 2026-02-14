package com.follow.clash.core

import android.util.Log

/**
 * JNI bridge to libleaf.so (Rust proxy core).
 *
 * Loads the leaf native library and provides socket protection
 * via JNI callback mechanism.
 *
 * Leaf calls [protectSocket] from native code when it needs to
 * protect a socket from being routed through the VPN tunnel.
 *
 * All services run in the same process, so socket protection is
 * a direct in-process call to VpnService.protect().
 */
object LeafBridge {
    private const val TAG = "LeafBridge"

    private var protectionEnabled = false

    private var libraryLoaded = false

    init {
        try {
            System.loadLibrary("leaf")
            libraryLoaded = true
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "Failed to load libleaf.so: ${e.message}", e)
        }
    }

    /**
     * Enable socket protection via the remote VPN service.
     * Must be called before starting leaf when using TUN mode.
     * Registers the JNI callback so leaf's Rust code can call [protectSocket].
     */
    fun enableProtection() {
        if (!libraryLoaded) {
            Log.e(TAG, "enableProtection: libleaf.so not loaded, skipping")
            return
        }
        protectionEnabled = true
        try {
            nativeSetProtectSocketCallback()
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "nativeSetProtectSocketCallback failed: ${e.message}", e)
        } catch (e: Exception) {
            Log.e(TAG, "enableProtection failed: ${e.message}", e)
        }
    }

    /**
     * Disable socket protection (e.g., when VPN is stopped).
     */
    fun disableProtection() {
        protectionEnabled = false
    }

    /**
     * Called from native code (Rust/JNI) when leaf needs to protect a socket fd.
     * Direct in-process call to VpnService.protect() — thread-safe per Android docs.
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
            com.follow.clash.service.State.vpnService?.protect(fd) ?: false
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
