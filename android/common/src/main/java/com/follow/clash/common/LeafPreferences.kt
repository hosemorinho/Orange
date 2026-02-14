package com.follow.clash.common

import android.content.Context
import android.content.SharedPreferences

/**
 * SharedPreferences wrapper for persisting leaf core state.
 * Used for auto-recovery after process restart.
 */
object LeafPreferences {
    private const val PREFS_NAME = "leaf_prefs"

    // Preference keys
    private const val KEY_SHOULD_RUN = "should_run"
    private const val KEY_SELECTED_NODE_TAG = "selected_node_tag"
    private const val KEY_MODE = "mode"
    private const val KEY_CONFIG_VERSION = "config_version"
    private const val KEY_LAST_START_TIME = "last_start_time"
    private const val KEY_CONFIG_JSON = "config_json"
    private const val KEY_VPN_OPTIONS_JSON = "vpn_options_json"

    @Volatile
    private var prefs: SharedPreferences? = null
    @Volatile
    private var appContext: Context? = null

    @Suppress("DEPRECATION")
    private fun prefsMode(): Int {
        // MODE_MULTI_PROCESS is deprecated, but it still improves cross-process
        // refresh behavior for SharedPreferences-backed state in dual-process mode.
        return Context.MODE_PRIVATE or Context.MODE_MULTI_PROCESS
    }

    /**
     * Initialize LeafPreferences. Must be called once at app startup.
     */
    fun init(context: Context) {
        appContext = context.applicationContext
        prefs = appContext?.getSharedPreferences(PREFS_NAME, prefsMode())
    }

    /**
     * Initialize with an existing SharedPreferences instance.
     * Useful for passing prefs between processes.
     */
    fun init(preferences: SharedPreferences) {
        prefs = preferences
    }

    /**
     * Check if LeafPreferences has been initialized.
     * @return true if initialized, false otherwise
     */
    fun initGuard(): Boolean {
        return prefs != null
    }

    private fun getPrefs(): SharedPreferences {
        appContext?.let { ctx ->
            prefs = ctx.getSharedPreferences(PREFS_NAME, prefsMode())
        }
        return prefs ?: throw IllegalStateException(
            "LeafPreferences not initialized. Call init(context) first."
        )
    }

    /**
     * Whether the core should be running.
     * Set to true when user explicitly starts, false when explicitly stops.
     */
    var shouldRun: Boolean
        get() = getPrefs().getBoolean(KEY_SHOULD_RUN, false)
        set(value) {
            getPrefs().edit().putBoolean(KEY_SHOULD_RUN, value).commit()
        }

    /**
     * The currently selected node tag.
     */
    var selectedNodeTag: String
        get() = getPrefs().getString(KEY_SELECTED_NODE_TAG, "") ?: ""
        set(value) {
            getPrefs().edit().putString(KEY_SELECTED_NODE_TAG, value).commit()
        }

    /**
     * The current mode: "rule", "global", or "direct".
     */
    var mode: String
        get() = getPrefs().getString(KEY_MODE, "rule") ?: "rule"
        set(value) {
            getPrefs().edit().putString(KEY_MODE, value).commit()
        }

    /**
     * Configuration version for tracking updates.
     */
    var configVersion: Long
        get() = getPrefs().getLong(KEY_CONFIG_VERSION, 0)
        set(value) {
            getPrefs().edit().putLong(KEY_CONFIG_VERSION, value).commit()
        }

    /**
     * Last timestamp when the core was started.
     */
    var lastStartTime: Long
        get() = getPrefs().getLong(KEY_LAST_START_TIME, 0)
        set(value) {
            getPrefs().edit().putLong(KEY_LAST_START_TIME, value).commit()
        }

    /**
     * The cached config JSON for recovery.
     */
    var configJson: String
        get() = getPrefs().getString(KEY_CONFIG_JSON, "") ?: ""
        set(value) {
            getPrefs().edit().putString(KEY_CONFIG_JSON, value).commit()
        }

    /**
     * Cached VPN options JSON for process/boot recovery.
     */
    var vpnOptionsJson: String
        get() = getPrefs().getString(KEY_VPN_OPTIONS_JSON, "") ?: ""
        set(value) {
            getPrefs().edit().putString(KEY_VPN_OPTIONS_JSON, value).commit()
        }

    /**
     * Clear all persisted state.
     */
    fun clear() {
        getPrefs().edit().clear().commit()
    }

    /**
     * Save all state at once.
     */
    fun saveAll(
        shouldRun: Boolean,
        selectedNodeTag: String,
        mode: String,
        configVersion: Long,
        lastStartTime: Long,
        configJson: String
    ) {
        getPrefs().edit().apply {
            putBoolean(KEY_SHOULD_RUN, shouldRun)
            putString(KEY_SELECTED_NODE_TAG, selectedNodeTag)
            putString(KEY_MODE, mode)
            putLong(KEY_CONFIG_VERSION, configVersion)
            putLong(KEY_LAST_START_TIME, lastStartTime)
            putString(KEY_CONFIG_JSON, configJson)
            commit()
        }
    }
}
