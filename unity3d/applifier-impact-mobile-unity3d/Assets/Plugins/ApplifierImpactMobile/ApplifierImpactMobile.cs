using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ApplifierImpactMobile : MonoBehaviour {
	
	public bool showTestButton = false;
	public string gameId = "";
	public bool debugModeEnabled = false;
	public bool testModeEnabled = false;
	public bool openAnimated = false;
	public bool noOfferscreen = false;
	
	private static bool _campaignsAvailable = false;
	private static bool _initRun = false;
	private static bool _impactOpen = false;
	private static bool _gotAwake = false;
	private static string _gameObjectName = null;
	private static float _savedTimeScale = 1f;
	private static string _gamerSID = "";
	
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
	
	
	public void Awake () {
		if (_gotAwake == false) {
			_gotAwake = true;
			this.init(this.gameId, this.testModeEnabled, this.debugModeEnabled);
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
	
	public void init (string gameId, bool testModeEnabled, bool debugModeEnabled) {
		if (!_initRun) {
			_initRun = true;
			_gameObjectName = gameObject.name;
			ApplifierImpactMobileExternal.init(gameId, testModeEnabled, debugModeEnabled, _gameObjectName);
		}
	}
	
	
	/* Static Methods */
	
	public static ApplifierImpactMobile getCurrentInstance () {
		GameObject applifierImpact = GameObject.FindWithTag("ApplifierImpactMobile");
		ApplifierImpactMobile applifierImpactMobile = applifierImpact.GetComponent<ApplifierImpactMobile>();
		return applifierImpactMobile;
	}
	
	
	public static bool getTestButtonVisibility () {
		return getCurrentInstance().showTestButton;
	}
	
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
	
	public static Dictionary<string, string> getRewardItemDetailsWithKey (string rewardItemKey) {
		Dictionary<string, string> retDict = new Dictionary<string, string>();
		if (_campaignsAvailable) {
			retDict = ApplifierImpactMobileExternal.getRewardItemDetailsWithKey(rewardItemKey);
			return retDict;
		}
		
		return retDict;
	}
	
	public static bool showImpact () {
		if (!_impactOpen && _campaignsAvailable) {
			ApplifierImpactMobile instance = getCurrentInstance();
			
			bool animated = false;
			bool noOfferscreen = false;
			string gamerSID = _gamerSID;
			
			if (instance != null) {
				animated = instance.openAnimated;
				noOfferscreen = instance.noOfferscreen;
			}
			
			if (ApplifierImpactMobileExternal.showImpact(animated, noOfferscreen, gamerSID)) {				
				if (_impactOpenDelegate != null)
					_impactOpenDelegate();
				
				_impactOpen = true;
				_savedTimeScale = Time.timeScale;
				AudioListener.pause = true;
				Time.timeScale = 0;
			}
		}
		
		return false;
	}
	
	public static void hideImpact () {
		if (_impactOpen) {
			ApplifierImpactMobileExternal.hideImpact();
		}
	}
	
	
	/* Events */
	
	public void onImpactClose () {
		_impactOpen = false;
		AudioListener.pause = false;
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
