# Flutter 기본 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart 및 Flutter 엔진 관련
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Dio HTTP 클라이언트
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# GetX
-keep class com.get.** { *; }
-keepclassmembers class * extends com.get.GetxController {
    <methods>;
}

# Flutter Blue Plus
-keep class com.boskokg.flutter_blue_plus.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 모델 클래스 유지 (JSON 직렬화용)
-keep class com.example.myapp.app.cores.models.** { *; }
-keep class com.example.myapp.app.modules.**.models.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# 리플렉션 사용을 위한 클래스 유지
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Enum 클래스 유지
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable 구현 유지
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 경고 억제
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
