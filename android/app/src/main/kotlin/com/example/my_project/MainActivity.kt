package com.decoywalletapp.app

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val contactPickerChannelName = "decoy_wallet/contact_picker"
    private val pickContactRequestCode = 7301
    private var pendingContactResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            contactPickerChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickContact" -> pickContact(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun pickContact(result: MethodChannel.Result) {
        if (pendingContactResult != null) {
            result.error(
                "CONTACT_PICKER_BUSY",
                "Contact picker is already open.",
                null
            )
            return
        }

        val intent = Intent(
            Intent.ACTION_PICK,
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        )
        pendingContactResult = result

        try {
            startActivityForResult(intent, pickContactRequestCode)
        } catch (error: Exception) {
            pendingContactResult = null
            result.error(
                "CONTACT_PICKER_UNAVAILABLE",
                "Could not open contacts.",
                error.localizedMessage
            )
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pickContactRequestCode) {
            val result = pendingContactResult
            pendingContactResult = null

            if (result == null) {
                return
            }

            if (resultCode != Activity.RESULT_OK) {
                result.success(null)
                return
            }

            try {
                result.success(readSelectedContact(data))
            } catch (error: Exception) {
                result.error(
                    "CONTACT_READ_FAILED",
                    "Could not read selected contact.",
                    error.localizedMessage
                )
            }
            return
        }

        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun readSelectedContact(data: Intent?): Map<String, String>? {
        val contactUri = data?.data ?: return null
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )

        contentResolver.query(contactUri, projection, null, null, null)?.use { cursor ->
            if (!cursor.moveToFirst()) {
                return null
            }

            val displayName =
                cursor.getStringOrEmpty(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val phoneNumber =
                cursor.getStringOrEmpty(ContactsContract.CommonDataKinds.Phone.NUMBER)
            val (firstName, lastName) = splitDisplayName(displayName)

            return mapOf(
                "firstName" to firstName,
                "lastName" to lastName,
                "phoneNumber" to phoneNumber
            )
        }

        return null
    }

    private fun Cursor.getStringOrEmpty(columnName: String): String {
        val index = getColumnIndex(columnName)
        if (index < 0 || isNull(index)) {
            return ""
        }
        return getString(index)?.trim().orEmpty()
    }

    private fun splitDisplayName(displayName: String): Pair<String, String> {
        val parts = displayName.trim()
            .split(Regex("\\s+"))
            .filter { it.isNotBlank() }

        if (parts.isEmpty()) {
            return "" to ""
        }

        if (parts.size == 1) {
            return parts[0] to ""
        }

        return parts.first() to parts.drop(1).joinToString(" ")
    }
}
