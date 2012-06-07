package com.applifier.impact.android.cache;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;

public class ApplifierImpactCacheManifest {
	private String _manifestDirectory = null;
	private JSONObject _manifestJson = null;
	private String _manifestContent = "";
	
	public ApplifierImpactCacheManifest (String manifestDir) {
		_manifestDirectory = manifestDir;
		readCacheManifest();
	}
	
	public JSONObject getCacheManifest () {
		return _manifestJson;
	}
	
	public int getCampaignAmount () {
		if (_manifestJson == null) return 0;
		
		if (_manifestJson.has("va")) {
			try {
				return _manifestJson.getJSONArray("va").length();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Couldn't resolve video amount");
				return 0;
			}
		}
		
		return 0;
	}
	
	public ArrayList<String> getCachedCampaignIds () {
		if (_manifestJson == null || !_manifestJson.has("va")) return null;
		
		ArrayList<String> retList = new ArrayList<String>();
		JSONArray va = null;
		JSONObject currentCampaign = null;
		String currentId = null;
		
		try {
			va = _manifestJson.getJSONArray("va");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed manifest");
			return null;
		}
		
		for (int i = 0; i < va.length(); i++) {
			currentId = null;
			
			try {
				currentCampaign = va.getJSONObject(i);
				currentId = currentCampaign.getString("id");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed manifest");
				continue;
			}
			
			if (currentId != null)
				retList.add(currentId);
		}
		
		return retList;
	}
	
	public JSONObject getCampaign (String id) {
		if (id == null) return null;
		
		if (_manifestJson != null && _manifestJson.has("va")) {
			JSONArray va = null;
			JSONObject campaign = null;
			String campaignId = null;
			
			try {
				va = _manifestJson.getJSONArray("va");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed manifest");
				return null;
			}
			
			for (int i = 0; i < va.length(); i++) {
				try {
					campaign = va.getJSONObject(i);
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed manifest");
					continue;
				}
				
				if (campaign != null && campaign.has("id")) {
					try {
						campaignId = campaign.getString("id");
					}
					catch (Exception e) {
						Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed manifest");
						continue;
					}
				}
				
				if (id.equals(campaignId))
					return campaign;
			}
		}
		
		return null;		
	}
	
	public boolean removeCampaignFromManifest (JSONObject campaign) {
		if (campaign == null) return false;
		
		JSONArray originalVa = null;
		JSONArray newVa = new JSONArray();
		JSONObject currentCampaign = null;
		String currentCampaignId = null;
		String targetCampaignId = null;
		
		try {			
			targetCampaignId = campaign.getString("id");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
			return false;
		}
		
		try {
			originalVa = _manifestJson.getJSONArray("va");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
			return false;
		}
		
		if (originalVa != null) {
			for (int i = 0; i < originalVa.length(); i++) {
				try {
					currentCampaign = originalVa.getJSONObject(i);
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Couldn't get current campaign index.");
					return false;
				}
				
				try {
					currentCampaignId = currentCampaign.getString("id");
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
					return false;
				}
				
				if (!currentCampaignId.equals(targetCampaignId)) {
					newVa.put(currentCampaign);
				}
			}
			
			try {
				_manifestJson.put("va", newVa);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
				return false;
			}
			
			writeCurrentCacheManifest();			
		}
		else {
			return false;
		}
				
		return true;
	}
	
	public boolean addCampaignToManifest (JSONObject campaign) {
		if (campaign == null) return false;
		
		File manifest = getFileForManifest();
		
		if (!manifest.exists() || _manifestJson == null || !_manifestJson.has("va")) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Preparing new cache manifest");
			prepareNewCacheManifest();
		}
		
		String campaignId = null;
		
		try {
			campaignId = campaign.getString("id");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
			return false;
		}
		
		if (_manifestJson != null && _manifestJson.has("va") && getCampaign(campaignId) == null) {
			try {
				_manifestJson.getJSONArray("va").put(campaign);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem creating JSON: " + e.getMessage());
				return false;
			}
		}
		
		writeCurrentCacheManifest();

		return true;
	}
	
	public boolean updateCampaignInManifest (JSONObject campaign) {
		if (campaign == null) return false;
				
		String campaignId = null;
		JSONObject manifestCampaign = null;
		
		if (campaign.has("id")) {
			try {
				campaignId = campaign.getString("id");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
				return false;
			}
			
			if (campaignId == null) return false;
			
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating campaign: " + campaignId);
			manifestCampaign = getCampaign(campaignId);
			
			if (manifestCampaign != null) {
				try {
					if (!manifestCampaign.getString("v").equals(campaign.getString("v")) && !ApplifierImpact.cachemanager.isFileCached(campaign.getString("v"))) {
						// TODO: Make check that the old video-file is not needed anymore by other campaigns and remove it
						// ApplifierImpact.cachemanager.removeCachedFile(manifestCampaign.getString("v"));
						
						// TODO: Do not call cacheFile from here, caching should be done in cachemanager
						ApplifierImpact.cachemanager.cacheFile(campaign.getString("v"), campaignId);
					}
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
					return false;				
				}
				
				try {
					manifestCampaign.put("s", campaign.getString("s"));
					manifestCampaign.put("v", campaign.getString("v"));
					Log.d(ApplifierImpactProperties.LOG_NAME, campaign.getString("s") + ", " + campaign.getString("v"));
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed cache manifest.");
					return false;
				}
				
				// TODO: Make check that you write cache only if the video file has not changed, if it has, wait for the write until download has finished
				writeCurrentCacheManifest();
			}
		}
		
		return false;
	}
	
	private boolean prepareNewCacheManifest () {
		_manifestJson = new JSONObject();
		JSONArray ja = new JSONArray();
		
		try {
			_manifestJson.put("va", ja);				
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Problem creating JSON: " + e.getMessage());
			return false;
		}
	
		return true;
	}

	private boolean readCacheManifest () {
		File manifest = getFileForManifest();
		BufferedReader br = null;
		
		if (manifest.exists() && manifest.canRead()) {
			try {
				br = new BufferedReader(new FileReader(manifest));
				String line = null;
				
				while ((line = br.readLine()) != null) {
					_manifestContent = _manifestContent.concat(line);
				}
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem reading cachemanifest: " + e.getMessage());
				return false;
			}
			
			try {
				_manifestJson = new JSONObject(_manifestContent);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem creating manifest json: " + e.getMessage());
				return false;
			}
			
			try {
				br.close();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem closing reader: " + e.getMessage());
			}
						
			return true;
		}
		else {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Cache manifest did not exist or couldn't be read");
		}
		
		return false;
	}
	
	private boolean writeCurrentCacheManifest () {
		FileOutputStream fos = null;
		
		try {
			fos = new FileOutputStream(getFileForManifest());
			String content = _manifestJson.toString();
			fos.write(content.getBytes());
			fos.flush();
			fos.close();
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Could not re-write cachemanifest: " + e.getMessage());
		}
		
		return true;
	}
	
	private File getFileForManifest () {
		return new File(_manifestDirectory + "/" + ApplifierImpactProperties.CACHE_MANIFEST_FILENAME);
	}
}