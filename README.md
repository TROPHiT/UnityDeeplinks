# UnityDeeplinks
A set of tools for Unity to allow handling deeplink activation from within Unity scripts

# Usage
From within your Unity script, whenever the app gets activated by a deeplink, the following method will be called:

```
public void onDeeplink(string deeplink) {
    Debug.Log("onDeeplink " + deeplink);
}
```

# Integration Instructions
1. Clone/download the repository
2. Copy the entire UnityDeeplinks folder into your Unity project Assets folder

## Android

### If you have not yet overridden the default UnityPlayerActivity
You will have to use the provided UnityPlayerActivity subclass as follows:

* Replace the default UnityPlayerActivity in your Assets/Plugins/Android/AndroidManifest.xml with com.trophit.MyUnityPlayerActivity:

```
<!--
<activity android:name="com.unity3d.player.UnityPlayerActivity">
-->
<activity android:name="com.trophit.MyUnityPlayerActivity">
```

* Optional: by default, *MyUnityPlayerActivity* calls a Unity script method `onDeeplink` on a game object called *UnityDeeplinks*. If you wish to change the name of the object or method, you should edit *MyUnityPlayerActivity.java*, change the values of the `gameObject` and/or `deeplinkMethod` static properties and rebuild the *UnityDeeplinks.jar* file as instructed below

### Building the UnityDeeplinks.jar file

#### Prerequisites
* Go to your Unity => Preferences => External tools menu and find your Android SDK and JDK home folders
* Edit *UnityDeeplinks/Android/bulid_jar.sh*
* Ensure ANDROID_SDK_ROOT points to your Android SDK root folder
* Ensure the BOOTCLASSPATH points to your JDK/jre/lib folder
* Ensure UNITY_LIBS points to the Unity classes.jar file in your development environment

#### Build instructions
* Run the build script:
```
cd MY_UNITY_PROJECT_ROOT/Assets/UnityDeeplinks/Android
./build_jar.sh
```
Example output:
```
Compiling ...
/Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home/jre/lib
/Applications/Unity/PlaybackEngines/AndroidPlayer/Variations/mono/Release/Classes/classes.jar:/kankado/dev/tools/android-sdk-macosx/platforms/android-23/android.jar
Creating jar file...
adding: com/(in = 0) (out= 0)(stored 0%)
adding: com/trophit/(in = 0) (out= 0)(stored 0%)
adding: com/trophit/MyUnityPlayerActivity.class(in = 1504) (out= 789)(deflated 47%)
```
This creates/updates a *UnityDeeplinks.jar* file under your Unity project's Assets/UnityDeeplinks folder

* Continue to build and test your Unity project as usual in order for any jar changes to take effect
