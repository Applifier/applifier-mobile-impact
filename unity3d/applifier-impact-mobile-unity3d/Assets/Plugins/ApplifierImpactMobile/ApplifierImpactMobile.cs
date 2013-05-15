using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ApplifierImpactMobile : MonoBehaviour {

	public string gameId = "";
	public bool debugModeEnabled = false;
	public bool testModeEnabled = false;
	public bool openAnimated = false;
	public bool noOfferscreen = false;
	public bool videoUsesDeviceOrientation = false;
	public bool muteVideoSounds = false;
	
	private static ApplifierImpactMobile sharedInstance;
	private static bool _campaignsAvailable = false;
	private static bool _impactOpen = false;
	private static float _savedTimeScale = 1f;
	private static float _savedAudioVolume = 1f;
	private static string _gamerSID = "";
	
	private static string _rewardItemNameKey = "";
	private static string _rewardItemPictureKey = "";
	
	public delegate void ApplifierImpactCampaignsAvailable();
	private static ApplifierImpactCampaignsAvailable _campaignsAvailableDelegate;
	public static void setCampaignsAvailableDelegate (ApplifierImpactCampaignsAvailable action) {
		_campaignsAvailableDelegate = action;
	}

	public delegate void ApplifierImpactCampaignsFetchFailed();
	private static ApplifierImpactCampaignsFetchFailed _campaignsFetchFailedDelegate;
	public static void setCampaignsFetchFailedDelegate (ApplifierImpactCampaignsFetchFailed action) {
		_campaignsFetchFailedDelegate = action;
	}

	public delegate void ApplifierImpactOpen();
	private static ApplifierImpactOpen _impactOpenDelegate;
	public static void setOpenDelegate (ApplifierImpactOpen action) {
		_impactOpenDelegate = action;
	}
	
	public delegate void ApplifierImpactClose();
	private static ApplifierImpactClose _impactCloseDelegate;
	public static void setCloseDelegate (ApplifierImpactClose action) {
		_impactCloseDelegate = action;
	}

	public delegate void ApplifierImpactVideoCompleted(string rewardItemKey);
	private static ApplifierImpactVideoCompleted _videoCompletedDelegate;
	public static void setVideoCompletedDelegate (ApplifierImpactVideoCompleted action) {
		_videoCompletedDelegate = action;
	}
	
	public delegate void ApplifierImpactVideoStarted();
	private static ApplifierImpactVideoStarted _videoStartedDelegate;
	public static void setVideoStartedDelegate (ApplifierImpactVideoStarted action) {
		_videoStartedDelegate = action;
	}
	
	public static ApplifierImpactMobile SharedInstance {
		get {
			if(!sharedInstance) {
				sharedInstance = (ApplifierImpactMobile) FindObjectOfType(typeof(ApplifierImpactMobile));

				#if (UNITY_IPHONE || UNITY_ANDROID) && !UNITY_EDITOR
				ApplifierImpactMobileExternal.init(sharedInstance.gameId, sharedInstance.testModeEnabled, sharedInstance.debugModeEnabled && Debug.isDebugBuild, sharedInstance.gameObject.name);
				#endif
			}

			return sharedInstance;
		}
	}
	
	public void Awake () {
		if(gameObject == SharedInstance.gameObject) {
			DontDestroyOnLoad(gameObject);
		}
		else {
			Destroy (gameObject);
		}
	}
	
	public void OnDestroy () {
		_campaignsAvailableDelegate = null;
		_campaignsFetchFailedDelegate = null;
		_impactOpenDelegate = null;
		_impactCloseDelegate = null;
		_videoCompletedDelegate = null;
		_videoStartedDelegate = null;
	}

	/* Static Methods */
	
	public static bool isSupported () {
		return ApplifierImpactMobileExternal.isSupported();
	}
	
	public static string getSDKVersion () {
		return ApplifierImpactMobileExternal.getSDKVersion();
	}
	
	public static bool canShowCampaigns () {
		if (_campaignsAvailable)
			return ApplifierImpactMobileExternal.canShowCampaigns();
		
		return false;
	}
	
	public static bool canShowImpact () {
		if (_campaignsAvailable)
			return ApplifierImpactMobileExternal.canShowImpact();
		
		return false;
	}
	
	public static void setGamerSID (string sid) {
		_gamerSID = sid;
	}
	
	public static void stopAll () {
		ApplifierImpactMobileExternal.stopAll();
	}
	
	public static bool hasMultipleRewardItems () {
		if (_campaignsAvailable)
			return ApplifierImpactMobileExternal.hasMultipleRewardItems();
		
		return false;
	}
	
	public static List<string> getRewardItemKeys () {
		List<string> retList = new List<string>();
		
		if (_campaignsAvailable) {
			string keys = ApplifierImpactMobileExternal.getRewardItemKeys();
			retList = new List<string>(keys.Split(';'));
		}
		
		return retList;
	}
	
	public static string getDefaultRewardItemKey () {
		if (_campaignsAvailable) {
			return ApplifierImpactMobileExternal.getDefaultRewardItemKey();
		}
		
		return "";
	}
	
	public static string getCurrentRewardItemKey () {
		if (_campaignsAvailable) {
			return ApplifierImpactMobileExternal.getCurrentRewardItemKey();
		}
		
		return "";
	}
	
	public static bool setRewardItemKey (string rewardItemKey) {
		if (_campaignsAvailable) {
			return ApplifierImpactMobileExternal.setRewardItemKey(rewardItemKey);
		}
		
		return false;
	}
	
	public static void setDefaultRewardItemAsRewardItem () {
		if (_campaignsAvailable) {
			ApplifierImpactMobileExternal.setDefaultRewardItemAsRewardItem();
		}
	}
	
	public static string getRewardItemNameKey () {
		if (_rewardItemNameKey == null || _rewardItemNameKey.Length == 0) {
			fillRewardItemKeyData();
		}
		
		return _rewardItemNameKey;
	}
	
	public static string getRewardItemPictureKey () {
		if (_rewardItemPictureKey == null || _rewardItemPictureKey.Length == 0) {
			fillRewardItemKeyData();
		}
		
		return _rewardItemPictureKey;
	}
	
	public static Dictionary<string, string> getRewardItemDetailsWithKey (string rewardItemKey) {
		Dictionary<string, string> retDict = new Dictionary<string, string>();
		string rewardItemDataString = "";
		
		if (_campaignsAvailable) {
			rewardItemDataString = ApplifierImpactMobileExternal.getRewardItemDetailsWithKey(rewardItemKey);
			
			if (rewardItemDataString != null) {
				List<string> splittedData = new List<string>(rewardItemDataString.Split(';'));
				ApplifierImpactMobileExternal.Log("UnityAndroid: getRewardItemDetailsWithKey() rewardItemDataString=" + rewardItemDataString);
				
				if (splittedData.Count == 2) {
					retDict.Add(getRewardItemNameKey(), splittedData.ToArray().GetValue(0).ToString());
					retDict.Add(getRewardItemPictureKey(), splittedData.ToArray().GetValue(1).ToString());
				}
			}
		}
		
		return retDict;
	}
	
	public static bool showImpact () {
		if (!_impactOpen && _campaignsAvailable) {
			ApplifierImpactMobile instance = SharedInstance;
			
			if(instance) {
				bool animated = false;
				bool noOfferscreen = false;
				bool videoUsesDeviceOrientation = false;
				bool muteVideoSounds = false;
				string gamerSID = _gamerSID;
				
				if (instance != null) {
					animated = instance.openAnimated;
					noOfferscreen = instance.noOfferscreen;
					videoUsesDeviceOrientation = instance.videoUsesDeviceOrientation;
					muteVideoSounds = instance.muteVideoSounds;
					
					ApplifierImpactMobileExternal.Log("UnityAndroid: " + muteVideoSounds + ", " + videoUsesDeviceOrientation);
				}
				
				if (ApplifierImpactMobileExternal.showImpact(animated, noOfferscreen, gamerSID, muteVideoSounds, videoUsesDeviceOrientation)) {				
					if (_impactOpenDelegate != null)
						_impactOpenDelegate();
					
					_impactOpen = true;
					_savedTimeScale = Time.timeScale;
					_savedAudioVolume = AudioListener.volume;
					AudioListener.pause = true;
					AudioListener.volume = 0;
					Time.timeScale = 0;
				}
			}
		}
		
		return false;
	}
	
	public static void hideImpact () {
		if (_impactOpen) {
			ApplifierImpactMobileExternal.hideImpact();
		}
	}

	private static void fillRewardItemKeyData () {
		string keyData = ApplifierImpactMobileExternal.getRewardItemDetailsKeys();
		
		if (keyData != null && keyData.Length > 2) {
			List<string> splittedKeyData = new List<string>(keyData.Split(';'));
			_rewardItemNameKey = splittedKeyData.ToArray().GetValue(0).ToString();
			_rewardItemPictureKey = splittedKeyData.ToArray().GetValue(1).ToString();
		}
	}

	/* Events */
	
	public void onImpactClose () {
		_impactOpen = false;
		AudioListener.pause = false;
		AudioListener.volume = _savedAudioVolume;
		Time.timeScale = _savedTimeScale;
		
		if (_impactCloseDelegate != null)
			_impactCloseDelegate();
		
		ApplifierImpactMobileExternal.Log("onImpactClose");
	}
	
	public void onImpactOpen () {
		ApplifierImpactMobileExternal.Log("onImpactOpen");
	}
	
	public void onVideoStarted () {
		if (_videoStartedDelegate != null)
			_videoStartedDelegate();
		
		ApplifierImpactMobileExternal.Log("onVideoStarted");
	}
	
	public void onVideoCompleted (string rewardItemKey) {
		if (_videoCompletedDelegate != null)
			_videoCompletedDelegate(rewardItemKey);
		
		ApplifierImpactMobileExternal.Log("onVideoCompleted: " + rewardItemKey);
	}
	
	public void onCampaignsAvailable () {
		_campaignsAvailable = true;
		if (_campaignsAvailableDelegate != null)
			_campaignsAvailableDelegate();
			
		ApplifierImpactMobileExternal.Log("onCampaignsAvailable");
	}

	public void onCampaignsFetchFailed () {
		_campaignsAvailable = false;
		if (_campaignsFetchFailedDelegate != null)
			_campaignsFetchFailedDelegate();
		
		ApplifierImpactMobileExternal.Log("onCampaignsFetchFailed");
	}
}
