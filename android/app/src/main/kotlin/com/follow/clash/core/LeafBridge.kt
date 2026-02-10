package com.follow.clash.core

import android.net.VpnService
import android.util.Log

/**
 * JNI bridge to libleaf.so (Rust proxy core).
 *
 * Loads the leaf native library and provides socket protection
 * via JNI callback mechanism.
 *
 * Leaf calls [protectSocket] from native code when it needs to
 * protect a socket from being routed through the VPN tunnel.
 */
object LeafBridge {
    private const val TAG = "LeafBridge"

    private var vpnService: VpnService? = null

    init {
        System.loadLibrary("leaf")
    }

    /**
     * Register the VPN service for socket protection.
     * Must be called before starting leaf when using TUN mode.
     */
    fun setVpnService(service: VpnService?) {
        vpnService = service
        if (service != null) {
            nativeSetProtectSocketCallback()
        }
    }

    /**
     * Called from native code (Rust/JNI) when leaf needs to protect a socket fd.
     * This prevents the socket from being routed through the VPN tunnel.
     *
     * @param fd The raw file descriptor of the socket to protect.
     * @return true if protection succeeded, false otherwise.
     */
    @JvmStatic
    fun protectSocket(fd: Int): Boolean {
        val service = vpnService
        if (service == null) {
            Log.w(TAG, "protectSocket called but no VPN service registered")
            return false
        }
        val result = service.protect(fd)
        if (!result) {
            Log.w(TAG, "Failed to protect socket fd=$fd")
        }
        return result
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
