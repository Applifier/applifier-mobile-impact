package com.applifier.impact.android;

import java.util.ArrayList;

import org.json.JSONObject;

import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.cache.ApplifierImpactCacheManifest;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactCacheListener;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignListener;
import com.applifier.impact.android.video.ApplifierImpactVideoPlayView;
import com.applifier.impact.android.video.IApplifierImpactVideoListener;
import com.applifier.impact.android.video.IApplifierImpactVideoPlayerListener;
import com.applifier.impact.android.view.IApplifierImpactViewListener;
import com.applifier.impact.android.webapp.*;

import android.app.Activity;
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
	public static ApplifierImpactCacheManifest cachemanifest = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	
	// Temporary data
	private boolean _initialized = false;
	private boolean _showingImpact = false;
	private boolean _impactReadySent = false;
	
	// Views
	private ApplifierImpactVideoPlayView _vp = null;
	private ApplifierImpactWebView _webView = null;
	
	// Listeners
	private IApplifierImpactListener _impactListener = null;
	private IApplifierImpactCampaignListener _campaignListener = null;
	private IApplifierImpactVideoListener _videoListener = null;
	
	// Currently Selected Campaign (for viewing)
	private ApplifierImpactCampaign _selectedCampaign = null;	
	
	
	public ApplifierImpact (Activity activity, String applifierId) {
		instance = this;
		ApplifierImpactProperties.IMPACT_APP_ID = applifierId;
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
		cachemanifest = new ApplifierImpactCacheManifest();
		webdata = new ApplifierImpactWebData();
		webdata.setWebDataListener(this);
		
		if (webdata.initVideoPlan(cachemanifest.getCachedCampaignIds())) {
			_initialized = true;
		}
	}
		
	public void changeActivity (Activity activity) {
		if (activity == null) return;
		ApplifierImpactProperties.CURRENT_ACTIVITY = activity;
	}
	
	public boolean showImpact () {
		selectCampaign();
		
		if (!_showingImpact && _selectedCampaign != null && _webView != null && _webView.isWebAppLoaded()) {
			ApplifierImpactProperties.CURRENT_ACTIVITY.addContentView(_webView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
			focusToView(_webView);
			_webView.setView("videoStart");
			_webView.setSelectedCampaign(_selectedCampaign);
			_showingImpact = true;	
			
			if (_impactListener != null)
				_impactListener.onImpactOpen();
			
			return _showingImpact;
		}
		
		return false;
	}
		
	public boolean hasCampaigns () {
		if (cachemanifest != null && canShowCampaigns()) {
			return cachemanifest.getViewableCachedCampaigns().size() > 0;
		}
		
		return false;
	}
	
	public void stopAll () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "ApplifierImpact->stopAll()");
		ApplifierImpactDownloader.stopAllDownloads();
		webdata.stopAllRequests();
	}
	
	
	/* LISTENER METHODS */
	
	// IApplifierImpactCacheListener
	@Override
	public void onCampaignUpdateStarted () {	
		Log.d(ApplifierImpactProperties.LOG_NAME, "Campaign updates started.");
	}
	
	@Override
	public void onCampaignReady (ApplifierImpactCampaignHandler campaignHandler) {
		if (campaignHandler == null || campaignHandler.getCampaign() == null) return;
				
		Log.d(ApplifierImpactProperties.LOG_NAME, "Got onCampaignReady: " + campaignHandler.getCampaign().toString());
		
		if (!cachemanifest.addCampaignToManifest(campaignHandler.getCampaign()))
			cachemanifest.updateCampaignInManifest(campaignHandler.getCampaign());
		
		if (canShowCampaigns())
			sendImpactReadyEvent();
	}
	
	@Override
	public void onAllCampaignsReady () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Listener got \"All campaigns ready.\"");
	}
	
	// IApplifierImpactWebDataListener
	@Override
	public void onWebDataCompleted () {
		setup();
	}
	
	@Override
	public void onWebDataFailed () {
		setup();
	}
	
	// IApplifierImpactWebViewListener
	@Override
	public void onWebAppLoaded () {
		ArrayList<ApplifierImpactCampaign> campaignList = solveCurrentCampaigns();
		
		if (campaignList != null)
			_webView.setAvailableCampaigns(ApplifierImpactUtils.createJsonFromCampaigns(campaignList).toString());
		
		_webView.setDeviceId(ApplifierImpactUtils.getDeviceId(ApplifierImpactProperties.CURRENT_ACTIVITY));
		
		if (canShowCampaigns())
			sendImpactReadyEvent();
	}
	
	// IApplifierImpactViewListener
	@Override
	public void onCloseButtonClicked (View view) {
		closeView(view, true);
	}
	
	@Override
	public void onBackButtonClicked (View view) {
		closeView(view, true);
	}
	
	// IApplifierImpactWebBrigeListener
	@Override
	public void onPlayVideo(JSONObject data) {
		ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new ApplifierImpactPlayVideoRunner());
	}

	@Override
	public void onPauseVideo(JSONObject data) {
		if (_vp != null)
			_vp.pauseVideo();
	}

	@Override
	public void onCloseView(JSONObject data) {
		ApplifierImpactCloseViewRunner closeViewRunner = new ApplifierImpactCloseViewRunner(_webView, true);
		ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(closeViewRunner);
	}
	
	// IApplifierImpactVideoPlayerListener

	@Override
	public void onCompletion(MediaPlayer mp) {				
		if (_videoListener != null)
			_videoListener.onVideoCompleted();
		
		_selectedCampaign.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
		cachemanifest.writeCurrentCacheManifest();
		webdata.sendCampaignViewed(_selectedCampaign);
		_vp.setKeepScreenOn(false);
		closeView(_vp, false);
		
		_webView.setView("videoCompleted");
		ApplifierImpactProperties.CURRENT_ACTIVITY.addContentView(_webView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
		focusToView(_webView);
		_selectedCampaign = null;
	}
	
	
	/* PRIVATE METHODS */
	
	private void setup () {
		initCache();
		setupViews();
	}
	
	private void initCache () {
		if (_initialized) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Init cache");
			// Campaigns that were received in the videoPlan
			ArrayList<ApplifierImpactCampaign> videoPlanCampaigns = solveCurrentCampaigns();
			// Campaigns that were in cache but were not returned in the videoPlan (old or not current)
			ArrayList<ApplifierImpactCampaign> pruneList = solvePruneList();
				
			// If current videoPlan is null (nothing in the cache either), just forget going any further.
			if (videoPlanCampaigns == null || videoPlanCampaigns.size() == 0) return;
			
			// Update cache WILL START DOWNLOADS if needed, after this method you can check getDownloadingCampaigns which ones started downloading.
			cachemanager.updateCache(videoPlanCampaigns, pruneList);				
		}
	}
	
	private ArrayList<ApplifierImpactCampaign> solveCurrentCampaigns () {
		ArrayList<ApplifierImpactCampaign> campaigns = webdata.getVideoPlanCampaigns();
		if (campaigns == null)
			campaigns = cachemanifest.getCachedCampaigns();
		
		return campaigns;
	}
	
	private ArrayList<ApplifierImpactCampaign> solvePruneList () {
		if (webdata.getVideoPlanCampaigns() == null) return null;		
		return ApplifierImpactUtils.substractFromCampaignList(cachemanifest.getCachedCampaigns(), webdata.getVideoPlanCampaigns());		
	}
	
	private boolean canShowCampaigns () {
		return _webView != null && _webView.isWebAppLoaded() && cachemanifest.getViewableCachedCampaignAmount() > 0;
	}
	
	private void sendImpactReadyEvent () {
		if (!_impactReadySent && _campaignListener != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Impact ready!");
			_impactReadySent = true;
			_campaignListener.onCampaignsAvailable();
		}
	}
	
	private void selectCampaign () {
		ArrayList<ApplifierImpactCampaign> viewableCampaigns = cachemanifest.getViewableCachedCampaigns();
		
		if (viewableCampaigns != null && viewableCampaigns.size() > 0) {
			int campaignIndex = (int)Math.round(Math.random() * (viewableCampaigns.size() - 1));
			Log.d(ApplifierImpactProperties.LOG_NAME, "Selected campaign " + (campaignIndex + 1) + ", out of " + viewableCampaigns.size());
			_selectedCampaign = viewableCampaigns.get(campaignIndex);		
		}
	}

	private void closeView (View view, boolean freeView) {
		view.setFocusable(false);
		view.setFocusableInTouchMode(false);
		
		ViewGroup vg = (ViewGroup)view.getParent();
		if (vg != null)
			vg.removeView(view);
		
		if (_impactListener != null && freeView) {
			_showingImpact = false;
			_impactListener.onImpactClose();
		}		
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
	
	private class ApplifierImpactCloseViewRunner implements Runnable {
		private View _view = null;
		private boolean _freeView = false;
		
		public ApplifierImpactCloseViewRunner (View view, boolean freeView) {
			_view = view;
			_freeView = freeView;
		}
		
		@Override
		public void run() {
			closeView(_view, _freeView);
		}
	}
	
	private class ApplifierImpactPlayVideoRunner implements Runnable {
		@Override
		public void run() {
			closeView(_webView, false);
			ApplifierImpactProperties.CURRENT_ACTIVITY.addContentView(_vp, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
			focusToView(_vp);
			
			if (_selectedCampaign != null) {
				String playUrl = ApplifierImpactUtils.getCacheDirectory() + "/" + _selectedCampaign.getVideoFilename();
				if (!ApplifierImpactUtils.isFileInCache(_selectedCampaign.getVideoFilename()))
					playUrl = _selectedCampaign.getVideoStreamUrl(); 

				_vp.playVideo(playUrl);
			}			
			else
				Log.d(ApplifierImpactProperties.LOG_NAME, "Campaign is null");
						
			if (_videoListener != null)
				_videoListener.onVideoStarted();
		}		
	}
}
