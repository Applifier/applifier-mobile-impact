package com.applifier.impact.android.webapp;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.data.ApplifierImpactDevice;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactInstrumentation {

	private static ArrayList<Map<String, JSONObject>> _unsentEvents = null;
	
	private static JSONObject mapToJSON (Map<String, Object> mapWithValues) {
		if (mapWithValues != null) {
			JSONObject retJsonObject = new JSONObject();
			
			Set<String> keySet = mapWithValues.keySet();
			Iterator<String> i = keySet.iterator();
			while (i.hasNext()) {
				String key = i.next();
				
				if (mapWithValues.containsKey(key) && mapWithValues.get(key) != null) {
					try {
						retJsonObject.put(key, mapWithValues.get(key));
					}
					catch (Exception e) {
						ApplifierImpactUtils.Log("Could not add value: " + key, ApplifierImpactInstrumentation.class);
					}
				}
			}
			
			return retJsonObject;
		}
		
		return null;
	}
	
	private static JSONObject mergeJSON (JSONObject json1, JSONObject json2) {
		if (json1 != null && json2 != null) {
			Iterator keyIterator = json2.keys();
			while (keyIterator.hasNext()) {
				try {
					String key = keyIterator.next().toString();
					Object value = json2.get(key);
					json1.put(key, value);
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Problems creating JSON", ApplifierImpactInstrumentation.class);
				}
			}
			
			return json1;
		}
		
		if (json1 != null)
			return json1;		
		else if (json2 != null)
			return json2;
		
		return null;
	}
	
	private static JSONObject getBasicGAVideoProperties (ApplifierImpactCampaign campaignPlaying) {
		if (campaignPlaying != null) {
			String videoPlayType = ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOPLAY_HLSL;
			
			if (campaignPlaying.shouldCacheVideo() && ApplifierImpactUtils.canUseExternalStorage()) {
				videoPlayType = ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOPLAY_CACHED;
			}
			
			String connectionType = ApplifierImpactDevice.getConnectionType();
			
			JSONObject retJsonObject = new JSONObject();
			
			try {
				retJsonObject.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOPLAYBACKTYPE_KEY, videoPlayType);
				retJsonObject.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_CONNECTIONTYPE_KEY, connectionType);
				retJsonObject.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_CAMPAIGNID_KEY, campaignPlaying.getCampaignId());
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not create instrumentation JSON", ApplifierImpactInstrumentation.class);
				return null;
			}
			
			return retJsonObject;
		}
		
		return null;
	}
	
	private static void handleUnsentEvents () {
		sendGAInstrumentationEvents();
	}
	
	private static void sendGAInstrumentationEvents () {
		JSONObject finalData = null;
		JSONArray wrapArray = new JSONArray();
		JSONObject finalEvents = new JSONObject();
		
		if (_unsentEvents != null) {
			for (Map<String, JSONObject> map : _unsentEvents) {
				finalData = new JSONObject();
				String eventType = map.keySet().iterator().next();
				JSONObject data = map.get(eventType);
				
				try {
					finalData.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_TYPE_KEY, eventType);
					finalData.put("data", data);
				}
				catch (Exception e) {
					continue;
				}
				
				wrapArray.put(finalData);
				
				try {
					finalEvents.put("events", wrapArray);
				}
				catch (Exception e) {
				}
			}
			
			if (ApplifierImpact.mainview != null && ApplifierImpact.mainview.webview != null && ApplifierImpact.mainview.webview.isWebAppLoaded()) {
				ApplifierImpactUtils.Log("Sending to webapp!", ApplifierImpactInstrumentation.class);
				ApplifierImpact.mainview.webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_KEY, finalEvents);
				_unsentEvents.clear();
				_unsentEvents = null;
			}
		}
	}
	
	private static void sendGAInstrumentationEvent (String eventType, JSONObject data) {
		
		JSONObject finalData = new JSONObject();
		JSONArray wrapArray = new JSONArray();
		JSONObject events = new JSONObject();
		
		try {
			finalData.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_TYPE_KEY, eventType);
			finalData.put("data", data);
			wrapArray.put(finalData);
			events.put("events", wrapArray);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Couldn't create final data", ApplifierImpactInstrumentation.class);
		}
		
		if (ApplifierImpact.mainview != null && ApplifierImpact.mainview.webview != null && ApplifierImpact.mainview.webview.isWebAppLoaded()) {
			ApplifierImpactUtils.Log("Sending to webapp!", ApplifierImpactInstrumentation.class);
			ApplifierImpact.mainview.webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_KEY, events);
		}
		else {
			ApplifierImpactUtils.Log("WebApp not initialized, could not send event!", ApplifierImpactInstrumentation.class);
			
			if (_unsentEvents == null) {
				_unsentEvents = new ArrayList<Map<String,JSONObject>>();
			}
			
			Map <String, JSONObject> tmpData = new HashMap<String, JSONObject>();
			tmpData.put(eventType, data);
			_unsentEvents.add(tmpData);
		}
	}
	
	public static void gaInstrumentationVideoPlay (ApplifierImpactCampaign campaignPlaying, Map<String, Object> additionalValues) {
		JSONObject data = getBasicGAVideoProperties(campaignPlaying);
		data = mergeJSON(data, mapToJSON(additionalValues));
		handleUnsentEvents();
		sendGAInstrumentationEvent(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_TYPE_VIDEOPLAY, data);
	}
	
	public static void gaInstrumentationVideoError (ApplifierImpactCampaign campaignPlaying, Map<String, Object> additionalValues) {
		JSONObject data = getBasicGAVideoProperties(campaignPlaying);
		data = mergeJSON(data, mapToJSON(additionalValues));
		handleUnsentEvents();
		sendGAInstrumentationEvent(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_TYPE_VIDEOERROR, data);
	}
	
	public static void gaInstrumentationVideoAbort (ApplifierImpactCampaign campaignPlaying, Map<String, Object> additionalValues) {
		JSONObject data = getBasicGAVideoProperties(campaignPlaying);
		data = mergeJSON(data, mapToJSON(additionalValues));
		handleUnsentEvents();
		sendGAInstrumentationEvent(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_TYPE_VIDEOABORT, data);		
	}
	
	public static void gaInstrumentationVideoCaching (ApplifierImpactCampaign campaignPlaying, Map<String, Object> additionalValues) {
		JSONObject data = getBasicGAVideoProperties(campaignPlaying);
		data = mergeJSON(data, mapToJSON(additionalValues));
		handleUnsentEvents();
		sendGAInstrumentationEvent(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_TYPE_VIDEOCACHING, data);				
	}
}
