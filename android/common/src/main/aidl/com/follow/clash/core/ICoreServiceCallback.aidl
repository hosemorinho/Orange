// ICoreServiceCallback.aidl
package com.follow.clash.core;

/**
 * AIDL callback interface for receiving events from the :core process.
 */
interface ICoreServiceCallback {

    /**
     * Called when core status changes.
     * @param isRunning Whether leaf is currently running
     * @param mode The current mode (rule/global/direct)
     * @param selectedNode The currently selected node tag
     */
    void onStatusChanged(boolean isRunning, String mode, String selectedNode);

    /**
     * Called when leaf encounters an error.
     * @param error The error message
     */
    void onError(String error);

    /**
     * Called when core process crashes.
     * @param message The crash message
     */
    void onCrash(String message);
}
