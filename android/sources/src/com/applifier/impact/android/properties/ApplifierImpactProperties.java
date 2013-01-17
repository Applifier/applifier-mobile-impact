package com.applifier.impact.android.properties;

import com.applifier.impact.android.data.ApplifierImpactDevice;

import android.app.Activity;

public class ApplifierImpactProperties {
	//public static String CAMPAIGN_DATA_URL = "http://192.168.1.152:3500/mobile/campaigns";
	//public static String CAMPAIGN_DATA_URL = "https://impact.applifier.com/mobile/campaigns";
	public static String CAMPAIGN_DATA_URL = "https://staging-impact.applifier.com/mobile/campaigns";
	public static String WEBVIEW_BASE_URL = null;
	public static String ANALYTICS_BASE_URL = null;
	public static String IMPACT_BASE_URL = null;
	public static String CAMPAIGN_QUERY_STRING = null;
	public static String IMPACT_GAME_ID = null;
	public static String IMPACT_GAMER_ID = null;
	public static Boolean TESTMODE_ENABLED = false;
	public static Activity CURRENT_ACTIVITY = null;
	public static final int MAX_NUMBER_OF_ANALYTICS_RETRIES = 5;
	
	private static String _campaignQueryString = null; 
	
	private static void createCampaignQueryString () {
		String queryString = "?";
		
		//Mandatory params
		queryString = String.format("%s%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_DEVICEID_KEY, ApplifierImpactDevice.getDeviceId());
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_PLATFORM_KEY, "android");
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_GAMEID_KEY, ApplifierImpactProperties.IMPACT_GAME_ID);
		//queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_OPENUDID_KEY, ApplifierImpactProperties.IMPACT_GAME_ID);
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_MACADDRESS_KEY, ApplifierImpactDevice.getMacAddress());
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SDKVERSION_KEY, ApplifierImpactConstants.IMPACT_VERSION);
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_SOFTWAREVERSION_KEY, ApplifierImpactDevice.getSoftwareVersion());
		//queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_HARDWAREVERSION_KEY, ApplifierImpactDevice.getHardwareVersion());
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_DEVICETYPE_KEY, ApplifierImpactDevice.getDeviceType());
		queryString = String.format("%s&%s=%s", queryString, ApplifierImpactConstants.IMPACT_INIT_QUERYPARAM_CONNECTIONTYPE_KEY, ApplifierImpactDevice.getConnectionType());
		
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
