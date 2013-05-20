package com.applifier.impact.android.unity3d;

import java.lang.reflect.Method;
import java.util.HashMap;

import android.app.Activity;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.IApplifierImpactListener;

public class ApplifierImpactUnity3DWrapper implements IApplifierImpactListener {
	private Activity _startupActivity = null;
	private String _gameObject = null;
	private String _gameId = null;
	private Method _sendMessageMethod = null;
	private boolean _testMode = false;
	private boolean _debugMode = false;
	private static ApplifierImpact _applifierImpact = null;
	private static Boolean _constructed = false;
	private static Boolean _initialized = false;
	
	public ApplifierImpactUnity3DWrapper () {
		if (!_constructed) {
			_constructed = true;
	    	ApplifierImpactUtils.Log("ApplifierImpactUnity3DWrapper Constructor", this);
	        try {
	                Class<?> unityClass = Class.forName("com.unity3d.player.UnityPlayer");
	                Class<?> paramTypes[] = new Class[3];
	                paramTypes[0] = String.class;
	                paramTypes[1] = String.class;
	                paramTypes[2] = String.class;
	                _sendMessageMethod = unityClass.getDeclaredMethod("UnitySendMessage", paramTypes);
	        } 
	        catch (Exception e) {
	        	ApplifierImpactUtils.Log("Error getting class or method of com.unity3d.player.UnityPlayer, method UnitySendMessage(string, string, string). " + e.getLocalizedMessage(), this);
	        }
		}
	}
	
	
	// Public methods

	public boolean isSupported () {
		return ApplifierImpact.isSupported();
	}
	
	public String getSDKVersion () {
		return ApplifierImpact.getSDKVersion();
	}
	
