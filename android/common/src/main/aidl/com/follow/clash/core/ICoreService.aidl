// ICoreService.aidl
package com.follow.clash.core;

/**
 * AIDL interface for communication between UI process and :core process.
 * Used to control the leaf proxy core running in the separate :core process.
 *
 * In this architecture:
 * - VpnService runs in :core process and creates TUN
 * - Leaf runs in :core process and uses local tunPfd directly
 * - Flutter sends config via AIDL, no need to pass TUN fd
 */
interface ICoreService {

    /**
     * Start leaf with the given config JSON.
     * Leaf will use the local tunPfd from VpnService (same process).
     * @param configJson The Clash/YAML config as JSON string
     * @return true if started successfully, false otherwise
     */
    boolean startLeaf(String configJson);

    /**
     * Stop the running leaf instance.
     * @return true if stopped successfully, false otherwise
     */
    boolean stopLeaf();

    /**
     * Reload leaf with new config (hot reload without restart).
     * @param configJson The new config as JSON string
     * @return true if reloaded successfully, false otherwise
     */
    boolean reloadLeaf(String configJson);

    /**
     * Get current core status.
     * @return Map containing: isRunning (boolean), mode (String), selectedNode (String)
     */
    Map getStatus();

    /**
     * Get the currently selected node tag.
     * @return The node tag or empty string if none selected
     */
    String getSelectedNode();

    /**
     * Select a new node by tag.
     * @param nodeTag The node tag to select
     * @return true if selected successfully, false otherwise
     */
    boolean selectNode(String nodeTag);

    /**
     * Protect a socket from VPN routing.
     * Called from UI process when leaf needs socket protection.
     * @param fd The file descriptor of the socket to protect
     * @return true if protected successfully, false otherwise
     */
    boolean protectSocket(int fd);

    /**
     * Check if VPN/TUN is ready in :core process.
     * @return true if tunPfd is available
     */
    boolean isTunReady();

    /**
     * Request the core process to exit.
     */
    void shutdown();
}
