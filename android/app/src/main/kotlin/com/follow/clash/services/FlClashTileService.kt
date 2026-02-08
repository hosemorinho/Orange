package com.follow.clash.services

import android.annotation.SuppressLint
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import com.follow.clash.GlobalState
import com.follow.clash.RunState
import com.follow.clash.extensions.QuickAction
import com.follow.clash.extensions.getActionIntent
import com.follow.clash.extensions.getActionPendingIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class FlClashTileService : TileService() {
    private var scope: CoroutineScope? = null

    private fun updateTile(runState: RunState) {
        if (qsTile != null) {
            qsTile.state = when (runState) {
                RunState.START -> Tile.STATE_ACTIVE
                RunState.PENDING -> Tile.STATE_UNAVAILABLE
                RunState.STOP -> Tile.STATE_INACTIVE
            }
            qsTile.updateTile()
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        scope?.cancel()
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        scope?.launch {
            GlobalState.runStateFlow.collect {
                updateTile(it)
            }
        }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun handleToggle() {
        val applicationId = applicationContext.packageName
        val intent = getActionIntent(applicationId, QuickAction.TOGGLE)
        val pendingIntent = getActionPendingIntent(applicationId, QuickAction.TOGGLE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(pendingIntent)
        } else {
            @Suppress("DEPRECATION") startActivityAndCollapse(intent)
        }
    }

    override fun onClick() {
        super.onClick()
        handleToggle()
    }

    override fun onStopListening() {
        scope?.cancel()
        super.onStopListening()
    }
}
