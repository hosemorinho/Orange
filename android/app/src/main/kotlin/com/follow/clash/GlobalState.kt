package com.follow.clash

import android.util.Log
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.plugins.VpnPlugin
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

enum class RunState {
    START, PENDING, STOP
}

object GlobalState : CoroutineScope by CoroutineScope(Dispatchers.Default) {
    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)
    val runLock = Mutex()

    var flutterEngine: FlutterEngine? = null

    fun log(text: String) {
        Log.d("[FlClash]", text)
    }

    fun getCurrentAppPlugin(): AppPlugin? {
        return flutterEngine?.plugin<AppPlugin>()
    }

    fun getCurrentVPNPlugin(): VpnPlugin? {
        return flutterEngine?.plugin<VpnPlugin>()
    }

    fun getCurrentTilePlugin(): TilePlugin? {
        return flutterEngine?.plugin<TilePlugin>()
    }

    fun handleToggle() {
        launch {
            var action: (suspend () -> Unit)?
            runLock.withLock {
                action = when (runStateFlow.value) {
                    RunState.PENDING -> null
                    RunState.START -> ::handleStop
                    RunState.STOP -> ::handleStart
                }
            }
            action?.invoke()
        }
    }

    suspend fun handleStart() {
        getCurrentTilePlugin()?.handleStart()
    }

    suspend fun handleStop() {
        getCurrentTilePlugin()?.handleStop()
    }
}
