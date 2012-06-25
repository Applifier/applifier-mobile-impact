package com.applifier.impact.android.cache;

import java.io.File;
import java.util.ArrayList;

import org.json.JSONObject;

import android.util.Log;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;

public class ApplifierImpactCacheManifest {
	
	private JSONObject _manifestJson = null;
	private String _manifestContent = "";
	private ArrayList<ApplifierImpactCampaign> _cachedCampaigns = null;
	
	
	public ApplifierImpactCacheManifest () {
		readCacheManifest();
		createCampaignsFromManifest();
	}
	
	public int getCachedCampaignAmount () {
		if (_cachedCampaigns == null) 
			return 0;
		else
			return _cachedCampaigns.size();
	}
	
	public ArrayList<String> getCachedCampaignIds () {
		if (_cachedCampaigns == null) 
			return null;
		else {
			ArrayList<String> retList = new ArrayList<String>();
			
			for (ApplifierImpactCampaign campaign : _cachedCampaigns) {
				if (campaign != null)
					retList.add(campaign.getCampaignId());
			}
			
			return retList;
		}
	}
	
	public void setCachedCampaigns (ArrayList<ApplifierImpactCampaign> campaigns) {
		_cachedCampaigns = campaigns;
		writeCurrentCacheManifest();
	}
	
	public ArrayList<ApplifierImpactCampaign> getCachedCampaigns () {
		return _cachedCampaigns;
	}
	
	public ArrayList<ApplifierImpactCampaign> getViewableCachedCampaigns () {
		ArrayList<ApplifierImpactCampaign> retList = new ArrayList<ApplifierImpactCampaign>();
		
		if (_cachedCampaigns != null) {
			for (ApplifierImpactCampaign campaign : _cachedCampaigns) {
				if (campaign.getCampaignStatus() != ApplifierImpactCampaignStatus.VIEWED && campaign.getCampaignStatus() != ApplifierImpactCampaignStatus.PANIC)
					retList.add(campaign);
			}
			
			return retList;
		}
		
		return null;
	}
	
	public ApplifierImpactCampaign getCachedCampaignById (String id) {
		if (id == null || _cachedCampaigns == null) 
			return null;
		else {
			for (ApplifierImpactCampaign campaign : _cachedCampaigns) {
				if (campaign.getCampaignId().equals(id))
					return campaign;
			}
		}
		
		return null;
	}
	
	public boolean removeCampaignFromManifest (String campaignId) {		
		if (campaignId == null || _cachedCampaigns == null) return false;
		
		ApplifierImpactCampaign currentCampaign = null;
		int indexOfCampaignToRemove = -1;
		
		for (int i = 0; i < _cachedCampaigns.size(); i++) {
			currentCampaign = _cachedCampaigns.get(i);
			
			if (currentCampaign.getCampaignId().equals(campaignId)) {
				indexOfCampaignToRemove = i;
				break;
			}
		}
		
		if (indexOfCampaignToRemove > -1) {
			_cachedCampaigns.remove(indexOfCampaignToRemove);
			writeCurrentCacheManifest();
			return true;
		}
		
		return false;
	}
	
	public boolean addCampaignToManifest (ApplifierImpactCampaign campaign) {
		if (campaign == null) return false;
		if (_cachedCampaigns == null)
			_cachedCampaigns = new ArrayList<ApplifierImpactCampaign>();
		
		if (getCachedCampaignById(campaign.getCampaignId()) == null) {
			_cachedCampaigns.add(campaign);
			writeCurrentCacheManifest();
			return true;
		}
		
		return false;
	}
	
	public boolean updateCampaignInManifest (ApplifierImpactCampaign campaign) {
		if (campaign == null || _cachedCampaigns == null) return false;

		int updateIndex = -1;
		ApplifierImpactCampaign cacheCampaign = getCachedCampaignById(campaign.getCampaignId());
		if (cacheCampaign != null)
			updateIndex = _cachedCampaigns.indexOf(cacheCampaign);
		
		if (updateIndex > -1) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating campaign: " + campaign.getCampaignId());
			_cachedCampaigns.set(updateIndex, campaign);
			writeCurrentCacheManifest();
			
			return true;
		}
			
		return false;
	}
	
	public boolean writeCurrentCacheManifest () {
		JSONObject manifestToWrite = ApplifierImpactUtils.createJsonFromCampaigns(_cachedCampaigns);
		
		if (manifestToWrite != null) {
			return ApplifierImpactUtils.writeFile(getFileForManifest(), manifestToWrite.toString());
		}
		else {
			return ApplifierImpactUtils.writeFile(getFileForManifest(), "");
		}
	}
	
	
	/* INTERNAL METHODS */
	
	private void createCampaignsFromManifest () {
		if (_manifestJson == null) return;		
		
		_cachedCampaigns = ApplifierImpactUtils.createCampaignsFromJson(_manifestJson);
	}
	
	private boolean readCacheManifest () {		
		File manifest = getFileForManifest();
		_manifestContent = ApplifierImpactUtils.readFile(manifest, false);
		
		if (_manifestContent != null) {
			try {
				_manifestJson = new JSONObject(_manifestContent);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem creating manifest json: " + e.getMessage());
				return false;
			}
			
			return true;
		}
		
		return false;
	}
	
	private File getFileForManifest () {
		return new File(ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactProperties.CACHE_MANIFEST_FILENAME);
	}
}