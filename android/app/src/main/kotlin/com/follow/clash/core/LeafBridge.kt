package com.follow.clash.core

/**
 * JNI bridge to libleaf.so (Rust proxy core).
 *
 * This file provides backward compatibility for the UI process.
 * In the dual-process architecture:
 * - The actual LeafBridge implementation is in the common module
 * - This file re-exports the common module's LeafBridge for UI process usage
 * - Socket protection in UI process uses AIDL to communicate with :core process
 *
 * Note: libleaf.so is loaded in Application.attachBaseContext() BEFORE the Dart
 * engine starts. This avoids the native crash caused by Dart FFI's dlopen() and
 * System.loadLibrary() fighting over the same .so.
 */

// Re-export from common module for backward compatibility
typealias LeafBridge = com.follow.clash.common.LeafBridge
