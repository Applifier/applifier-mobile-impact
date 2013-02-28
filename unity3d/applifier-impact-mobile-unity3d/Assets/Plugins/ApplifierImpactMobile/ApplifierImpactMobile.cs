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
	private static string _gameObjectName = null;
	private static float _savedTimeScale = 1f;
	private static string _gamerSID = null;
	
	public void Awake () {
		this.init(this.gameId, this.testModeEnabled, this.debugModeEnabled);
	}
	
	public void init (string gameId, bool testModeEnabled, bool debugModeEnabled) {
		if (!_initRun) {
			_gameObjectName = gameObject.name;
			_initRun = true;
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
	
	public static void showImpact () {
		if (!_impactOpen && _campaignsAvailable) {
			ApplifierImpactMobile instance = getCurrentInstance();
			
			bool animated = false;
			bool noOfferscreen = false;
			string gamerSID = _gamerSID;
			
			if (instance != null) {
				animated = instance.openAnimated;
				noOfferscreen = instance.noOfferscreen;
			}
			
			ApplifierImpactMobileExternal.showImpact(animated, noOfferscreen, "");
		}
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
		ApplifierImpactMobileExternal.Log("onImpactClose");
	}
	
	public void onImpactOpen () {
		_impactOpen = true;
		_savedTimeScale = Time.timeScale;
		AudioListener.pause = true;
		Time.timeScale = 0;
		ApplifierImpactMobileExternal.Log("onImpactOpen");
	}
	
	public void onVideoStarted () {
		ApplifierImpactMobileExternal.Log("onVideoStarted");
	}
	
	public void onVideoCompleted (string rewardItemKey) {
		ApplifierImpactMobileExternal.Log("onVideoCompleted: " + rewardItemKey);
	}
	
	public void onCampaignsAvailable () {
		_campaignsAvailable = true;
		ApplifierImpactMobileExternal.Log("onCampaignsAvailable");
	}

	public void onCampaignsFetchFailed () {
		_campaignsAvailable = false;
		ApplifierImpactMobileExternal.Log("onCampaignsFetchFailed");
	}
}
