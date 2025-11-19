# Flutter's default rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# General rule for Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Rules for Google Play Core (for split components, used by Flutter)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# General rule for ML Kit
-keep public class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Specific rules for ML Kit Text Recognition and its components
-keep public class com.google.mlkit.vision.text.** { *; }
-keep public class com.google.mlkit.vision.text.korean.** { *; }
-keep public class com.google.mlkit.vision.text.japanese.** { *; }
-keep public class com.google.mlkit.vision.text.chinese.** { *; }
-keep public class com.google.mlkit.vision.text.devanagari.** { *; }

# Keep internal ML Kit classes that might be accessed via reflection
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**

# Keep models and options classes explicitly
-keep public class * extends com.google.mlkit.common.sdkinternal.MlKitComponent
-keep class com.google.mlkit.vision.text.internal.** { *; }
-keep class com.google.mlkit.common.sdkinternal.model.** { *; }
-keep class com.google.mlkit.common.sdkinternal.zzg { *; }
-keep class com.google.mlkit.common.sdkinternal.zzh { *; }

# Keep Flutter's deferred components classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
