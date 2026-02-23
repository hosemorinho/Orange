package com.follow.clash

import android.net.VpnService
import android.util.Base64
import com.follow.clash.common.GlobalState
import com.follow.clash.models.SetupParams
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.models.NotificationParams
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import java.security.MessageDigest
import java.util.UUID
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.math.min

enum class RunState {
    START, PENDING, STOP
}

private const val CONFIG_CHUNK_SIZE = 48 * 1024
private const val ACTION_TIMEOUT_MS = 30_000L


object State {

    val runLock = Mutex()

    var runTime: Long = 0

    var sharedState: SharedState = SharedState()

    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)

    var flutterEngine: FlutterEngine? = null

    val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>()

    val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>()

    suspend fun handleToggleAction() {
        var action: (suspend () -> Unit)?
        runLock.withLock {
            action = when (runStateFlow.value) {
                RunState.PENDING -> null
                RunState.START -> ::handleStopServiceAction
                RunState.STOP -> ::handleStartServiceAction
            }
        }
        action?.invoke()
    }

    suspend fun handleSyncState() {
        runLock.withLock {
            try {
                Service.bind()
                runTime = Service.getRunTime()
                val runState = when (runTime == 0L) {
                    true -> RunState.STOP
                    false -> RunState.START
                }
                runStateFlow.tryEmit(runState)
            } catch (_: Exception) {
                runStateFlow.tryEmit(RunState.STOP)
            }
        }
    }

    suspend fun handleStartServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.STOP) {
                return
            }
            tilePlugin?.handleStart()
            if (flutterEngine != null) {
                return
            }
            startServiceWithPref()
        }

    }

    suspend fun handleStopServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.START) {
                return
            }
            tilePlugin?.handleStop()
            if (flutterEngine != null) {
                return
            }
            if (GlobalState.isInitialized) {
                GlobalState.application.showToast(sharedState.stopTip)
            }
            handleStopService()
        }
    }

    fun handleStartService() {
        val appPlugin = flutterEngine?.plugin<AppPlugin>()
        if (appPlugin != null) {
            appPlugin.requestNotificationsPermission {
                startService()
            }
            return
        }
        startService()
    }

    private fun startServiceWithPref() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                if (!GlobalState.isInitialized) {
                    GlobalState.log("startServiceWithPref: application not initialized yet")
                    return@launch
                }
                sharedState = GlobalState.application.sharedState
                setupAndStart()
            }
        }
    }

    suspend fun syncState() {
        Service.updateNotificationParams(
            NotificationParams(
                title = sharedState.currentProfileName,
                stopText = sharedState.stopText,
                onlyStatisticsProxy = sharedState.onlyStatisticsProxy
            )
        )
    }

    private suspend fun setupAndStart() {
        Service.bind()
        syncState()
        GlobalState.application.showToast(sharedState.startTip)
        val initParams = mutableMapOf<String, Any>()
        initParams["home-dir"] = GlobalState.application.filesDir.path
        initParams["version"] = android.os.Build.VERSION.SDK_INT
        val initParamsString = Gson().toJson(initParams)
        val setupParams = try {
            attachSessionConfig(sharedState.setupParams)
        } catch (e: Exception) {
            val message = e.message ?: "quickSetup v2 failed"
            GlobalState.log(message)
            GlobalState.application.showToast(message)
            return
        }
        val setupParamsString = Gson().toJson(setupParams)
        Service.quickSetup(
            initParamsString,
            setupParamsString,
            onStarted = {
                startService()
            },
            onResult = {
                if (it.isNotEmpty()) {
                    GlobalState.application.showToast(it)
                }
            },
        )
    }

    private suspend fun attachSessionConfig(setupParams: SetupParams?): SetupParams {
        if (setupParams == null) {
            throw IllegalStateException("quickSetup v2: setup params missing; plaintext fallback is disabled")
        }
        val configBytes = QuickSetupConfigStore.readDecrypted()
        if (configBytes == null || configBytes.isEmpty()) {
            throw IllegalStateException("quickSetup v2: sealed config snapshot missing; plaintext fallback is disabled")
        }
        val sessionId = uploadConfigToSession(configBytes)
        if (sessionId.isNullOrEmpty()) {
            throw IllegalStateException("quickSetup v2: session upload failed; plaintext fallback is disabled")
        }
        GlobalState.log("quickSetup v2: using config session $sessionId")
        return setupParams.copy(configSessionId = sessionId)
    }

    private suspend fun uploadConfigToSession(configBytes: ByteArray): String? {
        val beginRes = invokeCoreAction("beginConfigSession", null) ?: return null
        val sessionId = beginRes.get("data")?.takeIf { it.isJsonPrimitive }?.asString
        if (sessionId.isNullOrEmpty()) {
            GlobalState.log("quickSetup v2: beginConfigSession returned empty session id")
            return null
        }

        var index = 0
        var offset = 0
        while (offset < configBytes.size) {
            val end = min(offset + CONFIG_CHUNK_SIZE, configBytes.size)
            val chunk = configBytes.copyOfRange(offset, end)
            val chunkBase64 = Base64.encodeToString(chunk, Base64.NO_WRAP)
            val appendOk = invokeCoreAction(
                "appendConfigChunk",
                mapOf("session-id" to sessionId, "chunk" to chunkBase64, "index" to index),
            ) != null
            if (!appendOk) {
                GlobalState.log("quickSetup v2: appendConfigChunk failed at index=$index")
                return null
            }
            index += 1
            offset = end
        }

        val sha256 = sha256Hex(configBytes)
        val commitOk = invokeCoreAction(
            "commitConfigSession",
            mapOf("session-id" to sessionId, "sha256" to sha256),
        ) != null
        if (!commitOk) {
            GlobalState.log("quickSetup v2: commitConfigSession failed")
            return null
        }
        return sessionId
    }

    private fun sha256Hex(input: ByteArray): String {
        return MessageDigest.getInstance("SHA-256")
            .digest(input)
            .joinToString("") { byte -> "%02x".format(byte) }
    }

    private suspend fun invokeCoreAction(method: String, data: Any?): JsonObject? {
        val action = mapOf(
            "id" to "${method}#${UUID.randomUUID()}",
            "method" to method,
            "data" to data,
        )
        val payload = Gson().toJson(action)
        val result = withTimeoutOrNull(ACTION_TIMEOUT_MS) {
            suspendCancellableCoroutine<String?> { cont ->
                GlobalState.launch {
                    try {
                        val serviceResult = Service.invokeAction(payload) { callbackResult ->
                            if (cont.isActive) {
                                cont.resume(callbackResult)
                            }
                        }
                        if (serviceResult.isFailure && cont.isActive) {
                            cont.resumeWithException(
                                serviceResult.exceptionOrNull()
                                    ?: IllegalStateException("invokeAction failed: $method")
                            )
                        }
                    } catch (e: Exception) {
                        if (cont.isActive) {
                            cont.resumeWithException(e)
                        }
                    }
                }
            }
        } ?: run {
            GlobalState.log("quickSetup v2: invokeAction timeout method=$method")
            return null
        }

        if (result.isNullOrEmpty()) {
            GlobalState.log("quickSetup v2: empty action result method=$method")
            return null
        }

        return try {
            val json = JsonParser.parseString(result).asJsonObject
            val code = json.get("code")?.asInt ?: -1
            if (code != 0) {
                val errorText = json.get("data")?.toString()
                GlobalState.log("quickSetup v2: action failed method=$method error=$errorText")
                null
            } else {
                json
            }
        } catch (e: Exception) {
            GlobalState.log("quickSetup v2: parse action result failed method=$method error=${e.message}")
            null
        }
    }

    private fun startService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                try {
                    runStateFlow.tryEmit(RunState.PENDING)
                    val options = sharedState.vpnOptions ?: return@launch
                    appPlugin?.let {
                        it.prepare(options.enable) {
                            runTime = Service.startService(options, runTime)
                            runStateFlow.tryEmit(RunState.START)
                        }
                    } ?: run {
                        val intent = VpnService.prepare(GlobalState.application)
                        if (intent != null) {
                            return@launch
                        }
                        runTime = Service.startService(options, runTime)
                        runStateFlow.tryEmit(RunState.START)
                    }
                } finally {
                    if (runStateFlow.value == RunState.PENDING) {
                        runStateFlow.tryEmit(RunState.STOP)
                    }
                }
            }
        }
    }

    fun handleStopService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.START) {
                    return@launch
                }
                try {
                    runStateFlow.tryEmit(RunState.PENDING)
                    runTime = Service.stopService()
                    runStateFlow.tryEmit(RunState.STOP)
                } finally {
                    if (runStateFlow.value == RunState.PENDING) {
                        runStateFlow.tryEmit(RunState.START)
                    }
                }
            }
        }
    }
}
