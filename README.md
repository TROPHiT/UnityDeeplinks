# UnityDeeplinks
A set of tools for Unity to allow handling deeplink activation from within Unity scripts, for Android and iOS, including iOS Universal Links.

### Known Issues/Limitations
* Check out the repo's *issues* section

### Disclaimer
This is NOT a TROPHiT SDK - this repo is an open-source contribution to developers for handling deeplink activations in a unified way for both iOS and Android. It can be used independently and regardless of TROPHiT services in order to intercept deeplinks for whatever purpose. If you are looking for info about TROPHiT integration modules, visit the [TROPHiT Help Center](https://trophit.zendesk.com/hc/en-us/articles/200865062-How-do-I-integrate-TROPHiT-)

# Usage
#### Example: Track Deeplinks with Adjust
* Tested with [Adjust Unity SDK](https://github.com/adjust/unity_sdk) v4.10.0
* Also enables Adjust's SDK to handle iOS Universal Links
* Assuming you already integrated the Adjust SDK, just implement `onDeeplink` in *UnityDeeplinks.cs* as follows:

 ```cs
 public void onDeeplink(string deeplink) {
     AdjustEvent adjustEvent = new AdjustEvent("abc123");
     adjustEvent.addCallbackParameter("deeplink", deeplink); // optional, for callback support
     Adjust.trackEvent(adjustEvent);
 }
 ```
* Add the following code marked `add this` to *Assets/UnitDeeplinks/iOS/UnityDeeplinks.mm*:

 ```objc
 #import "Adjust.h"  // <==== add this
 ...
 
 - (void)onNotification:(NSNotification*)notification {
     if (![kUnityOnOpenURL isEqualToString:notification.name]) return;
     ...
     [Adjust appWillOpenUrl:url]; // <==== add this right before UnityDeeplinks_dispatch
     UnityDeeplinks_dispatch([url absoluteString]);
 }
 ```

#### Example: Track Deeplinks with Tune
* Tested with [Tune Unity Plugin](https://developers.tune.com/sdk/unity-quick-start/) v4.3.1
* Also enables Tune's Plugin to handle iOS Universal Links
* Assuming you already integrated the Tune Plugin, just implement `onDeeplink` in *UnityDeeplinks.cs* as follows:

 ```cs
 public void onDeeplink(string deeplink) {
    TuneEvent event = new TuneEvent("deeplink");
    event.attribute1 = deeplink;
    Tune.MeasureEvent(event);
 }
 ```

#### Example: Track Deeplinks with Kochava
* Also enables Kochava's SDK to handle iOS Universal Links
* Assuming you already integrated the [Kochava Unity SDK](http://support.kochava.com/sdk-integration/unity-sdk-integration), just implement `onDeeplink` in *UnityDeeplinks.cs* as follows:

 ```cs
 public void onDeeplink(string deeplink) {
    Kochava.DeeplinkEvent(deeplink, null);
 }
 ```

#### Example: Track Deeplinks with AppsFlyer
* Tested with [AppsFlyer Unity SDK](https://support.appsflyer.com/hc/en-us/articles/213766183-Unity) v4.10.1, v4.11
* Requires some [customizations](#appsflyer)
* Also enables AppsFlyer's SDK to handle iOS Universal Links (for AppsFlyer Unity SDK 4.10 or earlier)
* Implement `onDeeplink` in *UnityDeeplinks.cs* as follows:

 ```cs
 public void onDeeplink(string deeplink) {
     System.Collections.Generic.Dictionary<string, string> values =
         new System.Collections.Generic.Dictionary<string, string>();
     values.Add("link", deeplink);
     AppsFlyer.trackRichEvent("deeplink", values);
 }
 ```

# Integration
* Clone/download the repository
* Copy the entire UnityDeeplinks folder into your Unity project Assets folder
* Attach the *Assets/UnityDeeplinks/UnityDeeplinks.cs* script to an empty *UnityDeeplinks* game object

## Android
Subclass the default *UnityPlayerActivity* in order to add deeplink-handling code that marshals deeplinks into your Unity script:

* Replace the default UnityPlayerActivity in your Assets/Plugins/Android/AndroidManifest.xml with com.trophit.MyUnityPlayerActivity:

 ```xml
 <!--
 <activity android:name="com.unity3d.player.UnityPlayerActivity" ...
 -->
 <activity android:name="com.trophit.MyUnityPlayerActivity" ...
 ```

* Add the following inside the same *activity* tag, assuming your deeplink URL scheme is myapp://

 ```xml
 <intent-filter>
     <action android:name="android.intent.action.VIEW" />
     <category android:name="android.intent.category.DEFAULT" />
     <category android:name="android.intent.category.BROWSABLE" />
     <data android:scheme="myapp" />
 </intent-filter>
 ```

* Notes:
 * If you already subclassed your Unity activity, merge the code from within *MyUnityPlayerActivity* into your existing subclass
 * Optional: by default, *MyUnityPlayerActivity* calls a Unity script method `onDeeplink` on a game object called *UnityDeeplinks*. If you wish to change the name of the object or method, you should edit *Assets/UnityDeeplinks/Android/MyUnityPlayerActivity.java*, change the values of the `gameObject` and/or `deeplinkMethod` static properties and rebuild the *UnityDeeplinks.jar* file as instructed below

### Why not handle deeplinks in a second activity?
Some might suggest having a "side-activity" e.g. *MyDeeplinkActivity* to handle the deeplink and start the main Unity player activity. This way, the main Unity player activity remains clean of "outside code", right? Wrong. Consider the Unity app is currently not running. Then:
* A deeplink gets activated
* MyDeeplinkActivity starts
* Tries to access the UnityPlayer object in order to send a message to a Unity script with the deeplink information
* At this point, since the Unity native libraries are not yet initialized, the call would fail with the error:
 ```
 Native libraries not loaded - dropping message for ...
 ```
Bottom line: you need the Unity player activity initialized in order to call Unity functions from native code. The only way to handle the scenario above would be to have the Unity player activity itself handle the deeplink. Unity will make sure it's initialized prior to the call.

### Building the UnityDeeplinks.jar file
Only perform this step if you made changes to any .java file under *Assets/UnityDeeplinks/Android/* or would like to rebuild it using an updated version of Unity classes, Android SDK, JDK and so on.

#### Prerequisites
* Go to your Unity => Preferences => External tools menu and find your Android SDK and JDK home folders
* Edit *UnityDeeplinks/Android/bulid_jar.sh*
* Ensure ANDROID_SDK_ROOT points to your Android SDK root folder
* Ensure JDK_HOME points to your JDK root folder
* Ensure UNITY_LIBS points to the Unity classes.jar file in your development environment

#### Build instructions
Run the build script:
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
adding: com/trophit/DeeplinkActivity.class(in = 2368) (out= 1237)(deflated 47%)
adding: com/trophit/MyUnityPlayerActivity.class(in = 1504) (out= 789)(deflated 47%)
```

This creates/updates a *UnityDeeplinks.jar* file under your Unity project's Assets/UnityDeeplinks folder.

Finally, continue to build and test your Unity project as usual in order for any jar changes to take effect

## iOS
UnityDeeplinks implements a native plugin for iOS, initialized by *Assets/UnityDeeplinks/UnityDeeplinks.cs*. The plugin listens for URL/Univeral Link activations and relayes them to the Unity script for processing. It, too, uses a similar approach as the one used for Android: the main Unity app controller gets subclassed.

Also, like in the Android case, if the app is currently not running, we can't simply have the native low-level deeplinking code make calls to Unity scripts until the Unity libraries are initialized. Therefore, we store the deeplink in a variable, wait for the app to initialize the plugin (an indication that the Unity native libraries are ready), and then send the stored deeplink to the Unity script.

* To support URL schemes, go to your Unity project's Build => iOS Player Settings => Other Settings => Supported URL Schemes and set:
 * Size: 1
 * Element 0: your URL scheme, e.g. myapp
* To support Universal Links, set them up as per [their specification](https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/UniversalLinks.html). *Note:* Universal Link settings in your XCode project are not removed during Unity rebuilds, unless you use the *Replace* option and overwrite your XCode project

## Testing

* Prepare a dummy web page that is accessible by your mobile device:

 ```xml
 <body>
 <a href="myapp://?a=b">deeplink test</a>
 </body>
 ```

* Open the web page on the device browser and click the deeplink
* The Unity app should open and the onDeeplink Unity script method should be invoked, performing whatever it is you designed it to perform

# Special Cases

## AppsFlyer
AppsFlyer already provides some implementation for iOS and Android to handle deeplinks. However, it has some inconsistencies:

* For iOS, it triggers the *onAppOpenAttribution* method in the *AppsFlyerTrackerCallbacks* script, but only if the app is already in the background. If it is not runnning, the method isn't triggered.
* For iOS, it does not handle Universal Links (in AppsFlyer SDK v4.10 or lower)
* For iOS, the *onAppOpenAttribution* method receives an input string in the format:
 `{"link":"deeplink url comes here"}`
 which is not parsable in Unity without external JSON libraries
* For Android, it does not trigger any Unity script method

For those reasons, we provide an implementation to completent AppsFlyer. Assuming you have already followed AppsFlyer's [integration guide](https://support.appsflyer.com/hc/en-us/articles/213766183-Unity) and performed the [integration](#integration) instructions above, follow the extra steps below and later proceed with [testing](#testing) as usual

### Android
* In your AndroidManifest.xml:
 * Change the main activity class from *com.trophit.MyUnityPLayerActivity* to *com.appsflyer.MyUnityPlayerActivity*
 * Remove *com.appsflyer.GetDeeplinkingActivity* from your AndroidManifest.xml (it uses the concept of a second activity to trigger deeplinks, which we've [discussed earlier](#why-not-handle-deeplinks-in-a-second-activity))

* Copy *Assets/UnityDeeplinks/Android/MyUnityPlayerActivity.java* to *Assets/Plugins/Android/src/MyUnityPlayerActivity.java* and make the following changes in the new copy:
 
 * Change the package name to *com.appsflyer*:
   ```
   package com.appsflyer;
   ```
   
 * Add a call to *AppsFlyerLib.setDeepLinkData* at the beginning of the `onDeeplink` method:
 ```java
 protected void onDeeplink(Intent intent) {
    AppsFlyerLib.getInstance().setDeepLinkData(intent); // <== add this
    // if (Intent.ACTION_VIEW.equals(intent.getAction())) ...
 }
 ```

* Rebuild the AppsFlyerAndroidPlugin.jar using AppsFlyer's script at *Assets/Plugins/Android/src/build_plugin_jar.sh* (make sure the paths inside the script are correct [as explained above](#building-the-unitydeeplinksjar-file))



### iOS

* Ensure you call `AppsFlyer.getConversionData();`:
```cs
#if UNITY_IOS
AppsFlyer.setAppID ("123456789");
AppsFlyer.getConversionData();
// ...
```

* (AppsFlyer SDK 4.11+): Comment out *IMPL_APP_CONTROLLER_SUBCLASS* in *Assets/Plugins/iOS/AppsFlyerAppController.m*:
```c
// IMPL_APP_CONTROLLER_SUBCLASS(AppsFlyerAppController)
```
  
* (AppsFlyer SDK 4.11+): Copy the "important bits" from the above file to *Assets/UnityDeeplinks/iOS/UnityDeeplinks.mm* as follows:
```c
#import "AppsFlyerTracker.h"
...
// Add as the first line inside application:continueUserActivity:
[[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
```
