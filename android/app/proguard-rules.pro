# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Unity Ads
-keep class com.unity3d.** { *; }
-dontwarn com.unity3d.**

# Gson (used by some SDKs)
-keepattributes Signature
-keepattributes *Annotation*

# Flutter deferred components (Play Core — optional, not used by this app)
-dontwarn com.google.android.play.core.**