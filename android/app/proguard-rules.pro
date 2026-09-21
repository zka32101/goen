# Older Firebase SDKs rely on reflection to instantiate their component
# registrars. With R8 full mode the no-arg constructors get stripped, which
# makes Crashlytics/Installations "not present" at runtime.
-keep class * implements com.google.firebase.components.ComponentRegistrar { <init>(); }
-keep class * implements com.google.firebase.components.ComponentRegistrar
-keep class com.google.firebase.provider.FirebaseInitProvider
