package com.follow.clash.service

import android.content.Context
import android.os.Binder
import android.os.Process
import com.follow.clash.common.XBoardLog
import com.follow.clash.core.ICoreService
import com.follow.clash.core.ICoreServiceCallback
import java.util.HashMap

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

    private fun enforceInternalCaller() {
        if (Binder.getCallingUid() != Process.myUid()) {
            throw SecurityException("Unauthorized caller uid=${Binder.getCallingUid()}")
        }
    }

    /**
     * Register callback for status changes.
     */
    override fun registerCallback(callback: ICoreServiceCallback?) {
        enforceInternalCaller()
        leafManager.registerCallback(callback)
    }

    override fun unregisterCallback(callback: ICoreServiceCallback?) {
        enforceInternalCaller()
        leafManager.unregisterCallback(callback)
    }

    override fun startLeaf(configJson: String): Boolean {
        enforceInternalCaller()
        XBoardLog.i(TAG, "startLeaf called")
        return leafManager.startLeaf(configJson)
    }

    override fun startLeafFromFile(configPath: String): Boolean {
        enforceInternalCaller()
        XBoardLog.i(TAG, "startLeafFromFile called: $configPath")
        return leafManager.startLeafFromFile(configPath)
    }

    override fun stopLeaf(): Boolean {
        enforceInternalCaller()
        XBoardLog.i(TAG, "stopLeaf called")
        return leafManager.stopLeaf()
    }

    override fun reloadLeaf(configJson: String): Boolean {
        enforceInternalCaller()
        XBoardLog.i(TAG, "reloadLeaf called")
        return leafManager.reloadLeaf(configJson)
    }

    override fun reloadLeafFromFile(configPath: String): Boolean {
        enforceInternalCaller()
        XBoardLog.i(TAG, "reloadLeafFromFile called: $configPath")
        return leafManager.reloadLeafFromFile(configPath)
    }

    override fun getStatus(): MutableMap<Any?, Any?> {
        enforceInternalCaller()
        val status = HashMap<Any?, Any?>()
        status.putAll(leafManager.getStatus())
        return status
    }

    override fun getSelectedNode(): String {
        enforceInternalCaller()
        return leafManager.getSelectedNode()
    }

    override fun selectNode(nodeTag: String): Boolean {
        enforceInternalCaller()
        XBoardLog.i(TAG, "selectNode: $nodeTag")
        return leafManager.selectNode(nodeTag)
    }

    override fun healthCheckNodes(
        nodeTags: MutableList<String>?,
        timeoutMs: Long,
    ): MutableMap<Any?, Any?> {
        enforceInternalCaller()
        val tags = nodeTags?.filter { it.isNotBlank() } ?: emptyList()
        val result = HashMap<Any?, Any?>()
        if (tags.isEmpty()) {
            return result
        }
        result.putAll(leafManager.healthCheckNodes(tags, timeoutMs))
        return result
    }

    override fun protectSocket(fd: Int): Boolean {
        enforceInternalCaller()
        return leafManager.protectSocket(fd)
    }

    override fun isTunReady(): Boolean {
        enforceInternalCaller()
        return leafManager.isTunReady()
    }

    override fun shutdown() {
        enforceInternalCaller()
        XBoardLog.i(TAG, "shutdown called")
        leafManager.shutdown()
    }
}
