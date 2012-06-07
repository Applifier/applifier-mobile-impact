package com.applifier.impact.android.cache;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;

public class ApplifierImpactWebData {
	private JSONObject _videoPlan = null;
	
	public ApplifierImpactWebData () {
		
	}
	
	public JSONObject getVideoPlan () {
		return _videoPlan;
	}
	
	public int getCampaignAmount () {
		if (_videoPlan == null) return 0;
		
		if (_videoPlan.has("va")) {
			try {
				return _videoPlan.getJSONArray("va").length();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Couldn't resolve video amount");
				return 0;
			}
		}
		
		return 0;
	}
	
	public boolean initVideoPlan (JSONObject cacheManifest) {		
		JSONObject data = new JSONObject();
		JSONArray campaignIds = null;
		ArrayList<String> cachedCampaignIds = ApplifierImpact.cachemanifest.getCachedCampaignIds();
		//Log.d(ApplifierImpactProperties.LOG_NAME, cachedCampaignIds.toString());
		
		if (cachedCampaignIds != null && cachedCampaignIds.size() > 0) {
			campaignIds = new JSONArray();
			
			for (String id : cachedCampaignIds) {
				campaignIds.put(id);
			}
		}
		
		try {
			data.put("c", campaignIds);
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON");
			return false;
		}
		
		String cachedCampaignData = null;
		
		if (data != null && campaignIds != null && campaignIds.length() > 0) {
			cachedCampaignData = data.toString();
			Log.d(ApplifierImpactProperties.LOG_NAME, cachedCampaignData);
		}
					
		// TODO: Send campaign ID's with the request
		
		/*
		URL yahoo = new URL("http://www.yahoo.com/");
		BufferedReader in = new BufferedReader(
		            new InputStreamReader(
		            yahoo.openStream()));

		String inputLine;

		while ((inputLine = in.readLine()) != null)
		    System.out.println(inputLine);

		in.close();*/
		
		JSONArray campaignstatus = new JSONArray();
		
		JSONArray videos = new JSONArray();
		JSONObject tmpvideo = null;
		
		try {
			tmpvideo = new JSONObject();
			tmpvideo.put("v", "http://quake.everyplay.fi/~bluesun/testvideos/video5.mp4");
			tmpvideo.put("s", "Ready");
			tmpvideo.put("id", "a5");
			videos.put(tmpvideo);
			
			/*
			tmpvideo = new JSONObject();
			tmpvideo.put("v", "http://quake.everyplay.fi/~bluesun/testvideos/video2.mp4");
			tmpvideo.put("s", "blaa2");
			tmpvideo.put("id", "a2");
			videos.put(tmpvideo);
	
			tmpvideo = new JSONObject();
			tmpvideo.put("v", "http://quake.everyplay.fi/~bluesun/testvideos/video3.mp4");
			tmpvideo.put("s", "blaa3");
			tmpvideo.put("id", "a3");
			videos.put(tmpvideo);
			*/
	
			_videoPlan = new JSONObject();
			_videoPlan.put("va", videos);
			
			/*
			tmpvideo = new JSONObject();
			tmpvideo.put("v", "http://quake.everyplay.fi/~bluesun/testvideos/video1.mp4");
			tmpvideo.put("s", "update");
			tmpvideo.put("id", "a1");
			campaignstatus.put(tmpvideo);
			_videoPlan.put("cs", campaignstatus);
			*/
			
			Log.d(ApplifierImpactProperties.LOG_NAME, _videoPlan.toString(4));
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Great error!");
			return false;
		}
		
		return true;
	}
}
