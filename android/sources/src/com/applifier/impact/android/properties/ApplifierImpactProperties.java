package com.applifier.impact.android.properties;

import java.lang.ref.WeakReference;
import java.net.URLEncoder;
import java.util.Map;

import android.app.Activity;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.data.ApplifierImpactDevice;
import com.google.android.gms.ads.identifier.AdvertisingIdClient.Info;

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
	public static Boolean TESTMODE_ENABLED = false;
	public static WeakReference<Activity> BASE_ACTIVITY = null;
	public static WeakReference<Activity> CURRENT_ACTIVITY = null;
	public static ApplifierImpactCampaign SELECTED_CAMPAIGN = null;
	public static Boolean IMPACT_DEBUG_MODE = false;
	public static Info ADVERTISING_TRACKING_INFO = null;
	public static Map<String, Object> IMPACT_DEVELOPER_OPTIONS = null;
	public static int ALLOW_VIDEO_SKIP = 0;
	public static int ALLOW_BACK_BUTTON_SKIP = 0;
	public static int CAMPAIGN_REFRESH_VIEWS_COUNT = 0;
	public static int CAMPAIGN_REFRESH_VIEWS_MAX = 0;
	public static int CAMPAIGN_REFRESH_SECONDS = 0;
	
	public static String TEST_DATA = null;
	public static String TEST_URL = null;
	public static String TEST_JAVASCRIPT = null;
	public static Boolean RUN_WEBVIEW_TESTS = false;
	
	public static String TEST_DEVELOPER_ID = null;
	public static String TEST_OPTIONS_ID = null;
	
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

			if (!ApplifierImpactDevice.getMacAddress().equals(ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN))
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_MACADDRESS_KEY, URLEncoder.encode(ApplifierImpactDevice.getMacAddress(), "UTF-8"));
			
			if(ApplifierImpactProperties.ADVERTISING_TRACKING_INFO != null) {
				queryString = String.format("%s&%s=%d", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_TRACKINGENABLED_KEY, ApplifierImpactProperties.ADVERTISING_TRACKING_INFO.isLimitAdTrackingEnabled() ? 0 : 1);
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_ADVERTISINGTRACKINGID_KEY, URLEncoder.encode(ApplifierImpactProperties.ADVERTISING_TRACKING_INFO.getId(), "UTF-8"));
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_RAWADVERTISINGTRACKINGID_KEY, URLEncoder.encode(ApplifierImpactProperties.ADVERTISING_TRACKING_INFO.getId(), "UTF-8"));
			}
			
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
			
			if (TEST_OPTIONS_ID != null && TEST_OPTIONS_ID.length() > 0) {
				queryString = String.format("%s&%s=%s", queryString, "optionsId", TEST_OPTIONS_ID);
			}
			
			if (TEST_DEVELOPER_ID != null && TEST_DEVELOPER_ID.length() > 0) {
				queryString = String.format("%s&%s=%s", queryString, "developerId", TEST_DEVELOPER_ID);
			}
		}
		else {
			if (ApplifierImpactProperties.getCurrentActivity() != null) {
				queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_ENCRYPTED_KEY, ApplifierImpactUtils.isDebuggable(ApplifierImpactProperties.getCurrentActivity()) ? "false" : "true");
			}
		}
				
		_campaignQueryString = queryString;
	}
	
	public static String getCampaignQueryUrl () {
		createCampaignQueryString();
		String url = CAMPAIGN_DATA_URL;
		
		if (ApplifierImpactUtils.isDebuggable(getBaseActivity()) && TEST_URL != null)
			url = TEST_URL;
			
		return String.format("%s%s", url, _campaignQueryString);
	}
	
	public static Activity getBaseActivity() {
		if(BASE_ACTIVITY != null) {
			return BASE_ACTIVITY.get();
		}
		return null;
	}
	
	public static Activity getCurrentActivity() {
		if(CURRENT_ACTIVITY != null) {
			return CURRENT_ACTIVITY.get();
		}
		return null;
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
