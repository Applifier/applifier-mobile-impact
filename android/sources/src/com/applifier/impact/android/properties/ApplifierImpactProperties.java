package com.applifier.impact.android.properties;

import java.net.URLEncoder;
import java.util.Map;

import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.data.ApplifierImpactDevice;

import android.app.Activity;

public class ApplifierImpactProperties {
	//public static String CAMPAIGN_DATA_URL = "http://192.168.1.246:3500/mobile/campaigns";
	public static String CAMPAIGN_DATA_URL = "https://impact.applifier.com/mobile/campaigns";
//	public static String CAMPAIGN_DATA_URL = "https://staging-impact.applifier.com/mobile/campaigns";
	public static String WEBVIEW_BASE_URL = null;
	public static String ANALYTICS_BASE_URL = null;
	public static String IMPACT_BASE_URL = null;
	public static String CAMPAIGN_QUERY_STRING = null;
	public static String IMPACT_GAME_ID = null;
	public static String IMPACT_GAMER_ID = null;
	public static String GAMER_SID = null;
	public static Boolean TESTMODE_ENABLED = false;
	public static Activity BASE_ACTIVITY = null;
	public static Activity CURRENT_ACTIVITY = null;
	public static ApplifierImpactCampaign SELECTED_CAMPAIGN = null;
	public static Boolean IMPACT_DEBUG_MODE = false;
	public static Map<String, Object> IMPACT_DEVELOPER_OPTIONS = null;
	public static int ALLOW_VIDEO_SKIP = 0;
	public static int ALLOW_BACK_BUTTON_SKIP = 0;
	
	public static String TEST_DATA = null;
	public static String TEST_URL = null;
	public static String TEST_JAVASCRIPT = null;
	public static Boolean RUN_WEBVIEW_TESTS = false;
	
	@SuppressWarnings("unused")
	private static Map<String, String> TEST_EXTRA_PARAMS = null; 

	public static final int MAX_NUMBER_OF_ANALYTICS_RETRIES = 5;
	public static final int MAX_BUFFERING_WAIT_SECONDS = 20;
	
	private static String _campaignQueryString = null; 
	
	private static void createCampaignQueryString () {
		String queryString = "?";
		
		//Mandatory params
		try {
			queryString = String.format("%s%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_DEVICEID_KEY, URLEncoder.encode(ApplifierImpactDevice.getAndroidId(), "UTF-8"));
			
			if (!ApplifierImpactDevice.getAndroidId().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_ANDROIDID_KEY, URLEncoder.encode(ApplifierImpactDevice.getAndroidId(), "UTF-8"));
			
			if (!ApplifierImpactDevice.getTelephonyId().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_TELEPHONYID_KEY, URLEncoder.encode(ApplifierImpactDevice.getTelephonyId(), "UTF-8"));
			
			if (!ApplifierImpactDevice.getAndroidSerial().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SERIALID_KEY, URLEncoder.encode(ApplifierImpactDevice.getAndroidSerial(), "UTF-8"));

			if (!ApplifierImpactDevice.getOpenUdid().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_OPENUDID_KEY, URLEncoder.encode(ApplifierImpactDevice.getOpenUdid(), "UTF-8"));
			
			if (!ApplifierImpactDevice.getMacAddress().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_MACADDRESS_KEY, URLEncoder.encode(ApplifierImpactDevice.getMacAddress(), "UTF-8"));

			if (!ApplifierImpactDevice.getOdin1Id().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_ODIN1ID_KEY, URLEncoder.encode(ApplifierImpactDevice.getOdin1Id(), "UTF-8"));
			
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_PLATFORM_KEY, "android");
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_GAMEID_KEY, URLEncoder.encode(ApplifierImpactProperties.IMPACT_GAME_ID, "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SDKVERSION_KEY, URLEncoder.encode(ApplifierImpactConstants.IMPACT_VERSION, "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SOFTWAREVERSION_KEY, URLEncoder.encode(ApplifierImpactDevice.getSoftwareVersion(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_HARDWAREVERSION_KEY, URLEncoder.encode(ApplifierImpactDevice.getHardwareVersion(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_DEVICETYPE_KEY, ApplifierImpactDevice.getDeviceType());
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_CONNECTIONTYPE_KEY, URLEncoder.encode(ApplifierImpactDevice.getConnectionType(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SCREENSIZE_KEY, ApplifierImpactDevice.getScreenSize());
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SCREENDENSITY_KEY, ApplifierImpactDevice.getScreenDensity());
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Problems creating campaigns query: " + e.getMessage() + e.getStackTrace().toString(), ApplifierImpactProperties.class);
		}
		
		if (TESTMODE_ENABLED) {
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_TEST_KEY, "true");
		}
		else {
			if (ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_ENCRYPTED_KEY, ApplifierImpactUtils.isDebuggable(ApplifierImpactProperties.CURRENT_ACTIVITY) ? "false" : "true");
			}
		}
		
		_campaignQueryString = queryString;
	}
	
	public static JSONObject getDeveloperOptionsAsJson () {
		if (IMPACT_DEVELOPER_OPTIONS != null) {
			JSONObject options = new JSONObject();
			
			boolean noOfferscreen = false;
			boolean openAnimated = false;
			boolean muteVideoSounds = false;
			boolean videoUsesDeviceOrientation = false;
			
			try {
				if (IMPACT_DEVELOPER_OPTIONS.containsKey(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY))
					noOfferscreen = (Boolean)IMPACT_DEVELOPER_OPTIONS.get(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY);
				
				options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, noOfferscreen);
				
				if (IMPACT_DEVELOPER_OPTIONS.containsKey(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY))
					openAnimated = (Boolean)IMPACT_DEVELOPER_OPTIONS.get(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY);
				
				options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY, openAnimated);
				
				if (IMPACT_DEVELOPER_OPTIONS.containsKey(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS))
					muteVideoSounds = (Boolean)IMPACT_DEVELOPER_OPTIONS.get(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS);
				
				options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS, muteVideoSounds);
				
				if (IMPACT_DEVELOPER_OPTIONS.containsKey(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY))
					options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY, IMPACT_DEVELOPER_OPTIONS.get(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY));
				
				if (IMPACT_DEVELOPER_OPTIONS.containsKey(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION))
					videoUsesDeviceOrientation = (Boolean)IMPACT_DEVELOPER_OPTIONS.get(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION);
				
				options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION, videoUsesDeviceOrientation);

			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not create JSON", ApplifierImpactProperties.class);
			}

			return options;
		}
		
		return null;
	}
	
	public static String getCampaignQueryUrl () {
		if (_campaignQueryString == null) {
			createCampaignQueryString();
		}
		
		String url = CAMPAIGN_DATA_URL;
		
		if (ApplifierImpactUtils.isDebuggable(BASE_ACTIVITY) && TEST_URL != null)
			url = TEST_URL;
			
		return String.format("%s%s", url, _campaignQueryString);
	}
	
	public static void setExtraParams (Map<String, String> params) {
		if (params.containsKey("testData")) {
			TEST_DATA = params.get("testData");
		}
		
		if (params.containsKey("testUrl")) {
			TEST_URL = params.get("testUrl");
		}
		
		if (params.containsKey("testJavaScript")) {
			TEST_JAVASCRIPT = params.get("testJavaScript");
		}
	}
}
