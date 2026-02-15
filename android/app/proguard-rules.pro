
-keep class com.follow.clash.models.**{ *; }

-keep class com.follow.clash.service.models.**{ *; }

# LeafBridge: protectSocket() is called from JNI native code (libleaf.so),
# invisible to R8 static analysis. Keep all members to prevent stripping.
-keep class com.follow.clash.common.LeafBridge { *; }
