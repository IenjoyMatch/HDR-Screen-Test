package com.xinxin.flutter_miuix

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Bundle
import android.view.HapticFeedbackConstants
import android.view.RoundedCorner
import android.view.View
import android.view.WindowInsets
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

/** Native Android bridge for the MIUIX haptic roles used by the Dart widgets. */
class FlutterMiuixPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodChannel.MethodCallHandler,
    Application.ActivityLifecycleCallbacks {
    private lateinit var hapticChannel: MethodChannel
    private lateinit var accessibilityChannel: MethodChannel
    private lateinit var platformChannel: MethodChannel
    private lateinit var tiltChannel: EventChannel
    private lateinit var windowInsetsChannel: EventChannel
    private var tiltStreamHandler: TiltStreamHandler? = null
    private var windowInsetsStreamHandler: WindowInsetsStreamHandler? = null
    private var applicationContext: Context? = null
    private var activity: Activity? = null
    private var lifecycleApplication: Application? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        hapticChannel = MethodChannel(binding.binaryMessenger, HAPTIC_CHANNEL)
        accessibilityChannel = MethodChannel(binding.binaryMessenger, ACCESSIBILITY_CHANNEL)
        platformChannel = MethodChannel(binding.binaryMessenger, PLATFORM_CHANNEL)
        tiltChannel = EventChannel(binding.binaryMessenger, TILT_CHANNEL)
        windowInsetsChannel = EventChannel(binding.binaryMessenger, WINDOW_INSETS_CHANNEL)
        tiltStreamHandler = TiltStreamHandler(binding.applicationContext).also {
            tiltChannel.setStreamHandler(it)
        }
        windowInsetsStreamHandler = WindowInsetsStreamHandler().also {
            windowInsetsChannel.setStreamHandler(it)
        }
        hapticChannel.setMethodCallHandler(this)
        accessibilityChannel.setMethodCallHandler(this)
        platformChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        hapticChannel.setMethodCallHandler(null)
        accessibilityChannel.setMethodCallHandler(null)
        platformChannel.setMethodCallHandler(null)
        tiltChannel.setStreamHandler(null)
        windowInsetsChannel.setStreamHandler(null)
        tiltStreamHandler?.dispose()
        tiltStreamHandler = null
        windowInsetsStreamHandler?.dispose()
        windowInsetsStreamHandler = null
        detachActivityLifecycle()
        applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        windowInsetsStreamHandler?.setActivity(binding.activity)
        attachActivityLifecycle(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        tiltStreamHandler?.setHostResumed(false)
        detachActivityLifecycle()
        windowInsetsStreamHandler?.setActivity(null)
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        windowInsetsStreamHandler?.setActivity(binding.activity)
        attachActivityLifecycle(binding.activity)
    }

    override fun onDetachedFromActivity() {
        tiltStreamHandler?.setHostResumed(false)
        detachActivityLifecycle()
        windowInsetsStreamHandler?.setActivity(null)
        activity = null
    }

    override fun onActivityResumed(resumedActivity: Activity) {
        if (resumedActivity === activity) tiltStreamHandler?.setHostResumed(true)
    }

    override fun onActivityPaused(pausedActivity: Activity) {
        if (pausedActivity === activity) tiltStreamHandler?.setHostResumed(false)
    }

    override fun onActivityDestroyed(destroyedActivity: Activity) {
        if (destroyedActivity === activity) tiltStreamHandler?.setHostResumed(false)
    }

    override fun onActivityCreated(activity: Activity, state: Bundle?) = Unit

    override fun onActivityStarted(activity: Activity) = Unit

    override fun onActivityStopped(activity: Activity) = Unit

    override fun onActivitySaveInstanceState(activity: Activity, state: Bundle) = Unit

    /** Observes host pause/resume so the sensor follows the source lifecycle. */
    private fun attachActivityLifecycle(host: Activity) {
        detachActivityLifecycle()
        host.application.registerActivityLifecycleCallbacks(this)
        lifecycleApplication = host.application
    }

    private fun detachActivityLifecycle() {
        lifecycleApplication?.unregisterActivityLifecycleCallbacks(this)
        lifecycleApplication = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "performHapticFeedback" -> performHapticFeedback(call, result)
            "recommendedTimeoutMillis" -> recommendedTimeoutMillis(call, result)
            "sdkInt" -> result.success(Build.VERSION.SDK_INT)
            "screenCornerRadius" -> result.success(readScreenCornerRadiusDp())
            else -> result.notImplemented()
        }
    }

    /** Returns the physical display corner used by current NavDisplay effects. */
    @SuppressLint("DiscouragedApi")
    private fun readScreenCornerRadiusDp(): Double {
        val context = applicationContext ?: return 0.0
        val insetRadius = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            activity?.window?.decorView?.rootWindowInsets
                ?.getRoundedCorner(RoundedCorner.POSITION_BOTTOM_LEFT)
                ?.radius
                ?.takeIf { it > 0 }
        } else {
            null
        }
        val pixels = insetRadius ?: run {
            val id = context.resources.getIdentifier(
                "rounded_corner_radius_bottom",
                "dimen",
                "android",
            )
            if (id > 0) context.resources.getDimensionPixelSize(id) else 0
        }
        val density = context.resources.displayMetrics.density.toDouble()
            .takeIf { it > 0 } ?: 1.0
        return pixels / density
    }

    /** Performs the platform haptic role requested by a Dart component. */
    private fun performHapticFeedback(call: MethodCall, result: MethodChannel.Result) {
        val hostView = activity?.window?.decorView
        if (hostView == null) {
            result.success(false)
            return
        }

        val role = call.argument<String>("type")
        result.success(hostView.performHapticFeedback(resolveHapticConstant(role)))
    }

    /** Mirrors Compose AccessibilityManager.calculateRecommendedTimeoutMillis. */
    private fun recommendedTimeoutMillis(call: MethodCall, result: MethodChannel.Result) {
        val requested = call.argument<Number>("originalTimeoutMillis")?.toLong()
        if (requested == null || requested <= 0L) {
            result.error("invalid_timeout", "originalTimeoutMillis must be positive", null)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(requested)
            return
        }
        val manager = applicationContext
            ?.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
        if (manager == null) {
            result.success(requested)
            return
        }
        var flags = AccessibilityManager.FLAG_CONTENT_ICONS or
            AccessibilityManager.FLAG_CONTENT_TEXT
        if (call.argument<Boolean>("hasAction") == true) {
            flags = flags or AccessibilityManager.FLAG_CONTENT_CONTROLS
        }
        val platformInput = requested.coerceAtMost(Int.MAX_VALUE.toLong()).toInt()
        result.success(manager.getRecommendedTimeoutMillis(platformInput, flags).toLong())
    }

    /** Maps every public Dart haptic role to the closest Android platform role. */
    @Suppress("DEPRECATION")
    private fun resolveHapticConstant(role: String?): Int = when (role) {
        "longPress" -> HapticFeedbackConstants.LONG_PRESS
        "contextClick" -> HapticFeedbackConstants.CONTEXT_CLICK
        "toggleOn" -> if (Build.VERSION.SDK_INT >= 34) {
            HapticFeedbackConstants.TOGGLE_ON
        } else {
            HapticFeedbackConstants.CONTEXT_CLICK
        }
        "toggleOff" -> if (Build.VERSION.SDK_INT >= 34) {
            HapticFeedbackConstants.TOGGLE_OFF
        } else {
            HapticFeedbackConstants.CONTEXT_CLICK
        }
        "segmentTick" -> if (Build.VERSION.SDK_INT >= 34) {
            HapticFeedbackConstants.SEGMENT_TICK
        } else {
            HapticFeedbackConstants.CLOCK_TICK
        }
        "gestureThresholdActivate" -> if (Build.VERSION.SDK_INT >= 34) {
            HapticFeedbackConstants.GESTURE_THRESHOLD_ACTIVATE
        } else {
            HapticFeedbackConstants.CONTEXT_CLICK
        }
        "confirm" -> if (Build.VERSION.SDK_INT >= 30) {
            HapticFeedbackConstants.CONFIRM
        } else {
            HapticFeedbackConstants.CONTEXT_CLICK
        }
        "textHandleMove" -> if (Build.VERSION.SDK_INT >= 27) {
            HapticFeedbackConstants.TEXT_HANDLE_MOVE
        } else {
            HapticFeedbackConstants.CLOCK_TICK
        }
        else -> HapticFeedbackConstants.CONTEXT_CLICK
    }

    /** Streams the same smoothed rotation-vector values used by MIUIX TiltLight. */
    private class TiltStreamHandler(context: Context) :
        EventChannel.StreamHandler,
        SensorEventListener {
        private val sensorManager =
            context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        private val sensor = sensorManager?.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR)
            ?: sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        private val rotationMatrix = FloatArray(9)
        private val orientation = FloatArray(3)
        private var eventSink: EventChannel.EventSink? = null
        private var hostResumed = false
        private var registered = false
        private var initialized = false
        private var smoothPitch = 0f
        private var smoothRoll = 0f
        private var smoothGravityX = 0f
        private var smoothGravityY = 0f

        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            eventSink = events
            reconcileRegistration()
        }

        override fun onCancel(arguments: Any?) {
            eventSink = null
            reconcileRegistration()
        }

        override fun onSensorChanged(event: SensorEvent) {
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            SensorManager.getOrientation(rotationMatrix, orientation)
            val gravityX = -rotationMatrix[6]
            val gravityY = -rotationMatrix[7]
            if (!initialized) {
                smoothPitch = orientation[1]
                smoothRoll = orientation[2]
                smoothGravityX = gravityX
                smoothGravityY = gravityY
                initialized = true
            } else {
                smoothPitch += (orientation[1] - smoothPitch) * SENSOR_SMOOTHING
                smoothRoll += (orientation[2] - smoothRoll) * SENSOR_SMOOTHING
                smoothGravityX += (gravityX - smoothGravityX) * SENSOR_SMOOTHING
                smoothGravityY += (gravityY - smoothGravityY) * SENSOR_SMOOTHING
            }
            eventSink?.success(
                mapOf(
                    "pitch" to smoothPitch.toDouble(),
                    "roll" to smoothRoll.toDouble(),
                    "gravityX" to smoothGravityX.toDouble(),
                    "gravityY" to smoothGravityY.toDouble(),
                ),
            )
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

        fun dispose() {
            eventSink = null
            hostResumed = false
            unregister()
        }

        fun setHostResumed(value: Boolean) {
            hostResumed = value
            reconcileRegistration()
        }

        private fun reconcileRegistration() {
            if (eventSink != null && hostResumed) register() else unregister()
        }

        private fun register() {
            val manager = sensorManager
            val target = sensor
            if (!registered && manager != null && target != null) {
                registered = manager.registerListener(this, target, SensorManager.SENSOR_DELAY_GAME)
            }
        }

        private fun unregister() {
            if (!registered) return
            sensorManager?.unregisterListener(this)
            registered = false
            initialized = false
        }
    }

    /**
     * Reports navigation and caption insets without merging them into one safe
     * area. The listener is attached to DecorView rather than FlutterView, so
     * it does not replace Flutter's own viewport-inset listener.
     */
    private class WindowInsetsStreamHandler : EventChannel.StreamHandler {
        private var activity: Activity? = null
        private var eventSink: EventChannel.EventSink? = null
        private var observedView: View? = null
        private var lastNavigationBottom = Double.NaN
        private var lastCaptionBottom = Double.NaN

        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            eventSink = events
            attachListener()
        }

        override fun onCancel(arguments: Any?) {
            eventSink = null
            detachListener()
        }

        /** Rebinds after rotation or another Activity configuration change. */
        fun setActivity(value: Activity?) {
            if (activity === value) return
            detachListener()
            activity = value
            attachListener()
        }

        /** Releases the DecorView callback before the engine disappears. */
        fun dispose() {
            eventSink = null
            detachListener()
            activity = null
        }

        private fun attachListener() {
            val view = activity?.window?.decorView ?: return
            if (eventSink == null || observedView === view) return
            observedView = view
            view.setOnApplyWindowInsetsListener { _, insets ->
                emit(view, insets)
                // Insets remain unconsumed so Flutter receives the same values.
                insets
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                view.rootWindowInsets?.let { emit(view, it) }
            }
            view.requestApplyInsets()
        }

        private fun detachListener() {
            observedView?.setOnApplyWindowInsetsListener(null)
            observedView = null
            lastNavigationBottom = Double.NaN
            lastCaptionBottom = Double.NaN
        }

        /** Converts physical Android pixels to Flutter logical pixels. */
        @Suppress("DEPRECATION")
        private fun emit(view: View, insets: WindowInsets) {
            val density = view.resources.displayMetrics.density.toDouble()
                .takeIf { it > 0.0 } ?: 1.0
            val navigationPixels: Int
            val captionPixels: Int
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                navigationPixels = insets.getInsets(WindowInsets.Type.navigationBars()).bottom
                captionPixels = insets.getInsets(WindowInsets.Type.captionBar()).bottom
            } else {
                // Caption-bar inset types were introduced in API 30. Earlier
                // Android versions expose only the legacy system bottom inset.
                navigationPixels = insets.systemWindowInsetBottom
                captionPixels = 0
            }
            val navigationBottom = navigationPixels / density
            val captionBottom = captionPixels / density
            if (
                navigationBottom == lastNavigationBottom &&
                captionBottom == lastCaptionBottom
            ) return
            lastNavigationBottom = navigationBottom
            lastCaptionBottom = captionBottom
            eventSink?.success(
                mapOf(
                    "navigationBarBottom" to navigationBottom,
                    "captionBarBottom" to captionBottom,
                ),
            )
        }
    }

    private companion object {
        const val HAPTIC_CHANNEL = "flutter_miuix/haptics"
        const val ACCESSIBILITY_CHANNEL = "flutter_miuix/accessibility"
        const val PLATFORM_CHANNEL = "flutter_miuix/platform"
        const val TILT_CHANNEL = "flutter_miuix/device_tilt"
        const val WINDOW_INSETS_CHANNEL = "flutter_miuix/window_insets"
        const val SENSOR_SMOOTHING = 0.15f
    }
}
