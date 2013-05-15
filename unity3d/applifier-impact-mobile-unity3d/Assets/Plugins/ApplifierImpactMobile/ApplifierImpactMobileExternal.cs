using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class ApplifierImpactMobileExternal {

	private static string _logTag = "ApplifierImpactMobile";
	
	public static void Log (string message) {
		ApplifierImpactMobile applifierImpactMobileInstance = ApplifierImpactMobile.SharedInstance;
		
		if(applifierImpactMobileInstance) {
			if(applifierImpactMobileInstance.debugModeEnabled && Debug.isDebugBuild)
				Debug.Log(_logTag + "/" + message);
		}
	}
	
#if UNITY_EDITOR
	public static void init (string gameId, bool testModeEnabled, bool debugModeEnabled, string gameObjectName) {
		Log ("UnityEditor: init(), gameId=" + gameId + ", testModeEnabled=" + testModeEnabled + ", gameObjectName=" + gameObjectName + ", debugModeEnabled=" + debugModeEnabled);
	}
	
	public static bool showImpact (bool openAnimated, bool noOfferscreen, string gamerSID, bool muteVideoSounds, bool videoUsesDeviceOrientation) {
		Log ("UnityEditor: showImpact()");
		return false;
	}
	
	public static void hideImpact () {
		Log ("UnityEditor: hideImpact()");
	}
	
	public static bool isSupported () {
		Log ("UnityEditor: isSupported()");
		return false;
	}
	
	public static string getSDKVersion () {
		Log ("UnityEditor: getSDKVersion()");
		return "EDITOR";
	}
	
	public static bool canShowCampaigns () {
		Log ("UnityEditor: canShowCampaigns()");
		return false;
	}
	
	public static bool canShowImpact () {
		Log ("UnityEditor: canShowImpact()");
		return false;
	}
	
	public static void stopAll () {
		Log ("UnityEditor: stopAll()");
	}
	
	public static bool hasMultipleRewardItems () {
		Log ("UnityEditor: hasMultipleRewardItems()");
		return false;
	}
	
	public static string getRewardItemKeys () {
		Log ("UnityEditor: getRewardItemKeys()");
		return "";
	}

	public static string getDefaultRewardItemKey () {
		Log ("UnityEditor: getDefaultRewardItemKey()");
		return "";
	}
	
	public static string getCurrentRewardItemKey () {
		Log ("UnityEditor: getCurrentRewardItemKey()");
		return "";
	}

	public static bool setRewardItemKey (string rewardItemKey) {
		Log ("UnityEditor: setRewardItemKey() rewardItemKey=" + rewardItemKey);
		return false;
	}
	
	public static void setDefaultRewardItemAsRewardItem () {
		Log ("UnityEditor: setDefaultRewardItemAsRewardItem()");
	}
	
	public static string getRewardItemDetailsWithKey (string rewardItemKey) {
		Log ("UnityEditor: getRewardItemDetailsWithKey() rewardItemKey=" + rewardItemKey);
		return "";
	}
	
	public static string getRewardItemDetailsKeys () {
		return "name;picture";
	}
	
#elif UNITY_IPHONE
	[DllImport ("__Internal")]
	public static extern void init (string gameId, bool testModeEnabled, bool debugModeEnabled, string gameObjectName);
	
	[DllImport ("__Internal")]
	public static extern bool showImpact (bool openAnimated, bool noOfferscreen, string gamerSID, bool muteVideoSounds, bool videoUsesDeviceOrientation);
	
	[DllImport ("__Internal")]
	public static extern void hideImpact ();
	
	[DllImport ("__Internal")]
	public static extern bool isSupported ();
	
	[DllImport ("__Internal")]
	public static extern string getSDKVersion ();

	[DllImport ("__Internal")]
	public static extern bool canShowCampaigns ();

	[DllImport ("__Internal")]
	public static extern bool canShowImpact ();
	
	[DllImport ("__Internal")]
	public static extern void stopAll ();

	[DllImport ("__Internal")]
	public static extern bool hasMultipleRewardItems ();
	
	[DllImport ("__Internal")]
	public static extern string getRewardItemKeys ();

	[DllImport ("__Internal")]
	public static extern string getDefaultRewardItemKey ();
	
	[DllImport ("__Internal")]
	public static extern string getCurrentRewardItemKey ();

	[DllImport ("__Internal")]
	public static extern bool setRewardItemKey (string rewardItemKey);
	
	[DllImport ("__Internal")]
	public static extern void setDefaultRewardItemAsRewardItem ();

	[DllImport ("__Internal")]
	public static extern string getRewardItemDetailsWithKey (string rewardItemKey);

	[DllImport ("__Internal")]
	public static extern string getRewardItemDetailsKeys ();

#elif UNITY_ANDROID
	private static AndroidJavaObject applifierImpact;
	private static AndroidJavaObject applifierImpactUnity;
	private static AndroidJavaClass applifierImpactClass;
	
	public static void init (string gameId, bool testModeEnabled, bool debugModeEnabled, string gameObjectName) {
		Log("UnityAndroid: init(), gameId=" + gameId + ", testModeEnabled=" + testModeEnabled + ", gameObjectName=" + gameObjectName + ", debugModeEnabled=" + debugModeEnabled);
		AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
		AndroidJavaObject activity = jc.GetStatic<AndroidJavaObject>("currentActivity");
		applifierImpactUnity = new AndroidJavaObject("com.applifier.impact.android.unity3d.ApplifierImpactUnity3DWrapper");
		applifierImpactUnity.Call("init", gameId, activity, testModeEnabled, debugModeEnabled, gameObjectName);
	}
	
	public static bool showImpact (bool openAnimated, bool noOfferscreen, string gamerSID, bool muteVideoSounds, bool videoUsesDeviceOrientation) {
		Log ("UnityAndroid: showImpact()");
		return applifierImpactUnity.Call<bool>("showImpact", openAnimated, noOfferscreen, gamerSID, muteVideoSounds, videoUsesDeviceOrientation);
	}
	
	public static void hideImpact () {
		Log ("UnityAndroid: hideImpact()");
		applifierImpactUnity.Call("hideImpact");
	}
	
	public static bool isSupported () {
		Log ("UnityAndroid: isSupported()");
		return applifierImpactUnity.Call<bool>("isSupported");
	}
	
	public static string getSDKVersion () {
		Log ("UnityAndroid: getSDKVersion()");
		return applifierImpactUnity.Call<string>("getSDKVersion");
	}
	
	public static bool canShowCampaigns () {
		Log ("UnityAndroid: canShowCampaigns()");
		return applifierImpactUnity.Call<bool>("canShowCampaigns");
	}
	
	public static bool canShowImpact () {
		Log ("UnityAndroid: canShowImpact()");
		return applifierImpactUnity.Call<bool>("canShowImpact");
	}
	
	public static void stopAll () {
		Log ("UnityAndroid: stopAll()");
		applifierImpactUnity.Call("stopAll");
	}
	
	public static bool hasMultipleRewardItems () {
		Log ("UnityAndroid: hasMultipleRewardItems()");
		return applifierImpactUnity.Call<bool>("hasMultipleRewardItems");
	}
	
	public static string getRewardItemKeys () {
		Log ("UnityAndroid: getRewardItemKeys()");
		return applifierImpactUnity.Call<string>("getRewardItemKeys");
	}

	public static string getDefaultRewardItemKey () {
		Log ("UnityAndroid: getDefaultRewardItemKey()");
		return applifierImpactUnity.Call<string>("getDefaultRewardItemKey");
	}
	
	public static string getCurrentRewardItemKey () {
		Log ("UnityAndroid: getCurrentRewardItemKey()");
		return applifierImpactUnity.Call<string>("getCurrentRewardItemKey");
	}

	public static bool setRewardItemKey (string rewardItemKey) {
		Log ("UnityAndroid: setRewardItemKey() rewardItemKey=" + rewardItemKey);
		return applifierImpactUnity.Call<bool>("setRewardItemKey", rewardItemKey);
	}
	
	public static void setDefaultRewardItemAsRewardItem () {
		Log ("UnityAndroid: setDefaultRewardItemAsRewardItem()");
		applifierImpactUnity.Call("setDefaultRewardItemAsRewardItem");
	}
	
	public static string getRewardItemDetailsWithKey (string rewardItemKey) {
		Log ("UnityAndroid: getRewardItemDetailsWithKey() rewardItemKey=" + rewardItemKey);
		return applifierImpactUnity.Call<string>("getRewardItemDetailsWithKey", rewardItemKey);
	}
	
	public static string getRewardItemDetailsKeys () {
		Log ("UnityAndroid: getRewardItemDetailsKeys()");
		return applifierImpactUnity.Call<string>("getRewardItemDetailsKeys");
	}
	
#endif

}
