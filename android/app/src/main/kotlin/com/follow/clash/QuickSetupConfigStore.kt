package com.follow.clash

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import com.follow.clash.common.GlobalState
import java.io.File
import java.nio.ByteBuffer
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

private const val QUICK_SETUP_FILE_NAME = "quick_setup_config.sealed"
private const val QUICK_SETUP_KEY_ALIAS = "orange.quick_setup.config.v1"
private const val QUICK_SETUP_MAGIC = "ORANGEQ2"
private const val QUICK_SETUP_VERSION: Byte = 1
private const val GCM_TAG_BITS = 128
private const val MIN_HEADER_SIZE = 8 + 1 + 1 + 4

object QuickSetupConfigStore {
    private val magicBytes = QUICK_SETUP_MAGIC.toByteArray(Charsets.US_ASCII)

    fun persist(configBytes: ByteArray): Result<Unit> = runCatching {
        val key = getOrCreateSecretKey()
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val iv = cipher.iv
        val encrypted = cipher.doFinal(configBytes)
        val header = ByteBuffer.allocate(magicBytes.size + 1 + 1 + 4)
            .put(magicBytes)
            .put(QUICK_SETUP_VERSION)
            .put(iv.size.toByte())
            .putInt(encrypted.size)
            .array()
        val payload = ByteArray(header.size + iv.size + encrypted.size)
        System.arraycopy(header, 0, payload, 0, header.size)
        System.arraycopy(iv, 0, payload, header.size, iv.size)
        System.arraycopy(encrypted, 0, payload, header.size + iv.size, encrypted.size)

        val target = snapshotFile()
        val temp = File(target.parentFile, "${target.name}.tmp")
        temp.writeBytes(payload)
        if (!temp.renameTo(target)) {
            target.writeBytes(payload)
            temp.delete()
        }
    }

    fun readDecrypted(): ByteArray? {
        val target = snapshotFile()
        if (!target.exists()) {
            return null
        }
        return runCatching {
            val bytes = target.readBytes()
            if (bytes.size < MIN_HEADER_SIZE) {
                return null
            }
            val header = ByteBuffer.wrap(bytes)
            val magic = ByteArray(magicBytes.size)
            header.get(magic)
            if (!magic.contentEquals(magicBytes)) {
                return null
            }
            val version = header.get()
            if (version != QUICK_SETUP_VERSION) {
                return null
            }
            val ivLen = header.get().toInt() and 0xFF
            if (ivLen <= 0) {
                return null
            }
            val encryptedLen = header.int
            if (encryptedLen <= 0) {
                return null
            }
            val expectedSize = magicBytes.size + 1 + 1 + 4 + ivLen + encryptedLen
            if (expectedSize != bytes.size) {
                return null
            }
            val iv = ByteArray(ivLen)
            header.get(iv)
            val encrypted = ByteArray(encryptedLen)
            header.get(encrypted)

            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(
                Cipher.DECRYPT_MODE,
                getOrCreateSecretKey(),
                GCMParameterSpec(GCM_TAG_BITS, iv),
            )
            cipher.doFinal(encrypted)
        }.getOrNull()
    }

    fun clear(): Result<Unit> = runCatching {
        snapshotFile().delete()
    }

    private fun snapshotFile(): File {
        return File(GlobalState.application.filesDir, QUICK_SETUP_FILE_NAME)
    }

    private fun getOrCreateSecretKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply {
            load(null)
        }
        val existing = keyStore.getKey(QUICK_SETUP_KEY_ALIAS, null)
        if (existing is SecretKey) {
            return existing
        }
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore",
        )
        val spec = KeyGenParameterSpec.Builder(
            QUICK_SETUP_KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .build()
        generator.init(spec)
        return generator.generateKey()
    }
}
