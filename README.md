# UnityDeeplinks
A set of tools for Unity to allow handling deeplink activation from within Unity scripts, for Android and iOS, including iOS Universal Links.

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
* Implement `onAppOpenAttribution` in *AppsFlyerTrackerCallbacks.cs* as follows:
```cs
public void onAppOpenAttribution(string validateResult) {
	print("AppsFlyerTrackerCallbacks:: got onAppOpenAttribution  = " + validateResult);
	System.Collections.Generic.Dictionary<string, string> values =
		new System.Collections.Generic.Dictionary<string, string>();
	values.Add("data", validateResult);
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

* Add the following inside the *activity* tag, assuming your deeplink URL scheme is myapp://
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
Some might suggest having a "side-activity" e.g. *MyDeeplinkActivity* to handle the deeplink and start the main Unity player activity. This way, the main Unity player activity remains clean of "outside code", right? Wrong, expect an error message in LogCat:
```
Native libraries not loaded - dropping message for ...
```

Here's why - consider the Unity app is currently not running. Then:
* A deeplink gets activated
* MyDeeplinkActivity starts
* Tries to access the UnityPlayer object in order to send a message to a Unity script with the deeplink information
* At this point, since the Unity native libraries not yet initialized, the call would fail with the mentioned error

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
adding: com/trophit/DeeplinkActivity.class(in = 2368) (out= 1237)(deflated 47%)
adding: com/trophit/MyUnityPlayerActivity.class(in = 1504) (out= 789)(deflated 47%)
```
This creates/updates a *UnityDeeplinks.jar* file under your Unity project's Assets/UnityDeeplinks folder

* Continue to build and test your Unity project as usual in order for any jar changes to take effect

## iOS
UnityDeeplinks implements a native plugin for iOS, initialized by *Assets/UnityDeeplinks/UnityDeeplinks.cs*. the plugin listens for URL/Univeral Link activations and relayes them to the Unity script for processing.

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
AppsFlyer already provides some implementation for iOS and Android to handle deeplinks. However, it does not behave consistently for iOS and Android when a deeplink is activated:
* For iOS, it triggers the *onAppOpenAttribution* method in the *AppsFlyerTrackerCallbacks* script
* For iOS, it does not handle Universal Links (in AppsFlyer SDK v4.10 or lower)
* For Android, it does not trigger any Unity script method

We can complement AppsFlyer's plugin and ensure the same trigger is added for Android:

* Do NOT implement the AppsFlyer deeplinking configuration as the guide suggests (it uses the concept of a second activity to trigger deeplinks, which we've [discussed earlier](#why-not-handle-deeplinks-in-a-second-activity)
* For iOS, call `AppsFlyer.getConversionData();` in your AppsFlyer startup script, right after `setAppId`:
```cs
#if UNITY_IOS
AppsFlyer.setAppID ("123456789");
AppsFlyer.getConversionData();
// ...
```
* For Android, modify *Assets/UnityDeeplinks/Android/MyUnityPlayerActivity.java*'s `onDeeplink` method:
```java
protected void onDeeplink(Intent intent) {
    if (Intent.ACTION_VIEW.equals(intent.getAction())) {
        String deeplink = intent.getDataString();
        if (deeplink != null) {
            try {
                org.json.JSONObject jo = new org.json.JSONObject();
                jo.put("link", getIntent().getDataString());
                com.unity3d.player.UnityPlayer.UnitySendMessage(
		    "AppsFlyerTrackerCallbacks", "onAppOpenAttribution", jo.toString());
            } catch (org.json.JSONException ex) {
                Log.e(TAG, "Unable to send deeplink to Unity", ex);
            }
	}
    }
}
```
* Rebuild the UnityDeeplinks .jar, [as explained above](#building-the-unitydeeplinksjar-file)

* Finally, implement your `AppsFlyerTrackerCallbacks.onAppOpenAttribution` method as needed. Upon deeplink activation on iOS or Android, it receives a JSON string in the format:
`{"link":"deeplink url comes here"}`
* Proceed to [testing](#testing) as usual
