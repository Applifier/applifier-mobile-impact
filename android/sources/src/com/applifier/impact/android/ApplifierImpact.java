package com.applifier.impact.android;

import java.util.ArrayList;
import java.util.Map;

import org.json.JSONObject;

import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactCacheListener;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.ApplifierImpactRewardItem;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;
import com.applifier.impact.android.view.ApplifierImpactMainView;
import com.applifier.impact.android.view.IApplifierImpactMainViewListener;
import com.applifier.impact.android.view.ApplifierImpactMainView.ApplifierImpactMainViewAction;
import com.applifier.impact.android.view.ApplifierImpactMainView.ApplifierImpactMainViewState;
import com.applifier.impact.android.webapp.*;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;


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

	// Impact components
	public static ApplifierImpact instance = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	
	// Temporary data
	private boolean _initialized = false;
	private boolean _showingImpact = false;
	private boolean _impactReadySent = false;
	private boolean _webAppLoaded = false;
	private boolean _openRequestFromDeveloper = false;
	private Map<String, Object> _developerOptions = null;
		
	// Main View
	private ApplifierImpactMainView _mainView = null;
	
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
		
		return false;
	}
	
	public static void setDebugMode (boolean debugModeEnabled) {
		ApplifierImpactProperties.IMPACT_DEBUG_MODE = debugModeEnabled;
	}
	
	public static void setTestMode (boolean testModeEnabled) {
		ApplifierImpactProperties.TESTMODE_ENABLED = testModeEnabled;
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
		
		if (!activity.equals(ApplifierImpactProperties.CURRENT_ACTIVITY)) {
			ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
			
			// Not the most pretty way to detect when the fullscreen activity is ready
			if (activity.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
				String view = _mainView.webview.getWebViewCurrentView();
				if (_openRequestFromDeveloper) {
					view = ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START;
					ApplifierImpactUtils.Log("changeActivity: This open request is from the developer, setting start view", this);
				}
				
				open(view);
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
			_developerOptions = options;
			
			if (_developerOptions != null) {
				if (_developerOptions.containsKey(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY) && _developerOptions.get(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY).equals(true)) {
					if (webdata.getViewableVideoPlanCampaigns().size() > 0) {
						ApplifierImpactCampaign selectedCampaign = webdata.getViewableVideoPlanCampaigns().get(0);
						ApplifierImpactProperties.SELECTED_CAMPAIGN = selectedCampaign;
					}
				}
				if (_developerOptions.containsKey(APPLIFIER_IMPACT_OPTION_GAMERSID_KEY) && _developerOptions.get(APPLIFIER_IMPACT_OPTION_GAMERSID_KEY) != null) {
					ApplifierImpactProperties.GAMER_SID = "" + _developerOptions.get(APPLIFIER_IMPACT_OPTION_GAMERSID_KEY);
				}
			}
			
			return showImpact();
		}
		
		return false;
	}
	
	public boolean showImpact () {
		if (canShowImpact()) {
			startImpactFullscreenActivity();
			_showingImpact = true;
			_openRequestFromDeveloper = true;
			return _showingImpact;
		}

		return false;
	}
	
	public boolean canShowCampaigns () {
		return _mainView != null && _mainView.webview != null && _mainView.webview.isWebAppLoaded() && _webAppLoaded && webdata != null && webdata.getViewableVideoPlanCampaigns().size() > 0;
	}
	
	public boolean canShowImpact () {
		return !_showingImpact && _mainView != null && _mainView.webview != null && _mainView.webview.isWebAppLoaded() && _webAppLoaded && webdata != null && webdata.getVideoPlanCampaigns().size() > 0;
	}

	public void stopAll () {
		ApplifierImpactUtils.Log("stopAll()", this);
		ApplifierImpactDownloader.stopAllDownloads();
		webdata.stopAllRequests();
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
		ApplifierImpactRewardItem rewardItem = webdata.getRewardItemByKey(rewardItemKey);
		
		if (rewardItem != null) {
			webdata.setCurrentRewardItem(rewardItem);
			return true;
		}
		
		return false;
	}
	
	public void setDefaultRewardItemAsRewardItem () {
		if (webdata != null && webdata.getDefaultRewardItem() != null) {
			webdata.setCurrentRewardItem(webdata.getDefaultRewardItem());
		}
	}
	
	public Map<String, String> getRewardItemDetailsWithKey (String rewardItemKey) {
		ApplifierImpactRewardItem rewardItem = webdata.getRewardItemByKey(rewardItemKey);
		if (rewardItem != null) {
			return rewardItem.getDetails();
		}
		
		return null;
	}
	
	
	/* LISTENER METHODS */
	
	// IApplifierImpactMainViewListener
	public void onMainViewAction (ApplifierImpactMainViewAction action) {
		switch (action) {
			case BackButtonPressed:
				close();
				break;
			case VideoStart:
				if (_impactListener != null)
					_impactListener.onVideoStarted();
				break;
			case VideoEnd:
				if (_impactListener != null)
					_impactListener.onVideoCompleted();
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
	@Override
	public void onWebDataCompleted () {
		setup();
	}
	
	@Override
	public void onWebDataFailed () {
		if (_impactListener != null)
			_impactListener.onCampaignsFetchFailed();
	}
	
	
	// IApplifierImpactWebBrigeListener
	@Override
	public void onPlayVideo(JSONObject data) {
		if (data.has(ApplifierImpactConstants.IMPACT_WEBVIEW_EVENTDATA_CAMPAIGNID_KEY)) {
			String campaignId = null;
			
			try {
				campaignId = data.getString(ApplifierImpactConstants.IMPACT_WEBVIEW_EVENTDATA_CAMPAIGNID_KEY);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not get campaignId", this);
			}
			
			if (campaignId != null) {
				ApplifierImpactProperties.SELECTED_CAMPAIGN = webdata.getCampaignById(campaignId);
				Boolean rewatch = false;
				
				try {
					rewatch = data.getBoolean(ApplifierImpactConstants.IMPACT_WEBVIEW_EVENTDATA_REWATCH_KEY);
				}
				catch (Exception e) {
				}
				
				if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null && (rewatch || !ApplifierImpactProperties.SELECTED_CAMPAIGN.isViewed())) {
					playVideo();
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
				_mainView.webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, setViewData);
				sendImpactReadyEvent();			
			}
		}
	}
	
	public void onOpenPlayStore (JSONObject data) {
	    ApplifierImpactUtils.Log("onOpenPlayStore", this);
		if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null && ApplifierImpactProperties.SELECTED_CAMPAIGN.getStoreId() != null) {
			try {
			    ApplifierImpactUtils.Log("Opening playstore activity with storeId: " + ApplifierImpactProperties.SELECTED_CAMPAIGN.getStoreId(), this);
				ApplifierImpactProperties.CURRENT_ACTIVITY.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + ApplifierImpactProperties.SELECTED_CAMPAIGN.getStoreId())));
			} 
			catch (android.content.ActivityNotFoundException anfe) {
			    ApplifierImpactUtils.Log("Could not open PlayStore activity, opening in browser with storeId: " + ApplifierImpactProperties.SELECTED_CAMPAIGN.getStoreId(), this);
				ApplifierImpactProperties.CURRENT_ACTIVITY.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=" + ApplifierImpactProperties.SELECTED_CAMPAIGN.getStoreId())));
			}
		}
		else {
		    ApplifierImpactUtils.Log("Selected campaign (" + ApplifierImpactProperties.SELECTED_CAMPAIGN + ") or couldn't get storeId", this);
		}
	}
	

	/* PRIVATE METHODS */
	
	private void init (Activity activity, String gameId, IApplifierImpactListener listener) {
		instance = this;
		ApplifierImpactProperties.IMPACT_GAME_ID = gameId;
		ApplifierImpactProperties.BASE_ACTIVITY = activity;
		ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
		
		ApplifierImpactUtils.Log(Build.FINGERPRINT, this);
		
		if (_initialized) return; 
		
		cachemanager = new ApplifierImpactCacheManager();
		cachemanager.setDownloadListener(this);
		webdata = new ApplifierImpactWebData();
		webdata.setWebDataListener(this);

		if (webdata.initCampaigns()) {
			_initialized = true;
		}
	}
	
	private void close () {
		ApplifierImpactCloseRunner closeRunner = new ApplifierImpactCloseRunner();
		ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(closeRunner);
	}
	
	private void open (String view) {
		Boolean dataOk = true;			
		JSONObject data = new JSONObject();
		
		try  {
			data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_OPEN);
			data.put(ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY, webdata.getCurrentRewardItemKey());
		}
		catch (Exception e) {
			dataOk = false;
		}

		ApplifierImpactUtils.Log("open() dataOk: " + dataOk, this);
		
		if (dataOk && view != null) {
			ApplifierImpactUtils.Log("open() opening with view:" + view + " and data:" + data.toString(), this);
			_mainView.openImpact(view, data);
			
			if (_developerOptions != null && _developerOptions.containsKey(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY)  && _developerOptions.get(APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY).equals(true))
				playVideo();
			
			if (_impactListener != null)
				_impactListener.onImpactOpen();
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
		_mainView = new ApplifierImpactMainView(ApplifierImpactProperties.CURRENT_ACTIVITY, this);
	}

	private void playVideo () {
		ApplifierImpactPlayVideoRunner playVideoRunner = new ApplifierImpactPlayVideoRunner();
		ApplifierImpactUtils.Log("Running threaded", this);
		ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(playVideoRunner);
	}
	
	private void startImpactFullscreenActivity () {
		Intent newIntent = new Intent(ApplifierImpactProperties.CURRENT_ACTIVITY, com.applifier.impact.android.view.ApplifierImpactFullscreenActivity.class);
		int flags = Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK;
		
		if (_developerOptions != null && _developerOptions.containsKey(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY) && _developerOptions.get(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY).equals(true))
			flags = Intent.FLAG_ACTIVITY_NEW_TASK;
		
		newIntent.addFlags(flags);
		ApplifierImpactProperties.BASE_ACTIVITY.startActivity(newIntent);
	}
	
	
	/* INTERNAL CLASSES */

	// FIX: Could these 2 classes be moved to MainView
	
	private class ApplifierImpactCloseRunner implements Runnable {
		@Override
		public void run() {
			_showingImpact = false;
			if (ApplifierImpactProperties.CURRENT_ACTIVITY.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
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
					_mainView.closeImpact(data);
					ApplifierImpactProperties.CURRENT_ACTIVITY.finish();
					
					if (_developerOptions == null || !_developerOptions.containsKey(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY) || _developerOptions.get(APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY).equals(false))
						ApplifierImpactProperties.CURRENT_ACTIVITY.overridePendingTransition(0, 0);
					
					if (_impactListener != null)
						_impactListener.onImpactClose();
				}
			}
			
			// Reset developer options when impact closes
			_developerOptions = null;
		}
	}
	
	private class ApplifierImpactPlayVideoRunner implements Runnable {
		@Override
		public void run() {			
			if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null) {
				JSONObject data = new JSONObject();
				
				try {
					data.put(ApplifierImpactConstants.IMPACT_TEXTKEY_KEY, ApplifierImpactConstants.IMPACT_TEXTKEY_BUFFERING);
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Couldn't create data JSON", this);
					return;
				}
				
				_mainView.webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_SHOWSPINNER, data);
				
				String playUrl = ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactProperties.SELECTED_CAMPAIGN.getVideoFilename();
				if (!ApplifierImpactUtils.isFileInCache(ApplifierImpactProperties.SELECTED_CAMPAIGN.getVideoFilename()))
					playUrl = ApplifierImpactProperties.SELECTED_CAMPAIGN.getVideoStreamUrl(); 

				_mainView.setViewState(ApplifierImpactMainViewState.VideoPlayer);
				_mainView.videoplayerview.playVideo(playUrl);
			}			
			else
				ApplifierImpactUtils.Log("Campaign is null", this);
		}		
	}
}
