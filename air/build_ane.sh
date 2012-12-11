#!/bin/sh
~/Library/AirSDK/bin/adt -package -target ane applifier-impact-mobile.ane extension.xml -swc ./ApplifierImpactMobileAIRWrapper.swc -platform iPhone-ARM -C ios . -platformoptions ios/platformoptions.xml -platform default -C default .
