package com.applifier.impact.android;

import java.util.ArrayList;

import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.cache.ApplifierImpactCacheManifest;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.ApplifierImpactWebData;
import com.applifier.impact.android.cache.IApplifierCacheListener;
import com.applifier.impact.android.cache.IApplifierImpactWebDataListener;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignListener;
import com.applifier.impact.android.video.IApplifierImpactVideoListener;
import com.applifier.impact.android.view.ApplifierVideoCompletedView;
import com.applifier.impact.android.view.ApplifierVideoPlayView;
import com.applifier.impact.android.view.ApplifierVideoSelectView;

import android.app.Activity;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

// TODO: No native UI. Use webview for everything else than video.
public class ApplifierImpact implements IApplifierCacheListener, IApplifierImpactWebDataListener {
	
	// Impact components
	public static ApplifierImpact instance = null;
	public static ApplifierImpactCacheManifest cachemanifest = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	
	// Temporary data
	private Activity _currentActivity = null;
	private boolean _initialized = false;
	private boolean _showingImpact = false;
	
	// Views
	private ApplifierVideoSelectView _vs = null;
	private ApplifierVideoPlayView _vp = null;
	private ApplifierVideoCompletedView _vc = null;
	
	// Listeners
	private IApplifierImpactListener _impactListener = null;
	private IApplifierImpactCampaignListener _campaignListener = null;
	private IApplifierImpactVideoListener _videoListener = null;
	
	// Currently Selected Campaign (for viewing)
	private ApplifierImpactCampaign _selectedCampaign = null;	
	
	
	public ApplifierImpact (Activity activity, String applifierId) {
		instance = this;
		ApplifierImpactProperties.IMPACT_APP_ID = applifierId;
		ApplifierImpactProperties.ROOT_ACTIVITY = activity;
		_currentActivity = activity;
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
		_currentActivity = activity;
		
		if (_vp != null)
			_vp.setActivity(_currentActivity);
	}
	
	public boolean showImpact () {
		selectCampaign();
		
		if (!_showingImpact && _selectedCampaign != null) {
			_currentActivity.addContentView(_vs, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
			focusToView(_vs);
			_showingImpact = true;	
			
			if (_impactListener != null)
				_impactListener.onImpactOpen();
			
			return _showingImpact;
		}
		
		return false;
	}
	
	public void closeImpactView (View view, boolean freeView) {
		view.setFocusable(false);
		view.setFocusableInTouchMode(false);
		
		ViewGroup vg = (ViewGroup)view.getParent();
		if (vg != null)
			vg.removeView(view);
		
		if (_impactListener != null && freeView) {
			_selectedCampaign = null;
			_showingImpact = false;
			_impactListener.onImpactClose();
		}
	}
	
	public boolean hasCampaigns () {
		if (cachemanifest != null) {
			return cachemanifest.getCachedCampaignAmount() > 0;
		}
		
		return false;
	}
	
	public void stopAll () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "ApplifierImpact->stopAll()");
		ApplifierImpactDownloader.stopAllDownloads();
		webdata.stopAllRequests();
	}
	
	
	/* LISTENER METHODS */
	
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
		
		if (_campaignListener != null && cachemanifest.getViewableCachedCampaignAmount() > 0) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Reporting cached campaigns available");
			_campaignListener.onCampaignsAvailable();
		}
	}
	
	@Override
	public void onAllCampaignsReady () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Listener got \"All campaigns ready.\"");
	}
	
	@Override
	public void onWebDataCompleted () {
		initCache();
	}
	
	@Override
	public void onWebDataFailed () {
		initCache();
	}
	
	
	/* PRIVATE METHODS */
	
	private void initCache () {
		if (_initialized) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Init cache");
			// Campaigns that are currently cached
			ArrayList<ApplifierImpactCampaign> cachedCampaigns = cachemanifest.getCachedCampaigns();
			// Campaigns that were received in the videoPlan
			ArrayList<ApplifierImpactCampaign> videoPlanCampaigns = webdata.getVideoPlanCampaigns();
			// Campaigns that were in cache but were not returned in the videoPlan (old or not current)
			ArrayList<ApplifierImpactCampaign> pruneList = ApplifierImpactUtils.substractFromCampaignList(cachedCampaigns, videoPlanCampaigns);
			
			// If campaigns from web-data is null something has probably gone wrong, try to maintain something viewable by setting
			// the videoPlan campaigns from current cache and running them through.
			if (videoPlanCampaigns == null) {
				videoPlanCampaigns = cachemanifest.getCachedCampaigns();
				pruneList = null;
			}
				
			// If current videoPlan is still null (nothing in the cache either), just forget going any further.
			if (videoPlanCampaigns == null || videoPlanCampaigns.size() == 0) return;
			
			if (cachedCampaigns != null)
				Log.d(ApplifierImpactProperties.LOG_NAME, "Cached campaigns: " + cachedCampaigns.toString());
			
			if (videoPlanCampaigns != null)
				Log.d(ApplifierImpactProperties.LOG_NAME, "Campaigns in videoPlan: " + videoPlanCampaigns.toString());
			
			if (pruneList != null)
				Log.d(ApplifierImpactProperties.LOG_NAME, "Campaigns to prune: " + pruneList.toString());
			
			// Update cache WILL START DOWNLOADS if needed, after this method you can check getDownloadingCampaigns which ones started downloading.
			cachemanager.updateCache(videoPlanCampaigns, pruneList);			
			setupViews();		
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

	private void focusToView (View view) {
		view.setFocusable(true);
		view.setFocusableInTouchMode(true);
		view.requestFocus();
	}
	
	private void setupViews () {
		_vc = new ApplifierVideoCompletedView(_currentActivity.getBaseContext());
		_vc.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				closeImpactView(_vc, true);
			}
		});
		
		_vs = new ApplifierVideoSelectView(_currentActivity.getBaseContext());		
		_vs.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				closeImpactView(_vs, false);
				_currentActivity.addContentView(_vp, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
				focusToView(_vp);
				
				if (_selectedCampaign != null)
					_vp.playVideo(_selectedCampaign.getVideoFilename());
				
				if (_videoListener != null)
					_videoListener.onVideoStarted();
			}
		});
				
		_vp = new ApplifierVideoPlayView(_currentActivity.getBaseContext(), new MediaPlayer.OnCompletionListener() {			
			@Override
			public void onCompletion(MediaPlayer mp) {				
				if (_videoListener != null)
					_videoListener.onVideoCompleted();
				
				_selectedCampaign.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
				cachemanifest.writeCurrentCacheManifest();
				webdata.sendCampaignViewed(_selectedCampaign);
				_vp.setKeepScreenOn(false);
				closeImpactView(_vp, false);
				_currentActivity.addContentView(_vc, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
				focusToView(_vc);	
			}
		}, _currentActivity);	
	}
}
