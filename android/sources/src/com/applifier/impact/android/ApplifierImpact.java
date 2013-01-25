package com.applifier.impact.android;

import org.json.JSONObject;

import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactCacheListener;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignListener;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;
import com.applifier.impact.android.video.ApplifierImpactVideoPlayView;
import com.applifier.impact.android.video.IApplifierImpactVideoListener;
import com.applifier.impact.android.video.IApplifierImpactVideoPlayerListener;
import com.applifier.impact.android.view.ApplifierImpactMainView;
import com.applifier.impact.android.view.IApplifierImpactMainViewListener;
import com.applifier.impact.android.view.IApplifierImpactViewListener;
import com.applifier.impact.android.view.ApplifierImpactMainView.ApplifierImpactMainViewAction;
import com.applifier.impact.android.view.ApplifierImpactMainView.ApplifierImpactMainViewState;
import com.applifier.impact.android.webapp.*;
import com.applifier.impact.android.webapp.ApplifierImpactWebData.ApplifierVideoPosition;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

public class ApplifierImpact implements IApplifierImpactCacheListener, 
										IApplifierImpactWebDataListener, 
										IApplifierImpactWebBrigeListener,
										IApplifierImpactMainViewListener {
	
	// Impact components
	public static ApplifierImpact instance = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	
	// Temporary data
	private boolean _initialized = false;
	private boolean _showingImpact = false;
	private boolean _impactReadySent = false;
	private boolean _webAppLoaded = false;
		
	// Main View
	private ApplifierImpactMainView _mainView = null;
	
	// Listeners
	private IApplifierImpactListener _impactListener = null;
	private IApplifierImpactCampaignListener _campaignListener = null;
	private IApplifierImpactVideoListener _videoListener = null;
	
	
	public ApplifierImpact (Activity activity, String gameId) {
		instance = this;
		ApplifierImpactProperties.IMPACT_GAME_ID = gameId;
		ApplifierImpactProperties.BASE_ACTIVITY = activity;
		ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
	}
		
	public void setImpactListener (IApplifierImpactListener listener) {
		_impactListener = listener;
	}
	
	public void setCampaignListener (IApplifierImpactCampaignListener listener) {
		_campaignListener = listener;
	}
	
	public void setVideoListener (IApplifierImpactVideoListener listener) {
		_videoListener = listener;
	}
	
	public void init () {
		if (_initialized) return; 
		
		cachemanager = new ApplifierImpactCacheManager();
		cachemanager.setDownloadListener(this);
		webdata = new ApplifierImpactWebData();
		webdata.setWebDataListener(this);

		if (webdata.initCampaigns()) {
			_initialized = true;
		}
	}
		
	public void changeActivity (Activity activity) {
		if (activity == null) return;
		
		if (!activity.equals(ApplifierImpactProperties.CURRENT_ACTIVITY)) {
			ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
			
			// Not the most pretty way to detect when the fullscreen activity is ready
			if (activity.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
				open();
			}
		}
	}
	
	public boolean closeImpact () {
		if (_showingImpact) {
			close();
			return true;
		}
		
		return false;
	}
	
	public boolean showImpact () {
		if (!_showingImpact && canShowCampaigns()) {
			Intent newIntent = new Intent(ApplifierImpactProperties.CURRENT_ACTIVITY, com.applifier.impact.android.view.ApplifierImpactFullscreenActivity.class);
			newIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK);
			ApplifierImpactProperties.CURRENT_ACTIVITY.startActivity(newIntent);
			_showingImpact = true;	
			return _showingImpact;
		}

		return false;
	}
		
	public boolean hasCampaigns () {
		if (webdata != null && canShowCampaigns()) {
			return webdata.getViewableVideoPlanCampaigns().size() > 0;
		}
		
		return false;
	}
	
	public void stopAll () {
		ApplifierImpactUtils.Log("stopAll()", this);
		ApplifierImpactDownloader.stopAllDownloads();
		webdata.stopAllRequests();
	}
	
	
	/* LISTENER METHODS */
	
	// IApplifierImpactMainViewListener
	public void onMainViewAction (ApplifierImpactMainViewAction action) {
		switch (action) {
			case BackButtonPressed:
				close();
				break;
			case VideoStart:
				if (_videoListener != null)
					_videoListener.onVideoStarted();
				break;
			case VideoEnd:
				if (_videoListener != null)
					_videoListener.onVideoCompleted();
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
					ApplifierImpactPlayVideoRunner playVideoRunner = new ApplifierImpactPlayVideoRunner();
					ApplifierImpactUtils.Log("Running threaded", this);
					ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(playVideoRunner);
				}
			}
		}
	}

	@Override
	public void onPauseVideo(JSONObject data) {
	}

	@Override
	public void onCloseImpactView(JSONObject data) {
		closeImpact();
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
	

	/* PRIVATE METHODS */
	
	private void close () {
		ApplifierImpactCloseRunner closeRunner = new ApplifierImpactCloseRunner();
		ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(closeRunner);
	}
	
	private void open () {
		Boolean dataOk = true;			
		JSONObject data = new JSONObject();
		
		ApplifierImpactUtils.Log("dataOk: " + dataOk, this);
		
		try  {
			data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_OPEN);
			data.put(ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY, webdata.getCurrentRewardItemKey());
		}
		catch (Exception e) {
			dataOk = false;
		}

		if (dataOk) {
			_mainView.openImpact(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, data);
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
	
	private boolean canShowCampaigns () {
		return _mainView != null && _mainView.webview != null && _mainView.webview.isWebAppLoaded() && _webAppLoaded && webdata.getViewableVideoPlanCampaigns().size() > 0;
	}
	
	private void sendImpactReadyEvent () {
		if (!_impactReadySent && _campaignListener != null) {
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {				
				@Override
				public void run() {
					ApplifierImpactUtils.Log("Impact ready!", this);
					_impactReadySent = true;
					_campaignListener.onCampaignsAvailable();
				}
			});
		}
	}

	private void setupViews () {
		_mainView = new ApplifierImpactMainView(ApplifierImpactProperties.CURRENT_ACTIVITY, this);
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
				
				ApplifierImpactUtils.Log("dataOk: " + dataOk, this);
				
				try  {
					data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_CLOSE);
				}
				catch (Exception e) {
					dataOk = false;
				}

				if (dataOk) {
					_mainView.closeImpact(data);
					ApplifierImpactProperties.CURRENT_ACTIVITY.finish();
				}
			}
		}
	}
	
	private class ApplifierImpactPlayVideoRunner implements Runnable {
		@Override
		public void run() {			
			if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null) {
				
				/*
				[[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner 
				data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
				*/
				
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
