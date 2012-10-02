package com.applifier.impact.android.campaign;

import java.io.File;

import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpactProperties;

import android.util.Log;

public class ApplifierImpactCampaign {
	
	public enum ApplifierImpactCampaignStatus { READY, VIEWED, PANIC;
		@Override
		public String toString () {
			String output = name().toString().toLowerCase();
			return output;
		}
		
		public static ApplifierImpactCampaignStatus getValueOf (String status) {
			if (ApplifierImpactCampaignStatus.READY.toString().equals(status.toLowerCase()))
				return ApplifierImpactCampaignStatus.READY;
			else if (ApplifierImpactCampaignStatus.VIEWED.toString().equals(status.toLowerCase()))
				return ApplifierImpactCampaignStatus.VIEWED;
			else
				return ApplifierImpactCampaignStatus.PANIC;
		}
	};
	
	private JSONObject _campaignJson = null;
	private String[] _requiredKeys = new String[]{"id", "gameId", "trailerDownloadable", "trailerStreaming", "clickUrl"};
	
	public ApplifierImpactCampaign () {		
	}
	
	public ApplifierImpactCampaign (JSONObject fromJSON) {
		_campaignJson = fromJSON;
	}
	
	@Override
	public String toString () {
		return "(ID: " + getCampaignId() + ", STATUS: " + getCampaignStatus().toString() + ", URL: " + getVideoUrl() + ")"; 
	}
	
	public JSONObject toJson () {
		JSONObject retObject = _campaignJson;
		
		try {
			retObject.put("status", getCampaignStatus().toString());
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Error creating campaign JSON");
			return null;
		}
		
		return retObject;
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
	
	public String getGameId () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("gameId");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getGameId: This should not happen!");
			}
		}
		
		return null;
	}
	
	public ApplifierImpactCampaignStatus getCampaignStatus () {
		/*
		if (checkDataIntegrity()) {
			try {
				return ApplifierImpactCampaignStatus.getValueOf(_campaignJson.getString("status"));
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getCampaignStatus: This should not happen!");
			}
		}*/
		return ApplifierImpactCampaignStatus.getValueOf("ready");
	}
	
	public void setCampaignStatus (ApplifierImpactCampaignStatus status) {
		if (checkDataIntegrity()) {
			try {
				_campaignJson.put("status", status.toString());
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "setCampaignStatus: This should not happen!");
			}
		}
	}
	
	public String getVideoStreamUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("trailerStreaming");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getVideoStreamUrl: This should not happen!");
			}
		}
		
		return null;
	}
	
	public String getClickUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("clickUrl");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "getClickUrl: This should not happen!");
			}
		}
		
		return null;
	}
	
	public String getVideoUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString("trailerDownloadable");
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
				File videoFile = new File(_campaignJson.getString("trailerDownloadable"));
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
