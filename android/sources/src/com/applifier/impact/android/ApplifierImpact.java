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
import com.applifier.impact.android.view.IApplifierImpactViewListener;
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
										IApplifierImpactWebViewListener, 
										IApplifierImpactVideoPlayerListener,
										IApplifierImpactWebBrigeListener,
										IApplifierImpactViewListener {
	
	// Impact components
	public static ApplifierImpact instance = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	
	// Temporary data
	private boolean _initialized = false;
	private boolean _showingImpact = false;
	private boolean _impactReadySent = false;
	private boolean _webAppLoaded = false;
	
	// Views
	private ApplifierImpactVideoPlayView _vp = null;
	private ApplifierImpactWebView _webView = null;
	
	// Listeners
	private IApplifierImpactListener _impactListener = null;
	private IApplifierImpactCampaignListener _campaignListener = null;
	private IApplifierImpactVideoListener _videoListener = null;
	
	// Currently Selected Campaign (for viewing)
	private ApplifierImpactCampaign _selectedCampaign = null;	
	
	
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
		
		ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
				
		if (activity.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
			open();
			applyImpactToActivity(ApplifierImpactProperties.CURRENT_ACTIVITY);
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
		Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpact->stopAll()");
		ApplifierImpactDownloader.stopAllDownloads();
		webdata.stopAllRequests();
	}
	
	
	/* LISTENER METHODS */
	
	// IApplifierImpactCacheListener
	@Override
	public void onCampaignUpdateStarted () {	
		Log.d(ApplifierImpactConstants.LOG_NAME, "Campaign updates started.");
	}
	
	@Override
	public void onCampaignReady (ApplifierImpactCampaignHandler campaignHandler) {
		if (campaignHandler == null || campaignHandler.getCampaign() == null) return;
				
		Log.d(ApplifierImpactConstants.LOG_NAME, "Got onCampaignReady: " + campaignHandler.getCampaign().toString());
		
		if (canShowCampaigns())
			sendImpactReadyEvent();
	}
	
	@Override
	public void onAllCampaignsReady () {
		Log.d(ApplifierImpactConstants.LOG_NAME, "Listener got \"All campaigns ready.\"");
	}
	
	// IApplifierImpactWebDataListener
	@Override
	public void onWebDataCompleted () {
		setup();
	}
	
	@Override
	public void onWebDataFailed () {
	}
	
	// IApplifierImpactWebViewListener
	@Override
	public void onWebAppLoaded () {
		_webView.initWebApp(webdata.getData());
	}

	@Override
	public void onBackButtonClicked (View view) {
		closeImpact();
	}
	
	// IApplifierImpactWebBrigeListener
	@Override
	public void onPlayVideo(JSONObject data) {
		if (data.has("campaignId")) {
			String campaignId = null;
			
			try {
				campaignId = data.getString("campaignId");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactConstants.LOG_NAME, "Could not get campaignId");
			}
			
			if (campaignId != null) {
				_selectedCampaign = webdata.getCampaignById(campaignId);
				
				if (_selectedCampaign != null) {
					ApplifierImpactPlayVideoRunner playVideoRunner = new ApplifierImpactPlayVideoRunner();
					Log.d(ApplifierImpactConstants.LOG_NAME, "Running threaded");
					ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(playVideoRunner);

				}
			}
		}
	}

	@Override
	public void onPauseVideo(JSONObject data) {
		if (_vp != null)
			_vp.pauseVideo();
	}

	@Override
	public void onCloseView(JSONObject data) {
		closeImpact();
	}
	
	@Override
	public void onWebAppInitComplete (JSONObject data) {
		Log.d(ApplifierImpactConstants.LOG_NAME, "WebAppInitComplete");
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
				_webView.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, setViewData);
				sendImpactReadyEvent();			
			}
		}
	}
	
	// IApplifierImpactVideoPlayerListener
	@Override
	public void onEventPositionReached (ApplifierVideoPosition position) {
		if (position.equals(ApplifierVideoPosition.Start)) {
			JSONObject params = null;
			
			try {
				params = new JSONObject("{\"campaignId\":\"" + _selectedCampaign.getCampaignId() + "\"}");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactConstants.LOG_NAME, "Could not create JSON");
			}
			
			//_webView.setWebViewCurrentView("completed", params);
			showVideoPlayer();
			_webView.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_COMPLETED, params);
		}
		
		if (_selectedCampaign != null && !_selectedCampaign.getCampaignStatus().equals(ApplifierImpactCampaignStatus.VIEWED))
			webdata.sendCampaignViewProgress(_selectedCampaign, position);
	}
	
	@Override
	public void onCompletion(MediaPlayer mp) {				
		if (_videoListener != null)
			_videoListener.onVideoCompleted();
		
		// Set unspecified orientation after video ends.
		ApplifierImpactProperties.CURRENT_ACTIVITY.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
		
		_vp.setKeepScreenOn(false);
		hideView(_vp);
		
		/*
		JSONObject params = null;
		
		try {
			params = new JSONObject("{\"campaignId\":\"" + _selectedCampaign.getCampaignId() + "\"}");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactConstants.LOG_NAME, "Could not create JSON");
		}
		
		_webView.setWebViewCurrentView("completed", params);
		*/
		ApplifierImpactProperties.CURRENT_ACTIVITY.addContentView(_webView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
		focusToView(_webView);
		onEventPositionReached(ApplifierVideoPosition.End);
		_selectedCampaign.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
		_selectedCampaign = null;
	}
	
	
	/* PRIVATE METHODS */
	
	private void close () {
		ApplifierImpactCloseRunner closeRunner = new ApplifierImpactCloseRunner();
		ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(closeRunner);
	}
	
	private void open () {
		Boolean dataOk = true;			
		JSONObject data = new JSONObject();
		
		Log.d(ApplifierImpactConstants.LOG_NAME, "dataOk: " + dataOk);
		
		try  {
			data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_OPEN);
			data.put(ApplifierImpactConstants.IMPACT_REWARD_ITEMKEY_KEY, webdata.getCurrentRewardItemKey());
		}
		catch (Exception e) {
			dataOk = false;
		}

		if (dataOk) {
			_webView.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, data);
		}
	}
	
	private void applyImpactToActivity (Activity activity) {
		activity.addContentView(_webView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
		focusToView(_webView);
	}
	
	private void setup () {
		initCache();
		setupViews();
	}
	
	private void initCache () {
		if (_initialized) {
			Log.d(ApplifierImpactConstants.LOG_NAME, "Init cache");
			// Update cache WILL START DOWNLOADS if needed, after this method you can check getDownloadingCampaigns which ones started downloading.
			cachemanager.updateCache(webdata.getVideoPlanCampaigns());				
		}
	}
	
	private boolean canShowCampaigns () {
		return _webView != null && _webView.isWebAppLoaded() && _webAppLoaded && webdata.getViewableVideoPlanCampaigns().size() > 0;
	}
	
	private void sendImpactReadyEvent () {
		if (!_impactReadySent && _campaignListener != null) {
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {				
				@Override
				public void run() {
					Log.d(ApplifierImpactConstants.LOG_NAME, "Impact ready!");
					_impactReadySent = true;
					_campaignListener.onCampaignsAvailable();
				}
			});
		}
	}

	private void showVideoPlayer () {
		if (_vp.getParent() == null) {
			hideView(_webView);
			ApplifierImpactProperties.CURRENT_ACTIVITY.addContentView(_vp, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
			focusToView(_vp);
		}
	}
	
	private void hideView (View view) {
		if (view != null) {
			view.setFocusable(false);
			view.setFocusableInTouchMode(false);
		}
		
		ViewGroup vg = (ViewGroup)view.getParent();
		if (vg != null)
			vg.removeView(view);
	}
	
	private void focusToView (View view) {
		view.setFocusable(true);
		view.setFocusableInTouchMode(true);
		view.requestFocus();
	}
	
	private void setupViews () {
		_webView = new ApplifierImpactWebView(ApplifierImpactProperties.CURRENT_ACTIVITY, this, new ApplifierImpactWebBridge(this));	
		_vp = new ApplifierImpactVideoPlayView(ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext(), this);	
	}

	
	/* INTERNAL CLASSES */

	private class ApplifierImpactCloseRunner implements Runnable {
		@Override
		public void run() {
			_showingImpact = false;
			if (ApplifierImpactProperties.CURRENT_ACTIVITY.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
				hideView(_webView);
				hideView(_vp);
				ApplifierImpactProperties.CURRENT_ACTIVITY.finish();
				
				Boolean dataOk = true;			
				JSONObject data = new JSONObject();
				
				Log.d(ApplifierImpactConstants.LOG_NAME, "dataOk: " + dataOk);
				
				try  {
					data.put(ApplifierImpactConstants.IMPACT_WEBVIEW_API_ACTION_KEY, ApplifierImpactConstants.IMPACT_WEBVIEW_API_CLOSE);
				}
				catch (Exception e) {
					dataOk = false;
				}

				if (dataOk) {
					_webView.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, data);
				}
			}
		}
	}
	
	private class ApplifierImpactPlayVideoRunner implements Runnable {
		@Override
		public void run() {			
			if (_selectedCampaign != null) {
				String playUrl = ApplifierImpactUtils.getCacheDirectory() + "/" + _selectedCampaign.getVideoFilename();
				if (!ApplifierImpactUtils.isFileInCache(_selectedCampaign.getVideoFilename()))
					playUrl = _selectedCampaign.getVideoStreamUrl(); 

				_vp.playVideo(playUrl);
			}			
			else
				Log.d(ApplifierImpactConstants.LOG_NAME, "Campaign is null");
						
			if (_videoListener != null) {
				_videoListener.onVideoStarted();
			}
		}		
	}
}
