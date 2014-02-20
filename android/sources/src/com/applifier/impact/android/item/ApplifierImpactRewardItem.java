package com.applifier.impact.android.item;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactRewardItem {
	private String _key = null;
	private String _name = null;
	private String _pictureURL = null;
	private JSONObject _rewardItemJSON = null;
	
	private String[] _requiredKeys = new String[] {
			ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY,
			ApplifierImpactConstants.IMPACT_REWARD_NAME_KEY,
			ApplifierImpactConstants.IMPACT_REWARD_PICTURE_KEY};
	
	public ApplifierImpactRewardItem (JSONObject fromJSON) {
		_rewardItemJSON = fromJSON;
		parseValues();
	}
	
	public String getKey () {
		return _key;
	}
	
	public String getName () {
		return _name;
	}
	
	public String getPictureUrl () {
		return _pictureURL;
	}
	
	public boolean hasValidData () {
		return checkDataIntegrity();
	}
	
	public void clearData () {
		_key = null;
		_name = null;
		_pictureURL = null;
		_rewardItemJSON = null;
		_requiredKeys = null;
	}
	
	public Map<String, String> getDetails () {
		Map<String, String> returnMap = new HashMap<String, String>();
		returnMap.put(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_NAME_KEY, getName());
		returnMap.put(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_PICTURE_KEY, getPictureUrl());
		return returnMap;
	}
	
	/* INTERNAL METHODS */
	
	private void parseValues () {
		try {
			_key = _rewardItemJSON.getString(ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY);
			_name = _rewardItemJSON.getString(ApplifierImpactConstants.IMPACT_REWARD_NAME_KEY);
			_pictureURL = _rewardItemJSON.getString(ApplifierImpactConstants.IMPACT_REWARD_PICTURE_KEY);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Problem parsing campaign values", this);
		}
	}
	
	private boolean checkDataIntegrity () {
		if (_rewardItemJSON != null) {
			for (String key : _requiredKeys) {
				if (!_rewardItemJSON.has(key)) {
					return false;
				}
			}
			
			return true;
		}
		return false;
	}
}
