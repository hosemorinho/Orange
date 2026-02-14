package com.follow.clash.service

import android.content.Context
import android.os.IBinder
import com.follow.clash.common.XBoardLog
import com.follow.clash.core.ICoreService
import com.follow.clash.core.ICoreServiceCallback

/**
 * AIDL service implementation running in :core process.
 * Provides IPC interface for controlling leaf from the UI process.
 */
class CoreService : ICoreService.Stub() {

    private val TAG = "CoreService"
    private lateinit var leafManager: LeafProcessManager

    /**
     * Initialize the service with application context.
     */
    fun init(context: Context) {
        leafManager = LeafProcessManager.getInstance(context)
    }

    /**
     * Register callback for status changes.
     */
    fun registerCallback(callback: ICoreServiceCallback?) {
        leafManager.setCallback(callback)
    }

    override fun startLeaf(configJson: String): Boolean {
        XBoardLog.i(TAG, "startLeaf called")
        return leafManager.startLeaf(configJson)
    }

    override fun stopLeaf(): Boolean {
        XBoardLog.i(TAG, "stopLeaf called")
        return leafManager.stopLeaf()
    }

    override fun reloadLeaf(configJson: String): Boolean {
        XBoardLog.i(TAG, "reloadLeaf called")
        return leafManager.reloadLeaf(configJson)
    }

    override fun getStatus(): java.util.Map<String, Any> {
        return leafManager.getStatus()
    }

    override fun getSelectedNode(): String {
        return leafManager.getSelectedNode()
    }

    override fun selectNode(nodeTag: String): Boolean {
        XBoardLog.i(TAG, "selectNode: $nodeTag")
        return leafManager.selectNode(nodeTag)
    }

    override fun protectSocket(fd: Int): Boolean {
        return leafManager.protectSocket(fd)
    }

    override fun isTunReady(): Boolean {
        return leafManager.isTunReady()
    }

    override fun shutdown() {
        XBoardLog.i(TAG, "shutdown called")
        leafManager.shutdown()
    }
}
