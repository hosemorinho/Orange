package com.follow.clash

import android.app.Activity
import android.os.Bundle
import com.follow.clash.extensions.QuickAction
import com.follow.clash.extensions.wrapAction

class TempActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val action = wrapAction(applicationContext.packageName, intent.action)
        when (action) {
            QuickAction.START -> GlobalState.handleToggle()
            QuickAction.STOP -> GlobalState.handleToggle()
            QuickAction.TOGGLE -> GlobalState.handleToggle()
            null -> {}
        }
        finish()
    }
}
