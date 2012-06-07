package com.applifier.impact.android;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import com.applifier.impact.android.campaign.ApplifierImpactCampaign;

import android.os.Environment;
import android.util.Log;

public class ApplifierImpactUtils {
	
	public static ArrayList<ApplifierImpactCampaign> createCampaignsFromJson (JSONObject json) {
		if (json != null && json.has("va")) {
			ArrayList<ApplifierImpactCampaign> campaignData = new ArrayList<ApplifierImpactCampaign>();
			JSONArray va = null;
			JSONObject currentCampaign = null;
			
			try {
				va = json.getJSONArray("va");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON");
			}
			
			for (int i = 0; i < va.length(); i++) {
				try {
					currentCampaign = va.getJSONObject(i);
					campaignData.add(new ApplifierImpactCampaign(currentCampaign));
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON");
				}				
			}
			
			return campaignData;
		}
		
		return null;
	}
	
	public static ArrayList<ApplifierImpactCampaign> mergeCampaignLists (ArrayList<ApplifierImpactCampaign> list1, ArrayList<ApplifierImpactCampaign> list2) {
		ArrayList<ApplifierImpactCampaign> mergedData = new ArrayList<ApplifierImpactCampaign>();
		
		if (list1 == null || list1.size() == 0) return list2;
		if (list2 == null || list2.size() == 0) return list1;
		
		if (list1 != null && list2 != null) {
			mergedData.addAll(list1);
			for (ApplifierImpactCampaign list1Campaign : list1) {
				ApplifierImpactCampaign inputCampaign = null;
				boolean match = false;
				for (ApplifierImpactCampaign list2Campaign : list2) {
					inputCampaign = list2Campaign;
					if (list1Campaign.getCampaignId().equals(list2Campaign.getCampaignId())) {
						match = true;
						break;
					}
				}
				
				if (!match)
					mergedData.add(inputCampaign);
			}
			
			return mergedData;
		}
		
		return null;
	}
	
	public static String readFile (File fileToRead) {
		String fileContent = "";
		BufferedReader br = null;
		
		if (fileToRead.exists() && fileToRead.canRead()) {
			try {
				br = new BufferedReader(new FileReader(fileToRead));
				String line = null;
				
				while ((line = br.readLine()) != null) {
					fileContent = fileContent.concat(line);
				}
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem reading file: " + e.getMessage());
				return null;
			}
			
			try {
				br.close();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problem closing reader: " + e.getMessage());
			}
						
			return fileContent;
		}
		else {
			Log.d(ApplifierImpactProperties.LOG_NAME, "File did not exist or couldn't be read");
		}
		
		return null;
	}
	
	public static boolean writeFile (File fileToWrite, String content) {
		FileOutputStream fos = null;
		
		try {
			fos = new FileOutputStream(fileToWrite);
			fos.write(content.getBytes());
			fos.flush();
			fos.close();
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Could not write file: " + e.getMessage());
			return false;
		}
		
		Log.d(ApplifierImpactProperties.LOG_NAME, "Wrote file: " + fileToWrite.getAbsolutePath());
		
		return true;
	}
	
	public static JSONObject createJsonFromCampaigns (ArrayList<ApplifierImpactCampaign> campaignList) {
		JSONObject retJson = new JSONObject();
		JSONArray campaigns = new JSONArray();
		JSONObject currentCampaign = null;
		
		try {
			for (ApplifierImpactCampaign campaign : campaignList) {
				currentCampaign = campaign.toJson();
				
				if (currentCampaign != null)
					campaigns.put(currentCampaign);
			}
			
			retJson.put("va", campaigns);
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Error while creating JSON from Campaigns");
		}
		
		// TODO: Malformed JSON possibility to f*** up stuff
		
		return retJson;
	}
	
	public static String getCacheDirectory () {
		return Environment.getExternalStorageDirectory().toString() + "/" + ApplifierImpactProperties.CACHE_DIR_NAME;
	}
	
	public static ArrayList<ApplifierImpactCampaign> createPruneList (ArrayList<ApplifierImpactCampaign> fromList, ArrayList<ApplifierImpactCampaign> substractionList) {
		if (fromList == null || substractionList == null) return null;
		
		ArrayList<ApplifierImpactCampaign> pruneList = null;
		
		for (ApplifierImpactCampaign fromCampaign : fromList) {
			boolean match = false;
			
			for (ApplifierImpactCampaign substractionCampaign : substractionList) {
				if (fromCampaign.getCampaignId().equals(substractionCampaign.getCampaignId())) {
					match = true;
					break;
				}					
			}
			
			if (match)
				continue;
			
			if (pruneList == null)
				pruneList = new ArrayList<ApplifierImpactCampaign>();
			
			pruneList.add(fromCampaign);
		}
		
		return pruneList;
	}
}
