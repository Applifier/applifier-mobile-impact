Welcome to the repository for Applifier Impact. To get started, make sure you have an account registered with Applifier.
If you don't have one, you can create an account at https://my.applifier.com/.

Integration instructions can be found here:

For iOS: http://docs.applifier.com/facebook-and-web/applifier-impact/ios/integrating-applifier-impact-for-ios/

For Android: http://docs.applifier.com/documentation/applifier-impact/impact-for-android/integration-documentation/

Applifier Impact SDK is licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.html)

In any issues, please file in issue with us in this Github repository, or log a ticket with us by emailing support@applifier.zendesk.com

Applifier Impact SDK Release Notes
==================================

v1.0.5 May 23rd, 2013
--------------------------
*iOS:*

- Fixed a bug that crashed Impact when user attempted to close the Impact windoe immediately after starting video playback (Thank you First Touch Games for reporting this issue!).

*Android:*

- Fixed a bug in instrumentation where WebApp would get erroneous data from native side and log javascript errors.


v1.0.4 May 22nd, 2013
--------------------------
*All platforms:*

- Support for muting video sounds & controlling the default setting from code
- Support setting Impact orientation to locked or unlocked to device orientation
- Ability to skip videos after n seconds as a server side configuration
- Better handling of opening iTunes / Google Play
- Improved instrumentation of network status
- Preview capability for loading campaigns of specific advertiser for previewing campaigns on the device

*iOS:*

- Option to use a Native iOS UI instead of UIWebView in order to save memory


v1.0.3.2 "Red Apple" - March 13, 2013
--------------------------

*Android:*

- Support for Unity3D
- Minor edge-case bugfixes

*iOS:*

- Support for Unity3D

v1.0.3.1 "Robotic Overlords" - February 27, 2013
--------------------------

*Android:*

- Android support is now officially released, get it while it's hot!

*iOS:*

- Bugfixes

v1.0.3 "Cornucopia" - January 23, 2013
--------------------------

*iOS:*

- Support for multiple reward items


v1.0.2 "AirHead" - December 11, 2012
--------------------------

*Adobe AIR:*

- Support for Adobe AIR when running on iOS platforms

*iOS:*

- Better fallbacks in some cases if data is not received correctly


v1.0.1 - November 28, 2012
--------------------------

*iOS:*

- Refactored view logic for easier integration
- Bug fixes, improved cache policies for video ad caching

*Android:*

- Android version still in development, should not be used in production apps

