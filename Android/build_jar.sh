#!/bin/sh

UNITY_LIBS="/Applications/Unity/PlaybackEngines/AndroidPlayer/Variations/mono/Release/Classes/classes.jar"
export UNITY_LIBS

ANDROID_SDK_ROOT="/kankado/dev/tools/android-sdk-macosx"
export ANDROID_SDK_ROOT

JDK_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home
export JDK_HOME

BOOTCLASSPATH=$JDK_HOME/jre/lib
export BOOTCLASSPATH

CLASSPATH=$UNITY_LIBS:$ANDROID_SDK_ROOT/platforms/android-23/android.jar
export CLASSPATH

echo "Compiling ..."
echo $BOOTCLASSPATH
echo $CLASSPATH
$JDK_HOME/bin/javac *.java -bootclasspath $BOOTCLASSPATH -classpath $CLASSPATH -d .

echo "Manifest-Version: 1.0" > MANIFEST.MF

echo "Creating jar file..."
jar cvfM ../UnityDeeplinks.jar com/

