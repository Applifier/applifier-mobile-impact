#!/bin/sh
cd build
~/AIRSDK_Compiler/bin/adt -package -target ane applifier-impact-mobile.ane extension.xml -swc ./ApplifierImpactMobileAIRWrapper.swc -platform iPhone-ARM -C ios . -platformoptions platformoptions_ios.xml -platform default -C default .
cd ..
