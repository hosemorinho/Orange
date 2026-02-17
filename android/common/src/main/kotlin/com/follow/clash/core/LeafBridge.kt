package com.follow.clash.common

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
 * In dual-process architecture:
 * - In :core process: direct call to VpnService.protect()
 * - In UI process: IPC call to :core process
 */
object LeafBridge {
    private const val TAG = "LeafBridge"

    @Volatile private var protectionEnabled = false

    // VPN service reference for socket protection
    // In :core process, this is set to the local VpnService
    // In UI process, this should be null (use IPC instead)
    @Volatile var vpnService: android.net.VpnService? = null

    /**
     * Enable socket protection via the VPN service.
     * Must be called before starting leaf when using TUN mode.
     * Registers the JNI callback so leaf's Rust code can call [protectSocket].
     */
    fun enableProtection() {
        protectionEnabled = true
        try {
            nativeSetProtectSocketCallback()
            XBoardLog.i(TAG, "enableProtection: socket protection callback registered")
        } catch (e: UnsatisfiedLinkError) {
            XBoardLog.e(TAG, "nativeSetProtectSocketCallback failed", e)
        } catch (e: Exception) {
            XBoardLog.e(TAG, "enableProtection failed", e)
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
     * Uses the VPN service reference for protection.
     *
     * @param fd The raw file descriptor of the socket to protect.
     * @return true if protection succeeded, false otherwise.
     */
    fun protectSocket(fd: Int): Boolean {
        if (!protectionEnabled) {
            Log.w(TAG, "protectSocket called but protection not enabled")
            return false
        }
        return try {
            vpnService?.protect(fd) ?: run {
                Log.w(TAG, "protectSocket: vpnService is null")
                false
            }
        } catch (e: Exception) {
            XBoardLog.e(TAG, "protectSocket failed for fd=$fd", e)
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
    // through Dart FFI.

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

    /**
     * Start leaf with in-memory JSON config string. Blocks the calling thread.
     * Must be called on a background thread.
     */
    external fun leafRunWithOptionsConfigString(
        rtId: Int,
        config: String,
        multiThread: Boolean,
        autoThreads: Boolean,
        threads: Int,
        stackSize: Int,
    ): Int

    /** Reload config (DNS, outbounds, routing rules). */
    external fun leafReload(rtId: Int): Int

    /** Reload config directly from in-memory JSON string. */
    external fun leafReloadWithConfigString(rtId: Int, config: String): Int

    /** Graceful shutdown. */
    external fun leafShutdown(rtId: Int): Boolean

    /** Close all active TCP relay connections. */
    external fun leafCloseConnections(rtId: Int): Boolean

    /**
     * Set selected outbound for selector group.
     * Returns 0 on success.
     */
    external fun leafSetOutboundSelected(rtId: Int, outbound: String, select: String): Int

    /** Validate a config file. */
    external fun leafTestConfig(configPath: String): Int

    /** Validate an in-memory JSON config string. */
    external fun leafTestConfigString(config: String): Int

    /**
     * Health check one outbound and return [code, tcpMs, udpMs].
     *
     * code follows leaf-ffi error codes. tcpMs/udpMs are 0 when that protocol fails.
     */
    external fun leafHealthCheckWithLatency(
        rtId: Int,
        outboundTag: String,
        timeoutMs: Long,
    ): LongArray

    /**
     * Set process environment variable for leaf runtime.
     * Must be called before leaf starts in the current process.
     */
    external fun leafSetEnv(key: String, value: String)
}
