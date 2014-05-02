Applifier Impact is now known as Everyplay GameAds. The rebranding is currently on its way.

Welcome to the repository for Everyplay GameAds. To get started, make sure you have an account registered with Applifier.
If you don't have one, you can create an account at https://my.applifier.com/.

Integration instructions can be found here:

For iOS: http://docs.applifier.com/impact/ios/

For Android: http://docs.applifier.com/impact/android/

Everyplay GameAds SDK is licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.html)

In any issues, please file in issue with us in this Github repository, or log a ticket with us by emailing support@applifier.zendesk.com

Everyplay GameAds SDK Release Notes
===================================

v1.2.1 May 2nd, 2014
--------------------

*Android*

- Fix crash when buffering over very slow connections
- Fix crash when closing end screen on certain zone configurations

v1.2.0 April 30th, 2014
-----------------------

*iOS & Android*

- Improved caching of videos
- Various fixes on both platforms

v1.1.0 February 20th, 2014
--------------------------

*iOS & Android*

- Support for multiple ad-placements with different settings for ads (aka. zones)  API
- various minor fixes on both platforms

*Android*

- Support for Android Advertising ID, requires Google Play Services libraries
- Better adplan performance on Android (New ads checked more frequently)

*iOS*

- device model detection improvements on iOS


v1.0.10 September 25th, 2013
--------------------------
*iOS:*

- Support for iOS 7

v1.0.9 July 19th, 2013
--------------------------
*All platforms:*

- Added a boolean for the video completion delegate for telling whether the video was skipped or not.


*iOS:*

- Removed MAC Address and ODIN1 from iOS7 and added plain text Advertising Identifier (IDFA) sending.
- Enabled skipping stalled video.
- Fixed a bug which caused the video end event not being sent always although the user reached the end.


v1.0.8 July 5th, 2013
--------------------------
*All platforms:*

- Improved video playback error handling

*iOS:*

- Moved network reachability test to background
- Removed duplicate logging events

*Unity:*

- Fixed a build error on Android
- Fixed Unity wrapper calling outdated canShowAds instead of canShowCampaigns


v1.0.7 June 18th, 2013
--------------------------
*All platforms:*

- Fixed reward item showing up in the offer screen. Previously it always showed the default item set on the server side. Now the item selection works on the client side, too.


v1.0.6 May 31st, 2013
--------------------------
*All platforms:*

- Fixed mute button functionality when developer settable video muting was on.


v1.0.5 May 23rd, 2013
--------------------------
*iOS:*

- Fixed a bug that crashed Impact when user attempted to close the Impact window immediately after starting video playback (Thank you First Touch Games for reporting this issue!).

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

*Android:*

- Impact no longer requires CHANGE_WIFI_STATE permission
- android:configChanges="keyboardHidden|orientation" require new possible options depending on the developers targetSdk etc. All possible options Impact needs are: "keyboardHidden|orientation|screenLayout|screenSize|smallestScreenSize"


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

