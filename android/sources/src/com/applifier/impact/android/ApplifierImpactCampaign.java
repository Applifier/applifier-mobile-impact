package com.applifier.impact.android;

import java.io.File;

import org.json.JSONObject;

import android.util.Log;

public class ApplifierImpactCampaign {
	private JSONObject _campaignJson = null;
	private String[] _requiredKeys = new String[]{"v", "s", "id"};
	
	public ApplifierImpactCampaign () {		
	}
	
	public ApplifierImpactCampaign (JSONObject fromJSON) {
		_campaignJson = fromJSON;
	}
	
	@Override
	public String toString () {
		return "(ID: " + getCampaignId() + ", STATUS: " + getCampaignStatus() + ", URL: " + getVideoUrl() + ")"; 
	}
	
	public String getCampaignId () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("id");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getCampaignId: This should not happen!");
			}
		}
		
		return null;
	}
	
	public String getCampaignStatus () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("s");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getCampaignStatus: This should not happen!");
			}
		}
		
		return null;
	}
	
	public String getVideoUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("v");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getVideoUrl: This should not happen!");
			}
		}
		
		return null;
	}
	
	public String getVideoFilename () {
		if (checkDataIntegrity()) {
			try {
				File videoFile = new File(_campaignJson.getString("v"));
				return videoFile.getName();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getVideoFilename: This should not happen!");
			}
		}
		
		return null;
	}
	
	public boolean hasValidData () {
		return checkDataIntegrity();
	}
	
	/* INTERNAL METHODS */
	
	private boolean checkDataIntegrity () {
		if (_campaignJson != null) {
			for (String key : _requiredKeys) {
				if (!_campaignJson.has(key)) {
					return false;
				}
			}
			
			return true;
		}
		return false;
	}
}
