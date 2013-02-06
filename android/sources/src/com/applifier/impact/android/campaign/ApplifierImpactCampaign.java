package com.applifier.impact.android.campaign;

import java.io.File;

import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

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
	private String[] _requiredKeys = new String[] {
			ApplifierImpactConstants.IMPACT_CAMPAIGN_ENDSCREEN_KEY, 
			ApplifierImpactConstants.IMPACT_CAMPAIGN_CLICKURL_KEY, 
			ApplifierImpactConstants.IMPACT_CAMPAIGN_PICTURE_KEY, 
			ApplifierImpactConstants.IMPACT_CAMPAIGN_TRAILER_DOWNLOADABLE_KEY, 
			ApplifierImpactConstants.IMPACT_CAMPAIGN_TRAILER_STREAMING_KEY,
			ApplifierImpactConstants.IMPACT_CAMPAIGN_GAME_ID_KEY,
			ApplifierImpactConstants.IMPACT_CAMPAIGN_GAME_NAME_KEY,
			ApplifierImpactConstants.IMPACT_CAMPAIGN_ID_KEY,
			ApplifierImpactConstants.IMPACT_CAMPAIGN_TAGLINE_KEY};
	
	private ApplifierImpactCampaignStatus _campaignStatus = ApplifierImpactCampaignStatus.READY;
	
	public ApplifierImpactCampaign () {		
	}
	
	public ApplifierImpactCampaign (JSONObject fromJSON) {
		_campaignJson = fromJSON;
	}
	
	@Override
	public String toString () {
		return "<ID: " + getCampaignId() + ", STATUS: " + getCampaignStatus().toString() + ", URL: " + getVideoUrl() + ">"; 
	}
	
	public JSONObject toJson () {
		JSONObject retObject = _campaignJson;
		
		try {
			retObject.put("status", getCampaignStatus().toString());
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Error creating campaign JSON", this);
			return null;
		}
		
		return retObject;
	}
	
	public Boolean shouldCacheVideo () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getBoolean(ApplifierImpactConstants.IMPACT_CAMPAIGN_CACHE_VIDEO_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("shouldCacheVideo: key not found, returning false", this);
			}			
		}
		return false;
	}

	public String getEndScreenUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_ENDSCREEN_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getEndScreenUrl: This should not happen!", this);
			}
		}
		
		return null;		
	}
	
	public String getPicture () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_PICTURE_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getPicture: This should not happen!", this);
			}
		}
		
		return null;		
	}
	
	public String getCampaignId () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_ID_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getCampaignId: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getGameId () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_GAME_ID_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getGameId: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getGameName () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_GAME_NAME_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getGameName: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getVideoUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_TRAILER_DOWNLOADABLE_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getVideoUrl: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getVideoStreamUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_TRAILER_STREAMING_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getVideoStreamUrl: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getClickUrl () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_CLICKURL_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getClickUrl: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getVideoFilename () {
		if (checkDataIntegrity()) {
			try {
				File videoFile = new File(_campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_TRAILER_DOWNLOADABLE_KEY));
				return getCampaignId() + "-" + videoFile.getName();
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getVideoFilename: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getTagLine () {
		if (checkDataIntegrity()) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_TAGLINE_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getTagLine: This should not happen!", this);
			}
		}
		
		return null;
	}
	
	public String getStoreId () {
		if (_campaignJson.has(ApplifierImpactConstants.IMPACT_CAMPAIGN_STOREID_KEY)) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_STOREID_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getStoreId: Was supposed to use ApplifierImpactConstants.IMPACT_CAMPAIGN_STOREID_KEY but " + e.getMessage() + " occured", this);
			}
		}
		if (_campaignJson.has(ApplifierImpactConstants.IMPACT_CAMPAIGN_ITUNESID_KEY)) {
			try {
				return _campaignJson.getString(ApplifierImpactConstants.IMPACT_CAMPAIGN_ITUNESID_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("getStoreId: Was supposed to use ApplifierImpactConstants.IMPACT_CAMPAIGN_ITUNESID_KEY but " + e.getMessage() + " occured", this);
			}
		}
		
		return null;
	}
	
	public ApplifierImpactCampaignStatus getCampaignStatus () {
		return _campaignStatus;
	}
	
	public void setCampaignStatus (ApplifierImpactCampaignStatus status) {
		_campaignStatus = status;
	}
	
	public Boolean isViewed () {
		if (_campaignStatus == ApplifierImpactCampaignStatus.VIEWED)
			return true;
		
		return false;
	}
	
	public boolean hasValidData () {
		return checkDataIntegrity();
	}
	
	public void clearData () {
		_campaignJson = null;
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
