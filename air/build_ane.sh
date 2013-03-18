#!/bin/sh
cd build/android
jar -xf ../../../android/sources/jar/applifier-impact-android.jar
jar -uf libApplifierImpactMobileAIRWrapper.jar com
rm -rf com META-INF
cd ..
~/AIRSDK_Compiler/bin/adt -package -target ane ../native_extension/applifier-impact-mobile.ane extension.xml -swc ./ApplifierImpactMobileAIRWrapper.swc -platform iPhone-ARM -C ios . -platformoptions platformoptions_ios.xml -platform Android-ARM -C android . -platform default -C default .
cd ..
