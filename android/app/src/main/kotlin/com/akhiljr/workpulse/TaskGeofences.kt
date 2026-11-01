package com.akhiljr.workpulse

import android.Manifest
import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingEvent
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import org.json.JSONArray
import org.json.JSONObject

private const val TAG = "TaskGeofences"
private const val PREFS = "task_geofences"
private const val KEY_TASKS = "tasks"
private const val KEY_REGISTERED = "registered"
private const val CHANNEL_ID = "task_location"

// Kept clear of the break-alarm and date-alert id ranges used from Dart.
private const val NOTIFICATION_ID_BASE = 1_500_000_000

// Larger values let Android batch checks, which uses less battery.
private const val RESPONSIVENESS_MS = 60_000

/**
 * Registers task geofences with Google Play services. The list is kept here as
 * well as in the app's database because Android forgets geofences on reboot,
 * and alerts must work without starting Flutter.
 */
object TaskGeofences {
    const val RESULT_OK = "ok"
    const val RESULT_NO_PERMISSION = "noPermission"
    const val RESULT_UNAVAILABLE = "unavailable"

    /**
     * Registers the list unless Android already has exactly this list.
     * Registering resets whether Android considers the device inside an area,
     * so doing it on every app open would lose an alert still on its way.
     */
    fun sync(context: Context, tasksJson: String, onDone: (String) -> Unit) {
        val prefs = prefs(context)
        val alreadyRegistered = prefs.getBoolean(KEY_REGISTERED, false) &&
            prefs.getString(KEY_TASKS, null) == tasksJson
        if (alreadyRegistered && hasPermissions(context)) {
            onDone(RESULT_OK)
            return
        }
        prefs.edit().putString(KEY_TASKS, tasksJson).apply()
        register(context, onDone)
    }

    /** Android dropped the geofences, so the next [sync] must add them again. */
    fun markUnregistered(context: Context) {
        setRegistered(context, false)
    }

    /** Replaces everything registered with the saved list. */
    @SuppressLint("MissingPermission")
    fun register(context: Context, onDone: (String) -> Unit) {
        setRegistered(context, false)
        val client = LocationServices.getGeofencingClient(context)
        val pendingIntent = pendingIntent(context)
        val geofences = load(context).let { tasks ->
            (0 until tasks.length()).map { index -> toGeofence(tasks.getJSONObject(index)) }
        }
        client.removeGeofences(pendingIntent).addOnCompleteListener {
            if (geofences.isEmpty()) {
                setRegistered(context, true)
                onDone(RESULT_OK)
                return@addOnCompleteListener
            }
            if (!hasPermissions(context)) {
                onDone(RESULT_NO_PERMISSION)
                return@addOnCompleteListener
            }
            val request = GeofencingRequest.Builder()
                // 0, not INITIAL_TRIGGER_ENTER: registering again after an edit or
                // reboot must not re-alert someone already inside.
                .setInitialTrigger(0)
                .addGeofences(geofences)
                .build()
            client.addGeofences(request, pendingIntent)
                .addOnSuccessListener {
                    Log.i(TAG, "Registered ${geofences.size} geofences")
                    setRegistered(context, true)
                    onDone(RESULT_OK)
                }
                .addOnFailureListener { error ->
                    Log.w(TAG, "Could not register geofences", error)
                    onDone(RESULT_UNAVAILABLE)
                }
        }
    }

    fun find(context: Context, taskId: String): JSONObject? {
        val tasks = load(context)
        return (0 until tasks.length())
            .map { tasks.getJSONObject(it) }
            .firstOrNull { it.getInt("id").toString() == taskId }
    }

    private fun toGeofence(task: JSONObject): Geofence = Geofence.Builder()
        .setRequestId(task.getInt("id").toString())
        .setCircularRegion(
            task.getDouble("latitude"),
            task.getDouble("longitude"),
            task.getInt("radiusMeters").toFloat(),
        )
        .setExpirationDuration(Geofence.NEVER_EXPIRE)
        .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER)
        .setNotificationResponsiveness(RESPONSIVENESS_MS)
        .build()

    private fun hasPermissions(context: Context): Boolean {
        val fine = granted(context, Manifest.permission.ACCESS_FINE_LOCATION)
        val background = Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            granted(context, Manifest.permission.ACCESS_BACKGROUND_LOCATION)
        return fine && background
    }

    private fun granted(context: Context, permission: String) =
        ContextCompat.checkSelfPermission(context, permission) ==
            PackageManager.PERMISSION_GRANTED

    private fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, GeofenceReceiver::class.java)
        // Must be mutable: Play services adds the event details to it.
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )
    }

    private fun setRegistered(context: Context, registered: Boolean) {
        prefs(context).edit().putBoolean(KEY_REGISTERED, registered).apply()
    }

    private fun load(context: Context) =
        JSONArray(prefs(context).getString(KEY_TASKS, "[]"))

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}

/** Raises the alert when the device enters a task's area. */
class GeofenceReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val event = GeofencingEvent.fromIntent(intent) ?: return
        if (event.hasError()) {
            val reason = GeofenceStatusCodes.getStatusCodeString(event.errorCode)
            Log.w(TAG, "Geofence event error: $reason")
            // Sent when Location is turned off, which removes every geofence.
            if (event.errorCode == GeofenceStatusCodes.GEOFENCE_NOT_AVAILABLE) {
                TaskGeofences.markUnregistered(context)
            }
            return
        }
        Log.i(TAG, "Geofence event: transition ${event.geofenceTransition}")
        if (event.geofenceTransition != Geofence.GEOFENCE_TRANSITION_ENTER) return
        event.triggeringGeofences?.forEach { geofence ->
            TaskGeofences.find(context, geofence.requestId)?.let { notify(context, it) }
        }
    }

    @SuppressLint("MissingPermission")
    private fun notify(context: Context, task: JSONObject) {
        ensureChannel(context)
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val content = PendingIntent.getActivity(
            context,
            task.getInt("id"),
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(task.getString("title"))
            .setContentText(task.getString("message"))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(content)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(context)
            .notify(NOTIFICATION_ID_BASE + task.getInt("id"), notification)
    }

    private fun ensureChannel(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Task locations",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply { description = "Alerts when you arrive at a task's location." },
        )
    }
}

/** Android forgets geofences on reboot and app update, so register them again. */
class GeofenceBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        TaskGeofences.register(context) { pending.finish() }
    }
}
