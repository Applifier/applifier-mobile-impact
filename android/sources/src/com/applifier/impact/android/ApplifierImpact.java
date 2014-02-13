package com.applifier.impact.android;

import java.util.ArrayList;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import org.json.JSONObject;

import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactCacheListener;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.ApplifierImpactRewardItem;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;
import com.applifier.impact.android.view.ApplifierImpactMainView;
import com.applifier.impact.android.view.IApplifierImpactMainViewListener;
import com.applifier.impact.android.view.ApplifierImpactMainView.ApplifierImpactMainViewAction;
import com.applifier.impact.android.view.ApplifierImpactMainView.ApplifierImpactMainViewState;
import com.applifier.impact.android.webapp.*;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.PowerManager;
import android.os.SystemClock;


public class ApplifierImpact implements IApplifierImpactCacheListener, 
										IApplifierImpactWebDataListener, 
										IApplifierImpactWebBrigeListener,
										IApplifierImpactMainViewListener {
	
	// Reward item HashMap keys
	public static final String APPLIFIER_IMPACT_REWARDITEM_PICTURE_KEY = "picture";
	public static final String APPLIFIER_IMPACT_REWARDITEM_NAME_KEY = "name";
	
	// Impact developer options keys
	public static final String APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY = "noOfferScreen";
	public static final String APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY = "openAnimated";
	public static final String APPLIFIER_IMPACT_OPTION_GAMERSID_KEY = "sid";
	public static final String APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS = "muteVideoSounds";
	public static final String APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION = "useDeviceOrientationForVideo";

	// Impact components
	public static ApplifierImpact instance = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	public static ApplifierImpactMainView mainview = null;
	
	// Temporary data
	private boolean _initialized = false;
	private boolean _showingImpact = false;
	private boolean _impactReadySent = false;
	private boolean _webAppLoaded = false;
	private boolean _openRequestFromDeveloper = false;
	private boolean _refreshAfterShowImpact = false;
	private AlertDialog _alertDialog = null;
		
	private TimerTask _pauseScreenTimer = null;
	private Timer _pauseTimer = null;
	private TimerTask _campaignRefreshTimerTask = null;
	private Timer _campaignRefreshTimer = null;
	private long _campaignRefreshTimerDeadline = 0;
	
	// Listeners
	private IApplifierImpactListener _impactListener = null;
	
	
	public ApplifierImpact (Activity activity, String gameId) {
		init(activity, gameId, null);
	}
	
	public ApplifierImpact (Activity activity, String gameId, IApplifierImpactListener listener) {
		init(activity, gameId, listener);
	}

	
	/* PUBLIC STATIC METHODS */
	
	public static boolean isSupported () {
		if (Build.VERSION.SDK_INT < 9) {
			return false;
		}
		
		return true;
	}
	
	public static void setDebugMode (boolean debugModeEnabled) {
		ApplifierImpactProperties.IMPACT_DEBUG_MODE = debugModeEnabled;
	}
	
	public static void setTestMode (boolean testModeEnabled) {
		ApplifierImpactProperties.TESTMODE_ENABLED = testModeEnabled;
	}
	
	public static void setTestDeveloperId (String testDeveloperId) {
		ApplifierImpactProperties.TEST_DEVELOPER_ID = testDeveloperId;
	}
	
	public static void setTestOptionsId (String testOptionsId) {
		ApplifierImpactProperties.TEST_OPTIONS_ID = testOptionsId;
	}
	
	public static String getSDKVersion () {
		return ApplifierImpactConstants.IMPACT_VERSION;
	}
	
	
	/* PUBLIC METHODS */
	
	public void setImpactListener (IApplifierImpactListener listener) {
		_impactListener = listener;
	}
	
	public void changeActivity (Activity activity) {
		if (activity == null) return;
		
		if (activity != null && !activity.equals(ApplifierImpactProperties.CURRENT_ACTIVITY)) {
			ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
			
			// Not the most pretty way to detect when the fullscreen activity is ready
			if (activity != null &&
				activity.getClass() != null &&
				activity.getClass().getName() != null &&
				activity.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
				
				String view = null;
				
				if (mainview != null && mainview.webview != null) {
					view = mainview.webview.getWebViewCurrentView();
					
					if (_openRequestFromDeveloper) {
						view = ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START;
						ApplifierImpactUtils.Log("changeActivity: This open request is from the developer, setting start view", this);
					}
					
					if (view != null)
						open(view);
				}
				
				_openRequestFromDeveloper = false;
			}
			else {
				ApplifierImpactProperties.BASE_ACTIVITY = activity;
			}
		}
	}
	
	public boolean hideImpact () {
		if (_showingImpact) {
			close();
			return true;
		}
		
		return false;
	}
	
	public boolean showImpact (Map<String, Object> options) {
		if (canShowImpact()) {
			ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS = options;
			
			if (ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS != null) {
				if (ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.containsKey(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY) && ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.get(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY).equals(true)) {
					if (webdata.getViewableVideoPlanCampaigns().size() > 0) {
						ApplifierImpactCampaign selectedCampaign = webdata.getViewableVideoPlanCampaigns().get(0);
						ApplifierImpactProperties.SELECTED_CAMPAIGN = selectedCampaign;
					}
				}
				if (ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.containsKey(APPLIFIER_IMPACT_OPTION_GAMERSID_KEY) && ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.get(APPLIFIER_IMPACT_OPTION_GAMERSID_KEY) != null) {
					ApplifierImpactProperties.GAMER_SID = "" + ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.get(APPLIFIER_IMPACT_OPTION_GAMERSID_KEY);
				}
			}
			
			return showImpact();
		}
		
		return false;
	}
	
	public boolean showImpact () {
		if (canShowImpact()) {
			_openRequestFromDeveloper = true;
			_showingImpact = true;
			startImpactFullscreenActivity();
			return _showingImpact;
		}

		return false;
	}
	
	public boolean canShowCampaigns () {
		return mainview != null && 
			mainview.webview != null && 
			mainview.webview.isWebAppLoaded() && 
			_webAppLoaded && 
			webdata != null && 
			webdata.getViewableVideoPlanCampaigns() != null && 
			webdata.getViewableVideoPlanCampaigns().size() > 0;
	}
	
	public boolean canShowImpact () {
		return !_showingImpact && 
			mainview != null && 
			mainview.webview != null && 
			mainview.webview.isWebAppLoaded() && 
			_webAppLoaded && 
			webdata != null && 
			webdata.getVideoPlanCampaigns() != null && 
			webdata.getVideoPlanCampaigns().size() > 0;
	}

	public void stopAll () {
		ApplifierImpactUtils.Log("stopAll()", this);
		if (mainview != null && mainview.videoplayerview != null)
			mainview.videoplayerview.clearVideoPlayer();
		if (mainview != null && mainview.webview != null)
			mainview.webview.clearWebView();
		
		ApplifierImpactDownloader.stopAllDownloads();
		ApplifierImpactDownloader.clearData();
		cachemanager.setDownloadListener(null);
		cachemanager.clearData();
		webdata.stopAllRequests();
		webdata.setWebDataListener(null);
		webdata.clearData();
		ApplifierImpactProperties.BASE_ACTIVITY = null;
		ApplifierImpactProperties.CURRENT_ACTIVITY = null;
		ApplifierImpactProperties.SELECTED_CAMPAIGN = null;
	}
	
	
	/* PUBLIC MULTIPLE REWARD ITEM SUPPORT */
	
	public boolean hasMultipleRewardItems () {
		if (webdata.getRewardItems() != null && webdata.getRewardItems().size() > 0)
			return true;
		
		return false;
	}
	
	public ArrayList<String> getRewardItemKeys () {
		if (webdata.getRewardItems() != null && webdata.getRewardItems().size() > 0) {
			ArrayList<ApplifierImpactRewardItem> rewardItems = webdata.getRewardItems();
			ArrayList<String> rewardItemKeys = new ArrayList<String>();
			for (ApplifierImpactRewardItem rewardItem : rewardItems) {
				rewardItemKeys.add(rewardItem.getKey());
			}
			
			return rewardItemKeys;
		}
		
		return null;
	}
	
	public String getDefaultRewardItemKey () {
		if (webdata != null && webdata.getDefaultRewardItem() != null)
			return webdata.getDefaultRewardItem().getKey();
		
		return null;
	}
	
	public String getCurrentRewardItemKey () {
		if (webdata != null && webdata.getCurrentRewardItemKey() != null)
			return webdata.getCurrentRewardItemKey();
			
		return null;
	}
	
	public boolean setRewardItemKey (String rewardItemKey) {
		if (canShowImpact()) {
			ApplifierImpactRewardItem rewardItem = webdata.getRewardItemByKey(rewardItemKey);
			
			if (rewardItem != null) {
				webdata.setCurrentRewardItem(rewardItem);
				return true;
			}
		}
		
		return false;
	}
	
	public void setDefaultRewardItemAsRewardItem () {
		if (canShowImpact()) {
			if (webdata != null && webdata.getDefaultRewardItem() != null) {
				webdata.setCurrentRewardItem(webdata.getDefaultRewardItem());
			}
		}
	}
	
	public Map<String, String> getRewardItemDetailsWithKey (String rewardItemKey) {
		ApplifierImpactRewardItem rewardItem = webdata.getRewardItemByKey(rewardItemKey);
		if (rewardItem != null) {
			return rewardItem.getDetails();
		}
		else {
			ApplifierImpactUtils.Log("Could not fetch reward item: " + rewardItemKey, this);
		}
		
		return null;
	}
	
	
	/* LISTENER METHODS */
	
	// IApplifierImpactMainViewListener
	public void onMainViewAction (ApplifierImpactMainViewAction action) {
		switch (action) {
			case BackButtonPressed:
				if (_showingImpact) {
					close();
				}
				break;
			case VideoStart:
				if (_impactListener != null)
					_impactListener.onVideoStarted();
				cancelPauseScreenTimer();
				break;
			case VideoEnd:
				ApplifierImpactProperties.CAMPAIGN_REFRESH_VIEWS_COUNT++;
				if (_impactListener != null && ApplifierImpactProperties.SELECTED_CAMPAIGN != null && !ApplifierImpactProperties.SELECTED_CAMPAIGN.isViewed()) {
					ApplifierImpactProperties.SELECTED_CAMPAIGN.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
					_impactListener.onVideoCompleted(getCurrentRewardItemKey(), false);
				}
				break;
			case VideoSkipped:
				ApplifierImpactProperties.CAMPAIGN_REFRESH_VIEWS_COUNT++;
				if (_impactListener != null && ApplifierImpactProperties.SELECTED_CAMPAIGN != null && !ApplifierImpactProperties.SELECTED_CAMPAIGN.isViewed()) {
					ApplifierImpactProperties.SELECTED_CAMPAIGN.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
					_impactListener.onVideoCompleted(getCurrentRewardItemKey(), true);
				}
				break;
			case RequestRetryVideoPlay:
				ApplifierImpactUtils.Log("Retrying video play, because something went wrong.", this);
				playVideo(300);
				break;
		}
	}

	// IApplifierImpactCacheListener
	@Override
	public void onCampaignUpdateStarted () {	
		ApplifierImpactUtils.Log("Campaign updates started.", this);
	}
	
	@Override
	public void onCampaignReady (ApplifierImpactCampaignHandler campaignHandler) {
		if (campaignHandler == null || campaignHandler.getCampaign() == null) return;
				
		ApplifierImpactUtils.Log("Got onCampaignReady: " + campaignHandler.getCampaign().toString(), this);
		
		if (canShowCampaigns())
			sendImpactReadyEvent();
	}
	
	@Override
	public void onAllCampaignsReady () {
		ApplifierImpactUtils.Log("Listener got \"All campaigns ready.\"", this);
	}
	
	// IApplifierImpactWebDataListener
	@SuppressWarnings("deprecation")
	@Override
	public void onWebDataCompleted () {
		JSONObject jsonData = null;
		boolean dataFetchFailed = false;
		boolean sdkIsCurrent = true;
		
		if (webdata.getData() != null && webdata.getData().has(ApplifierImpactConstants.IMPACT_JSON_DATA_ROOTKEY)) {
			try {
				jsonData = webdata.getData().getJSONObject(ApplifierImpactConstants.IMPACT_JSON_DATA_ROOTKEY);
			}
			catch (Exception e) {
				dataFetchFailed = true;
			}
			
			if (!dataFetchFailed) {
				setupCampaignRefreshTimer();
				
				if (jsonData.has(ApplifierImpactConstants.IMPACT_WEBVIEW_DATAPARAM_SDK_IS_CURRENT_KEY)) {
					try {
						sdkIsCurrent = jsonData.getBoolean(ApplifierImpactConstants.IMPACT_WEBVIEW_DATAPARAM_SDK_IS_CURRENT_KEY);
					}
					catch (Exception e) {
						dataFetchFailed = true;
					}
				}
			}
		}
		
		if (!dataFetchFailed && !sdkIsCurrent && ApplifierImpactUtils.isDebuggable(ApplifierImpactProperties.CURRENT_ACTIVITY)) {
			_alertDialog = new AlertDialog.Builder(ApplifierImpactProperties.CURRENT_ACTIVITY).create();
			_alertDialog.setTitle("Applifier Impact");
			_alertDialog.setMessage("You are not running the latest version of Applifier Impact android. Please update your version (this dialog won't appear in release builds).");
			_alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					_alertDialog.dismiss();
				}
			});
			
			_alertDialog.show();
		}
		
		setup();
	}
	
	@Override
	public void onWebDataFailed () {
		if (_impactListener != null && !_impactReadySent)
			_impactListener.onCampaignsFetchFailed();
	}
	
	
	// IApplifierImpactWebBrigeListener
	@Override
	public void onPlayVideo(JSONObject data) {
		ApplifierImpactUtils.Log("onPlayVideo", this);
		if (data.has(ApplifierImpactConstants.IMPACT_WEBVIEW_EVENTDATA_CAMPAIGNID_KEY)) {
			String campaignId = null;
			
			try {
				campaignId = data.getString(ApplifierImpactConstants.IMPACT_WEBVIEW_EVENTDATA_CAMPAIGNID_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not get campaignId", this);
			}
			
			if (campaignId != null) {
				if (webdata != null && webdata.getCampaignById(campaignId) != null) {
					ApplifierImpactProperties.SELECTED_CAMPAIGN = webdata.getCampaignById(campaignId);
				}
				
				if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null && 
					ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId() != null && 
					ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId().equals(campaignId)) {
					
					Boolean rewatch = false;
					
					try {
						rewatch = data.getBoolean(ApplifierImpactConstants.IMPACT_WEBVIEW_EVENTDATA_REWATCH_KEY);
					}
					catch (Exception e) {
					}
					
					ApplifierImpactUtils.Log("onPlayVideo: Selected campaign=" + ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId() + " isViewed: " + ApplifierImpactProperties.SELECTED_CAMPAIGN.isViewed(), this);
					if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null && (rewatch || !ApplifierImpactProperties.SELECTED_CAMPAIGN.isViewed())) {
						playVideo();
					}
				}
			}
		}
	}

	@Override
	public void onPauseVideo(JSONObject data) {
	}

	@Override
	public void onCloseImpactView(JSONObject data) {
		hideImpact();
	}
	
	@Override
	public void onWebAppInitComplete (JSONObject data) {
		ApplifierImpactUtils.Log("WebApp init complete", this);
		_webAppLoaded = true;
		Boolean dataOk = true;
		
		if (canShowCampaigns()) {
			JSONObject setViewData = new JSONObject();
			
			try {
				setViewData.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_INITCOMPLETE);
				setViewData.put(ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY, webdata.getCurrentRewardItemKey());
			}
			catch (Exception e) {
				dataOk = false;
			}
			
			if (dataOk) {
				mainview.webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, setViewData);
				sendImpactReadyEvent();			
			}
		}
	}
	
	public void onOpenPlayStore (JSONObject data) {
	    ApplifierImpactUtils.Log("onOpenPlayStore", this);

	    if (data != null) {
	    	
	    	ApplifierImpactUtils.Log(data.toString(), this);
	    	
	    	String playStoreId = null;
	    	String clickUrl = null;
	    	Boolean bypassAppSheet = false;
	    	
	    	if (data.has(ApplifierImpactConstants.IMPACT_PLAYSTORE_ITUNESID_KEY)) {
	    		try {
		    		playStoreId = data.getString(ApplifierImpactConstants.IMPACT_PLAYSTORE_ITUNESID_KEY);
	    		}
	    		catch (Exception e) {
	    			ApplifierImpactUtils.Log("Could not fetch playStoreId", this);
	    		}
	    	}
	    	
	    	if (data.has(ApplifierImpactConstants.IMPACT_PLAYSTORE_CLICKURL_KEY)) {
	    		try {
	    			clickUrl = data.getString(ApplifierImpactConstants.IMPACT_PLAYSTORE_CLICKURL_KEY);
	    		}
	    		catch (Exception e) {
	    			ApplifierImpactUtils.Log("Could not fetch clickUrl", this);
	    		}
	    	}
	    	
	    	if (data.has(ApplifierImpactConstants.IMPACT_PLAYSTORE_BYPASSAPPSHEET_KEY)) {
	    		try {
	    			bypassAppSheet = data.getBoolean(ApplifierImpactConstants.IMPACT_PLAYSTORE_BYPASSAPPSHEET_KEY);
	    		}
	    		catch (Exception e) {
	    			ApplifierImpactUtils.Log("Could not fetch bypassAppSheet", this);
	    		}
	    	}
	    	
	    	if (playStoreId != null && !bypassAppSheet) {
	    		openPlayStoreAsIntent(playStoreId);
	    	}
	    	else if (clickUrl != null ){
	    		openPlayStoreInBrowser(clickUrl);
	    	}
	    }
	}
	

	/* PRIVATE METHODS */
	
	private void openPlayStoreAsIntent (String playStoreId) {
		ApplifierImpactUtils.Log("Opening playstore activity with storeId: " + playStoreId, this);
		
		if (ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
			try {
				ApplifierImpactProperties.CURRENT_ACTIVITY.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + playStoreId)));
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Couldn't start PlayStore intent!", this);
			}
		}
	}
	
	private void openPlayStoreInBrowser (String url) {
	    ApplifierImpactUtils.Log("Could not open PlayStore activity, opening in browser with url: " + url, this);
	    
		if (ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
			try {
				ApplifierImpactProperties.CURRENT_ACTIVITY.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Couldn't start browser intent!", this);
			}
		}
	}
	
	private void init (Activity activity, String gameId, IApplifierImpactListener listener) {
		if (_initialized) return; 
		
		if(gameId.length() == 0) {
			throw new IllegalArgumentException("gameId is empty");
		} else {
			try {
				int gameIdInteger = Integer.parseInt(gameId);
				if(gameIdInteger <= 0) {
					throw new IllegalArgumentException("gameId is invalid");
				}
			} catch(NumberFormatException e) {
				throw new IllegalArgumentException("gameId does not parse as an integer");
			}
		}
		
		instance = this;
		setImpactListener(listener);
		
		ApplifierImpactProperties.IMPACT_GAME_ID = gameId;
		ApplifierImpactProperties.BASE_ACTIVITY = activity;
		ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
		
		ApplifierImpactUtils.Log("Is debuggable=" + ApplifierImpactUtils.isDebuggable(activity), this);
		
		
		cachemanager = new ApplifierImpactCacheManager();
		cachemanager.setDownloadListener(this);
		webdata = new ApplifierImpactWebData();
		webdata.setWebDataListener(this);

		if (webdata.initCampaigns()) {
			_initialized = true;
		}
	}
	
	private void close () {
		cancelPauseScreenTimer();
		if(ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
			ApplifierImpactCloseRunner closeRunner = new ApplifierImpactCloseRunner();
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(closeRunner);
		}
	}
	
	private void open (String view) {
		Boolean dataOk = true;			
		JSONObject data = new JSONObject();
		
		try  {
			data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_OPEN);
			data.put(ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY, webdata.getCurrentRewardItemKey());
			data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_DEVELOPER_OPTIONS, ApplifierImpactProperties.getDeveloperOptionsAsJson());
		}
		catch (Exception e) {
			dataOk = false;
		}

		ApplifierImpactUtils.Log("open() dataOk: " + dataOk, this);
		
		if (dataOk && view != null) {
			ApplifierImpactUtils.Log("open() opening with view:" + view + " and data:" + data.toString(), this);
			
			if (mainview != null) {
				mainview.openImpact(view, data);
				
				if (ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS != null && 
					ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.containsKey(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY)  && 
					ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.get(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY).equals(true))
						playVideo();
				
				if (_impactListener != null)
					_impactListener.onImpactOpen();
			}
		}
	}

	private void setup () {
		initCache();
		setupViews();
	}
	
	private void initCache () {
		if (_initialized) {
			ApplifierImpactUtils.Log("Init cache", this);
			// Update cache WILL START DOWNLOADS if needed, after this method you can check getDownloadingCampaigns which ones started downloading.
			cachemanager.updateCache(webdata.getVideoPlanCampaigns());				
		}
	}
	
	private void sendImpactReadyEvent () {
		if (!_impactReadySent && _impactListener != null) {
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {				
				@Override
				public void run() {
					ApplifierImpactUtils.Log("Impact ready!", this);
					_impactReadySent = true;
					_impactListener.onCampaignsAvailable();
				}
			});
		}
	}

	private void setupViews () {
		mainview = new ApplifierImpactMainView(ApplifierImpactProperties.CURRENT_ACTIVITY, this);
	}

	private void playVideo () {
		playVideo(0);
	}
	
	private void playVideo (long delay) {
		ApplifierImpactUtils.Log("Running threaded", this);
		
		if (delay > 0) {
			Timer delayTimer = new Timer();
			delayTimer.schedule(new TimerTask() {
				@Override
				public void run() {
					ApplifierImpactUtils.Log("Delayed video start", this);
					ApplifierImpactPlayVideoRunner playVideoRunner = new ApplifierImpactPlayVideoRunner();
					if (ApplifierImpactProperties.CURRENT_ACTIVITY != null)
						ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(playVideoRunner);
				}
			}, delay);
		}
		else {
			ApplifierImpactPlayVideoRunner playVideoRunner = new ApplifierImpactPlayVideoRunner();
			if (ApplifierImpactProperties.CURRENT_ACTIVITY != null)
				ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(playVideoRunner);
		}
	}
	
	private void startImpactFullscreenActivity () {
		Intent newIntent = new Intent(ApplifierImpactProperties.CURRENT_ACTIVITY, com.applifier.impact.android.view.ApplifierImpactFullscreenActivity.class);
		int flags = Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK;
		
		if (ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS != null && 
			ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.containsKey(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY) && 
			ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.get(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY).equals(true))
				flags = Intent.FLAG_ACTIVITY_NEW_TASK;
		
		newIntent.addFlags(flags);
		
		try {
			ApplifierImpactProperties.BASE_ACTIVITY.startActivity(newIntent);
		}
		catch (ActivityNotFoundException e) {
			ApplifierImpactUtils.Log("Could not find activity: " + e.getStackTrace(), this);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Weird error: " + e.getStackTrace(), this);
		}
	}
	
	private void cancelPauseScreenTimer () {
		if (_pauseScreenTimer != null) {
			_pauseScreenTimer.cancel();
		}
		
		if (_pauseTimer != null) {
			_pauseTimer.cancel();
			_pauseTimer.purge();
		}
		
		_pauseScreenTimer = null;
		_pauseTimer = null;
	}
	
	private void createPauseScreenTimer () {
		_pauseScreenTimer = new TimerTask() {
			@Override
			public void run() {
				if(ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
					PowerManager pm = (PowerManager)ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext().getSystemService(Context.POWER_SERVICE);			
					if (!pm.isScreenOn()) {
						mainview.webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_HIDESPINNER, new JSONObject());
						close();
						cancelPauseScreenTimer();
					}
				}
			}
		};
		
		_pauseTimer = new Timer();
		_pauseTimer.scheduleAtFixedRate(_pauseScreenTimer, 0, 50);
	}
	
	private void refreshCampaigns() {
		if(_refreshAfterShowImpact) {
			_refreshAfterShowImpact = false;
			ApplifierImpactUtils.Log("Starting delayed ad plan refresh", this);
			webdata.initCampaigns();
			return;
		}

		if(_campaignRefreshTimerDeadline > 0 && SystemClock.elapsedRealtime() > _campaignRefreshTimerDeadline) {
			removeCampaignRefreshTimer();
			ApplifierImpactUtils.Log("Refreshing ad plan from server due to timer deadline", this);
			webdata.initCampaigns();
			return;
		}

		if (ApplifierImpactProperties.CAMPAIGN_REFRESH_VIEWS_MAX > 0) {
			if(ApplifierImpactProperties.CAMPAIGN_REFRESH_VIEWS_COUNT >= ApplifierImpactProperties.CAMPAIGN_REFRESH_VIEWS_MAX) {
				ApplifierImpactUtils.Log("Refreshing ad plan from server due to endscreen limit", this);
				webdata.initCampaigns();
				return;
			}
		}

		if (webdata != null && webdata.getVideoPlanCampaigns() != null) {
			if(webdata.getViewableVideoPlanCampaigns().size() == 0) {
				ApplifierImpactUtils.Log("All available videos watched, refreshing ad plan from server", this);
				webdata.initCampaigns();
				return;
			}
		} else {
			ApplifierImpactUtils.Log("Unable to read video data to determine if ad plans should be refreshed", this);
		}
	}

	private void setupCampaignRefreshTimer() {
		removeCampaignRefreshTimer();

		if(ApplifierImpactProperties.CAMPAIGN_REFRESH_SECONDS > 0) {
			_campaignRefreshTimerTask = new TimerTask() {
				@Override
				public void run() {
					if(!_showingImpact) {
						ApplifierImpactUtils.Log("Refreshing ad plan to get new data", this);
						webdata.initCampaigns();
					} else {
						ApplifierImpactUtils.Log("Refreshing ad plan after current ad", this);
						_refreshAfterShowImpact = true;
					}
				}
			};

			_campaignRefreshTimerDeadline = SystemClock.elapsedRealtime() + ApplifierImpactProperties.CAMPAIGN_REFRESH_SECONDS * 1000;

			_campaignRefreshTimer = new Timer();
			_campaignRefreshTimer.schedule(_campaignRefreshTimerTask, ApplifierImpactProperties.CAMPAIGN_REFRESH_SECONDS * 1000);
		}
	}

	private void removeCampaignRefreshTimer() {
		_campaignRefreshTimerDeadline = 0;

		if(_campaignRefreshTimer != null) {
			_campaignRefreshTimer.cancel();
		}
	}

	/* INTERNAL CLASSES */

	// FIX: Could these 2 classes be moved to MainView
	
	private class ApplifierImpactCloseRunner implements Runnable {
		JSONObject _data = null;
		@Override
		public void run() {
			
			if (ApplifierImpactProperties.CURRENT_ACTIVITY != null && ApplifierImpactProperties.CURRENT_ACTIVITY.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
				Boolean dataOk = true;			
				JSONObject data = new JSONObject();
				
				try  {
					data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_CLOSE);
				}
				catch (Exception e) {
					dataOk = false;
				}

				ApplifierImpactUtils.Log("dataOk: " + dataOk, this);
				
				if (dataOk) {
					_data = data;
					if(mainview != null && mainview.webview != null) {
						mainview.webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_NONE, data);
					}
					Timer testTimer = new Timer();
					testTimer.schedule(new TimerTask() {
						@Override
						public void run() {
							if(ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
								ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {
									@Override
									public void run() {
										if(mainview != null) {
											mainview.closeImpact(_data);
										}
										if(ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
											ApplifierImpactProperties.CURRENT_ACTIVITY.finish();
										}
										
										if (ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS == null || 
											!ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.containsKey(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY) || 
											ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS.get(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY).equals(false)) {
											if(ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
												ApplifierImpactProperties.CURRENT_ACTIVITY.overridePendingTransition(0, 0);
											}
										}	
										
										ApplifierImpactProperties.IMPACT_DEVELOPER_OPTIONS = null;
										_showingImpact = false;

										if (_impactListener != null)
											_impactListener.onImpactClose();

										refreshCampaigns();
									}
								});
							}
						}
					}, 250);
				}
			}
		}
	}
	
	private class ApplifierImpactPlayVideoRunner implements Runnable {
		
		@Override
		public void run() {			
			ApplifierImpactUtils.Log("Running videoplayrunner", this);
			if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null) {
				ApplifierImpactUtils.Log("Selected campaign found", this);
				JSONObject data = new JSONObject();
				
				try {
					data.put(ApplifierImpactConstants.IMPACT_TEXTKEY_KEY, ApplifierImpactConstants.IMPACT_TEXTKEY_BUFFERING);
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Couldn't create data JSON", this);
					return;
				}
				
				mainview.webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_SHOWSPINNER, data);
				
				createPauseScreenTimer();
				
				String playUrl = ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactProperties.SELECTED_CAMPAIGN.getVideoFilename();
				if (!ApplifierImpactUtils.isFileInCache(ApplifierImpactProperties.SELECTED_CAMPAIGN.getVideoFilename()))
					playUrl = ApplifierImpactProperties.SELECTED_CAMPAIGN.getVideoStreamUrl(); 

				mainview.setViewState(ApplifierImpactMainViewState.VideoPlayer);
				ApplifierImpactUtils.Log("Start videoplayback with: " + playUrl, this);
				mainview.videoplayerview.playVideo(playUrl);
			}			
			else
				ApplifierImpactUtils.Log("Campaign is null", this);
		}		
	}
}
