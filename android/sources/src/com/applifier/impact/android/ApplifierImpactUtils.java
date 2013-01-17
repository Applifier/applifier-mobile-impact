package com.applifier.impact.android;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

import android.os.Environment;
import android.util.Log;

public class ApplifierImpactUtils {
	public static ArrayList<ApplifierImpactCampaign> createCampaignsFromJson (JSONObject json) {
		if (json != null && json.has("campaigns")) {
			ArrayList<ApplifierImpactCampaign> campaignData = new ArrayList<ApplifierImpactCampaign>();
			JSONArray receivedCampaigns = null;
			JSONObject currentCampaign = null;
			
			try {
				receivedCampaigns = json.getJSONArray("campaigns");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactConstants.LOG_NAME, "Malformed JSON");
			}
			
			for (int i = 0; i < receivedCampaigns.length(); i++) {
				try {
					currentCampaign = receivedCampaigns.getJSONObject(i);
					campaignData.add(new ApplifierImpactCampaign(currentCampaign));
				}
				catch (Exception e) {
					Log.d(ApplifierImpactConstants.LOG_NAME, "Malformed JSON");
				}
			}
			
			return campaignData;
		}
		
		return null;
	}

	public static String readFile (File fileToRead, boolean addLineBreaks) {
		String fileContent = "";
		BufferedReader br = null;
		
		if (fileToRead.exists() && fileToRead.canRead()) {
			try {
				br = new BufferedReader(new FileReader(fileToRead));
				String line = null;
				
				while ((line = br.readLine()) != null) {
					fileContent = fileContent.concat(line);
					if (addLineBreaks)
						fileContent = fileContent.concat("\n");
				}
			}
			catch (Exception e) {
				Log.d(ApplifierImpactConstants.LOG_NAME, "Problem reading file: " + e.getMessage());
				return null;
			}
			
			try {
				br.close();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactConstants.LOG_NAME, "Problem closing reader: " + e.getMessage());
			}
						
			return fileContent;
		}
		else {
			Log.d(ApplifierImpactConstants.LOG_NAME, "File did not exist or couldn't be read");
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
			Log.d(ApplifierImpactConstants.LOG_NAME, "Could not write file: " + e.getMessage());
			return false;
		}
		
		Log.d(ApplifierImpactConstants.LOG_NAME, "Wrote file: " + fileToWrite.getAbsolutePath());
		
		return true;
	}
	
	public static void removeFile (String fileName) {
		File removeFile = new File (fileName);
		File cachedVideoFile = new File (ApplifierImpactUtils.getCacheDirectory() + "/" + removeFile.getName());
		
		if (cachedVideoFile.exists()) {
			if (!cachedVideoFile.delete())
				Log.d(ApplifierImpactConstants.LOG_NAME, "Could not delete: " + cachedVideoFile.getAbsolutePath());
			else
				Log.d(ApplifierImpactConstants.LOG_NAME, "Deleted: " + cachedVideoFile.getAbsolutePath());
		}
		else {
			Log.d(ApplifierImpactConstants.LOG_NAME, "File: " + cachedVideoFile.getAbsolutePath() + " doesn't exist.");
		}
	}
		
	public static ArrayList<ApplifierImpactCampaign> substractFromCampaignList (ArrayList<ApplifierImpactCampaign> fromList, ArrayList<ApplifierImpactCampaign> substractionList) {
		if (fromList == null) return null;
		if (substractionList == null) return fromList;
		
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
	
	public static String getCacheDirectory () {
		return Environment.getExternalStorageDirectory().toString() + "/" + ApplifierImpactConstants.CACHE_DIR_NAME;
	}
	
	public static File createCacheDir () {
		File tdir = new File (getCacheDirectory());
		tdir.mkdirs();
		return tdir;
	}
	
	public static boolean isFileRequiredByCampaigns (String fileName, ArrayList<ApplifierImpactCampaign> campaigns) {
		if (fileName == null || campaigns == null) return false;
		
		File seekFile = new File(fileName);
		
		for (ApplifierImpactCampaign campaign : campaigns) {
			File matchFile = new File(campaign.getVideoUrl());
			if (seekFile.getName().equals(matchFile.getName()))
				return true;
		}
		
		return false;
	}

	public static boolean isFileInCache (String fileName) {
		File targetFile = new File (fileName);
		File testFile = new File(getCacheDirectory() + "/" + targetFile.getName());
		return testFile.exists();
	}
}
