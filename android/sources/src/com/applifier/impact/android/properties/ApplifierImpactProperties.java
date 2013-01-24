package com.applifier.impact.android.properties;

import java.net.URLEncoder;

import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.data.ApplifierImpactDevice;

import android.app.Activity;
import android.util.Log;

public class ApplifierImpactProperties {
	public static String CAMPAIGN_DATA_URL = "http://192.168.1.152:3500/mobile/campaigns";
	//public static String CAMPAIGN_DATA_URL = "https://impact.applifier.com/mobile/campaigns";
	//public static String CAMPAIGN_DATA_URL = "https://staging-impact.applifier.com/mobile/campaigns";
	public static String WEBVIEW_BASE_URL = null;
	public static String ANALYTICS_BASE_URL = null;
	public static String IMPACT_BASE_URL = null;
	public static String CAMPAIGN_QUERY_STRING = null;
	public static String IMPACT_GAME_ID = null;
	public static String IMPACT_GAMER_ID = null;
	public static Boolean TESTMODE_ENABLED = false;
	public static Activity BASE_ACTIVITY = null;
	public static Activity CURRENT_ACTIVITY = null;
	public static ApplifierImpactCampaign SELECTED_CAMPAIGN = null;
	public static final int MAX_NUMBER_OF_ANALYTICS_RETRIES = 5;
	
	private static String _campaignQueryString = null; 
	
	private static void createCampaignQueryString () {
		String queryString = "?";
		
		TESTMODE_ENABLED = true;
		
		//Mandatory params
		try {
			queryString = String.format("%s%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_DEVICEID_KEY, URLEncoder.encode(ApplifierImpactDevice.getDeviceId(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_PLATFORM_KEY, "android");
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_GAMEID_KEY, URLEncoder.encode(ApplifierImpactProperties.IMPACT_GAME_ID, "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_OPENUDID_KEY, URLEncoder.encode(ApplifierImpactDevice.getOpenUdid(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_MACADDRESS_KEY, URLEncoder.encode(ApplifierImpactDevice.getMacAddress(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SDKVERSION_KEY, URLEncoder.encode(ApplifierImpactConstants.IMPACT_VERSION, "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SOFTWAREVERSION_KEY, URLEncoder.encode(ApplifierImpactDevice.getSoftwareVersion(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_HARDWAREVERSION_KEY, URLEncoder.encode(ApplifierImpactDevice.getHardwareVersion(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_DEVICETYPE_KEY, URLEncoder.encode(ApplifierImpactDevice.getDeviceType(), "UTF-8"));
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_CONNECTIONTYPE_KEY, URLEncoder.encode(ApplifierImpactDevice.getConnectionType(), "UTF-8"));
		}
		catch (Exception e) {
			Log.d(ApplifierImpactConstants.LOG_NAME, "Problems creating campaigns query");
		}
		
		if (TESTMODE_ENABLED) {
			queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_TEST_KEY, "true");
		}
		
		_campaignQueryString = queryString;
	}
	
	public static String getCampaignQueryUrl () {
		if (_campaignQueryString == null) {
			createCampaignQueryString();
		}
		
		return String.format("%s%s", ApplifierImpactProperties.CAMPAIGN_DATA_URL, _campaignQueryString);
	}
}