	public void init (final String gameId, final Activity activity, boolean testMode, boolean debugMode, String gameObject) {
		if (!_initialized) {
			_initialized = true;
			_gameId = gameId;
			_gameObject = gameObject;
			_testMode = testMode;
			_debugMode = debugMode;
			
			if (_startupActivity == null)
				_startupActivity = activity;
			
			final ApplifierImpactUnity3DWrapper listener = this;
			
			try {
				_startupActivity.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						ApplifierImpact.setTestMode(_testMode);
						ApplifierImpact.setDebugMode(_debugMode);
						_applifierImpact = new ApplifierImpact(_startupActivity, _gameId, listener);
					}
				});
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Error occured while initializing impact", this);
			}
		}
	}
	
	public boolean showImpact (boolean openAnimated, boolean noOfferscreen, final String gamerSID, boolean muteVideoSounds, boolean useDeviceOrientationForVideo) {
		if (_applifierImpact != null && _applifierImpact.canShowCampaigns() && _applifierImpact.canShowImpact()) {
			HashMap<String, Object> params = new HashMap<String, Object>();
			params.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY, openAnimated);
			params.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, noOfferscreen);
			params.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS, muteVideoSounds);
			params.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION, useDeviceOrientationForVideo);
			
			if (gamerSID != null && gamerSID.length() > 0)
				params.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY, gamerSID);
			
			ApplifierImpactUtils.Log("Opening with: openAnimated=" + openAnimated + ", noOfferscreen=" + noOfferscreen + ", gamerSID=" + gamerSID + ", muteVideoSounds=" + muteVideoSounds + ", useDeviceOrientationForVideo=" + useDeviceOrientationForVideo, this);
			return _applifierImpact.showImpact(params);
		}
		
		return false;
	}
	
	public void hideImpact () {
		if (_applifierImpact == null) return;
		_applifierImpact.hideImpact();
	}
	
	public boolean canShowCampaigns () {
		if (_applifierImpact == null) return false;
		return _applifierImpact.canShowCampaigns();
	}
	
	public boolean canShowImpact () {
		if (_applifierImpact == null) return false;
		return _applifierImpact.canShowImpact();
	}
	
	public void stopAll () {
		if (_applifierImpact == null) return;
		_applifierImpact.stopAll();
	}
	
	public boolean hasMultipleRewardItems () {
		if (_applifierImpact == null) return false;
		return _applifierImpact.hasMultipleRewardItems();
	}
	
	public String getRewardItemKeys () {
		if (_applifierImpact == null || _applifierImpact.getRewardItemKeys() == null) return null;
		if (_applifierImpact.getRewardItemKeys().size() > 0) {
			String keys = "";
			for (String key : _applifierImpact.getRewardItemKeys()) {
				if (_applifierImpact.getRewardItemKeys().indexOf(key) > 0) {
					keys += ";";
				}
				keys += key;
			}
			
			return keys;
		}
		
		return null;
	}
	
	public String getDefaultRewardItemKey () {
		if (_applifierImpact == null) return "";
		return _applifierImpact.getDefaultRewardItemKey();
	}
	
	public String getCurrentRewardItemKey () {
		if (_applifierImpact == null) return "";
		return _applifierImpact.getCurrentRewardItemKey();
	}
	
	public boolean setRewardItemKey (String rewardItemKey) {
		if (_applifierImpact == null || rewardItemKey == null) return false;
		return _applifierImpact.setRewardItemKey(rewardItemKey);
	}
	
	public void setDefaultRewardItemAsRewardItem () {
		if (_applifierImpact == null) return;
		_applifierImpact.setDefaultRewardItemAsRewardItem();
	}
	
	public String getRewardItemDetailsWithKey (String rewardItemKey) {
		String retString = "";
		
		if (_applifierImpact == null) return "";
		if (_applifierImpact.getRewardItemDetailsWithKey(rewardItemKey) != null) {
			ApplifierImpactUtils.Log("Fetching reward data", this);
			
			@SuppressWarnings({ "unchecked", "rawtypes" })
			HashMap<String, String> rewardMap = (HashMap)_applifierImpact.getRewardItemDetailsWithKey(rewardItemKey);
			
			if (rewardMap != null) {
				retString = rewardMap.get(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_NAME_KEY);
				retString += ";" + rewardMap.get(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_PICTURE_KEY);
				return retString;
			}
			else {
				ApplifierImpactUtils.Log("Problems getting reward item details", this);
			}
		}
		else {
			ApplifierImpactUtils.Log("Could not find reward item details", this);
		}
		return "";
	}
	
    public String getRewardItemDetailsKeys () {
    	return String.format("%s;%s", ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_NAME_KEY, ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_PICTURE_KEY);
    }

	
	
	// IApplifierImpactListener
	
	@Override
	public void onImpactClose() {
		sendMessageToUnity3D("onImpactClose", null);
	}

	@Override
	public void onImpactOpen() {
		sendMessageToUnity3D("onImpactOpen", null);
	}

	@Override
	public void onVideoStarted() {
		sendMessageToUnity3D("onVideoStarted", null);
	}

	@Override
	public void onVideoCompleted(String rewardItemKey) {
		sendMessageToUnity3D("onVideoCompleted", rewardItemKey);
	}

	@Override
	public void onCampaignsAvailable() {
		sendMessageToUnity3D("onCampaignsAvailable", null);
	}

	@Override
	public void onCampaignsFetchFailed() {
		sendMessageToUnity3D("onCampaignsFetchFailed", null);
	}
	
    public void sendMessageToUnity3D(String methodName, String parameter) {
        // Unity Development build crashes if parameter is NULL
        if (parameter == null)
                parameter = "";

        if (_sendMessageMethod == null) {
        	ApplifierImpactUtils.Log("Cannot send message to Unity3D. Method is null", this);
        	return;
        }
        try {
        	ApplifierImpactUtils.Log("Sending message (" + methodName + ", " + parameter + ") to Unity3D", this);
        	_sendMessageMethod.invoke(null, _gameObject, methodName, parameter);
        } 
        catch (Exception e) {
        	ApplifierImpactUtils.Log("Can't invoke UnitySendMessage method. Error = "  + e.getLocalizedMessage(), this);
        }
    }
    
}
