package com.applifier.impact.android;

import android.app.Activity;

public class ApplifierImpactProperties {	
	public static final String LOG_NAME = "ApplifierImpact";
	public static final String CACHE_DIR_NAME = "ApplifierVideoCache";
	public static final String CACHE_MANIFEST_FILENAME = "manifest.json";
	public static final String PENDING_REQUESTS_FILENAME = "pendingrequests.dat";
	
	public static final String IMPACT_BASEURL = "http://impact.applifier.com/";
	public static final String IMPACT_GAMERPATH = "gamers";
	public static final String IMPACT_MOBILEPATH = "mobile";
	public static final String IMPACT_CAMPAIGNPATH = "campaigns";
	public static final String IMPACT_JS_PREFIX = "javascript:applifierimpact.";
	
	public static Activity CURRENT_ACTIVITY = null;
	public static String IMPACT_APP_ID = "";
}
