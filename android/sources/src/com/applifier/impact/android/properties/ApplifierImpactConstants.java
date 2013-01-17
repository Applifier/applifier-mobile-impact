package com.applifier.impact.android.properties;

public class ApplifierImpactConstants {
	// Android specific
	public static final String LOG_NAME = "ApplifierImpact";
	public static final String CACHE_DIR_NAME = "ApplifierVideoCache";
	public static final String CACHE_MANIFEST_FILENAME = "manifest.json";
	public static final String PENDING_REQUESTS_FILENAME = "pendingrequests.dat";

	/* Impact */
	public static final String IMPACT_VERSION = "1.0.3";
	
	/* JSON Data Root */	
	public static final String IMPACT_JSON_DATA_ROOTKEY = "data";
		
	/* WebView */
	public static final String IMPACT_WEBVIEW_JS_PREFIX = "javascript:applifierimpact.";
	public static final String IMPACT_WEBVIEW_JS_INIT = "init";
	public static final String IMPACT_WEBVIEW_JS_CHANGE_VIEW = "setView";
	public static final String IMPACT_WEBVIEW_JS_HANDLE_NATIVE_EVENT = "handleNativeEvent";
	
	public static final String IMPACT_WEBVIEW_DATAPARAM_CAMPAIGNDATA_KEY = "campaignData";
	public static final String IMPACT_WEBVIEW_DATAPARAM_PLATFORM_KEY = "platform";
	public static final String IMPACT_WEBVIEW_DATAPARAM_DEVICEID_KEY = "deviceId";
	public static final String IMPACT_WEBVIEW_DATAPARAM_GAMEID_KEY = "gameId";
	public static final String IMPACT_WEBVIEW_DATAPARAM_DEVICETYPE_KEY = "deviceType";
	public static final String IMPACT_WEBVIEW_DATAPARAM_OPENUDID_KEY = "openUdid";
	public static final String IMPACT_WEBVIEW_DATAPARAM_MACADDRESS_KEY = "macAddress";
	public static final String IMPACT_WEBVIEW_DATAPARAM_SDKVERSION_KEY = "sdkVersion";
	public static final String IMPACT_WEBVIEW_DATAPARAM_SOFTWAREVERSION_KEY = "softwareVersion";

	/* Campaign JSON Properties */
	public static final String IMPACT_CAMPAIGNS_KEY = "campaigns";
	public static final String IMPACT_CAMPAIGN_ENDSCREEN_KEY = "endScreen";
	public static final String IMPACT_CAMPAIGN_CLICKURL_KEY = "clickUrl";
	public static final String IMPACT_CAMPAIGN_PICTURE_KEY = "picture";
	public static final String IMPACT_CAMPAIGN_TRAILER_DOWNLOADABLE_KEY = "trailerDownloadable";
	public static final String IMPACT_CAMPAIGN_TRAILER_STREAMING_KEY = "trailerStreaming";
	public static final String IMPACT_CAMPAIGN_GAME_ID_KEY = "gameId";
	public static final String IMPACT_CAMPAIGN_GAME_NAME_KEY = "gameName";
	public static final String IMPACT_CAMPAIGN_ID_KEY = "id";
	public static final String IMPACT_CAMPAIGN_TAGLINE_KEY = "tagLine";
	public static final String IMPACT_CAMPAIGN_STOREID_KEY = "iTunesId";
	public static final String IMPACT_CAMPAIGN_CACHE_VIDEO_KEY = "cacheVideo";

	/* Reward Item JSON Properties */
	public static final String IMPACT_REWARD_ITEMKEY_KEY = "itemKey";
	public static final String IMPACT_REWARD_NAME_KEY = "name";
	public static final String IMPACT_REWARD_PICTURE_KEY = "picture";
	public static final String IMPACT_REWARD_ITEM_KEY = "item";
	public static final String IMPACT_REWARD_ITEMS_KEY = "items";

	/* Gamer JSON Properties */
	public static final String IMPACT_GAMER_ID_KEY = "gamerId";

	/* Impact Base JSON Properties */
	public static final String IMPACT_URL_KEY = "impactUrl";
	public static final String IMPACT_WEBVIEW_URL_KEY = "webViewUrl";	
	public static final String IMPACT_ANALYTICS_URL_KEY = "analyticsUrl";
	
	/* Init Query Params */
	public static final String IMPACT_INIT_QUERYPARAM_DEVICEID_KEY = "deviceId";
	public static final String IMPACT_INIT_QUERYPARAM_DEVICETYPE_KEY = "deviceType";
	public static final String IMPACT_INIT_QUERYPARAM_PLATFORM_KEY = "platform";
	public static final String IMPACT_INIT_QUERYPARAM_GAMEID_KEY = "gameId";
	public static final String IMPACT_INIT_QUERYPARAM_OPENUDID_KEY = "openUdid";
	public static final String IMPACT_INIT_QUERYPARAM_MACADDRESS_KEY = "macAddress";
	public static final String IMPACT_INIT_QUERYPARAM_ADVERTISINGTRACKINGID_KEY = "advertisingTrackingId";
	public static final String IMPACT_INIT_QUERYPARAM_TRACKINGENABLED_KEY = "trackingEnabled";
	public static final String IMPACT_INIT_QUERYPARAM_SOFTWAREVERSION_KEY = "softwareVersion";
	public static final String IMPACT_INIT_QUERYPARAM_HARDWAREVERSION_KEY = "hardwareVersion";
	public static final String IMPACT_INIT_QUERYPARAM_SDKVERSION_KEY = "sdkVersion";
	public static final String IMPACT_INIT_QUERYPARAM_CONNECTIONTYPE_KEY = "connectionType";
	public static final String IMPACT_INIT_QUERYPARAM_TEST_KEY = "test";
	
	/* Device types */
	public static final String IMPACT_DEVICEID_UNKNOWN = "unknown";
	
	/* Analytics */
	public static final String IMPACT_ANALYTICS_TRACKING_PATH = "gamers/";
	public static final String IMPACT_ANALYTICS_INSTALLTRACKING_PATH = "games/";
	
	/* Analytics Query Params */
	public static final String IMPACT_ANALYTICS_QUERYPARAM_GAMEID_KEY = "gameId";
	public static final String IMPACT_ANALYTICS_QUERYPARAM_EVENTTYPE_KEY = "type";
	public static final String IMPACT_ANALYTICS_QUERYPARAM_TRACKINGID_KEY = "trackingId";
	public static final String IMPACT_ANALYTICS_QUERYPARAM_PROVIDERID_KEY = "providerId";
	public static final String IMPACT_ANALYTICS_QUERYPARAM_REWARDITEM_KEY = "rewardItem";
}
