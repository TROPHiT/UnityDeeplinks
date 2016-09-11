#!/bin/sh

UNITY_LIBS="/Applications/Unity/PlaybackEngines/AndroidPlayer/Variations/mono/Release/Classes/classes.jar"
export UNITY_LIBS

ANDROID_SDK_ROOT="/kankado/dev/tools/android-sdk-macosx"
export ANDROID_SDK_ROOT

BOOTCLASSPATH=/Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home/jre/lib
export BOOTCLASSPATH
CLASSPATH=$UNITY_LIBS:$ANDROID_SDK_ROOT/platforms/android-23/android.jar
export CLASSPATH

echo "Compiling ..."
echo $BOOTCLASSPATH
echo $CLASSPATH
javac *.java -bootclasspath $BOOTCLASSPATH -classpath $CLASSPATH -d . -target 1.7 -source 1.7

echo "Manifest-Version: 1.0" > MANIFEST.MF

echo "Creating jar file..."
jar cvfM ../UnityDeeplinks.jar com/

