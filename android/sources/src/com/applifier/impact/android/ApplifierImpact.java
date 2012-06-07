package com.applifier.impact.android;

import java.util.ArrayList;

import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.cache.ApplifierImpactCacheManifest;
import com.applifier.impact.android.cache.ApplifierImpactWebData;
import com.applifier.impact.android.cache.IApplifierImpactCacheListener;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
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

public class ApplifierImpact {
	
	// Impact components
	public static ApplifierImpact instance = null;
	public static ApplifierImpactCacheManifest cachemanifest = null;
	public static ApplifierImpactCacheManager cachemanager = null;
	public static ApplifierImpactWebData webdata = null;
	
	// Temporary data
	private Activity _currentActivity = null;
	
	// Views
	private ApplifierVideoSelectView _vs = null;
	private ApplifierVideoPlayView _vp = null;
	private ApplifierVideoCompletedView _vc = null;
	
	// Listeners
	private IApplifierImpactListener _impactListener = null;
	private IApplifierImpactCacheListener _cacheListener = null;
	private IApplifierImpactVideoListener _videoListener = null;
	
	private boolean _initialized = false;
	
	public ApplifierImpact (Activity activity, String applifierId) {
		instance = this;
		ApplifierImpactProperties.IMPACT_APP_ID = applifierId;
		ApplifierImpactProperties.ROOT_ACTIVITY = activity;
		_currentActivity = activity;
	}
		
	public void setImpactListener (IApplifierImpactListener listener) {
		_impactListener = listener;
	}
	
	public void setCacheListener (IApplifierImpactCacheListener listener) {
		_cacheListener = listener;
	}
	
	public void setVideoListener (IApplifierImpactVideoListener listener) {
		_videoListener = listener;
	}
	
	public void init () {
		if (_initialized) return; 
		
		cachemanager = new ApplifierImpactCacheManager();
		cachemanifest = new ApplifierImpactCacheManifest();
		webdata = new ApplifierImpactWebData();
		
		if (webdata.initVideoPlan(cachemanifest.getCachedCampaignIds())) {
			ArrayList<ApplifierImpactCampaign> cachedCampaigns = cachemanifest.getCachedCampaigns();
			ArrayList<ApplifierImpactCampaign> videoPlanCampaigns = webdata.getVideoPlanCampaigns();
			ArrayList<ApplifierImpactCampaign> pruneList = ApplifierImpactUtils.createPruneList(cachedCampaigns, videoPlanCampaigns);
			
			if (cachedCampaigns != null)
				Log.d(ApplifierImpactProperties.LOG_NAME, "Cached campaigns: " + cachedCampaigns.toString());
			
			if (videoPlanCampaigns != null)
				Log.d(ApplifierImpactProperties.LOG_NAME, "Campaigns in videoPlan: " + videoPlanCampaigns.toString());
			
			if (pruneList != null)
				Log.d(ApplifierImpactProperties.LOG_NAME, "Campaigns to prune: " + pruneList.toString());
			
			cachemanager.updateCache(videoPlanCampaigns, pruneList);
			cachemanifest.setCachedCampaigns(webdata.getVideoPlanCampaigns());
		}
		
		
		/*
		cachemanager = new ApplifierImpactCacheManager();
		cachemanager.setCacheListener(new IApplifierImpactCacheListener() {			
			@Override
			public void onCachedCampaignsAvailable() {
				if (_cacheListener != null)
					_cacheListener.onCachedCampaignsAvailable();
			}
		});
		cachemanifest = new ApplifierImpactCacheManifest(cachemanager.getCacheDir());
		_webdata = new ApplifierImpactWebData();
		
		if (_webdata.initVideoPlan(cachemanifest.getCacheManifest())) {
			cachemanager.initCache(cachemanifest.getCacheManifest(), _webdata.getVideoPlan());
		}
		
		ArrayList<ApplifierImpactCampaign> mergedCampaigns = mergeCampaignLists(createCampaignsFromJson(_webdata.getVideoPlan()), createCampaignsFromJson(cachemanifest.getCacheManifest()));
		
		if (mergedCampaigns != null)
			Log.d(ApplifierImpactProperties.LOG_NAME, mergedCampaigns.toString());
		else
			Log.d(ApplifierImpactProperties.LOG_NAME, "Jenkem");
		
		setupViews();
		*/
		
		_initialized = true;
	}
		
	public void changeActivity (Activity activity) {
		_currentActivity = activity;
	}
	
	public boolean showImpact () {
		/*
		_currentImpact = new ArrayList<JSONObject>();
		ArrayList<String> _cachedCampaigns = cachemanifest.getCachedCampaignIds();
		
		for (String id : _cachedCampaigns) {
			_currentImpact.add(cachemanifest.getCampaign(id));
			
			if (_currentImpact.size() > 2)
				break;
		}
		
		
		if (_currentImpact.size() < 3) {
			int left = 3 - _currentImpact.size();
			JSONObject plan = _webdata.getVideoPlan();
			JSONArray va = null;
			
			try {
				va = plan.getJSONArray("va");
			}
			catch (Exception e) {
				return false;
			}
			
			for (int i = 0; i < left; i++) {
				try {
					_currentImpact.add(va.getJSONObject(i));
				}
				catch (Exception e) {
					return false;
				}
			}
		}
				
		Log.d(ApplifierImpactProperties.LOG_NAME, _currentImpact.toString());
		
		_currentActivity.addContentView(_vs, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
		focusToView(_vs);
		
		if (_impactListener != null)
			_impactListener.onImpactOpen();
		*/
		return false;
	}
	
	public void closeImpactView (View view, boolean reportClosed) {
		view.setFocusable(false);
		view.setFocusableInTouchMode(false);
		
		ViewGroup vg = (ViewGroup)view.getParent();
		if (vg != null)
			vg.removeView(view);
		
		if (_impactListener != null && reportClosed)
			_impactListener.onImpactClose();
	}
	
	public boolean hasCampaigns () {
		if (webdata != null && cachemanifest != null) {
			if (webdata.getCampaignAmount() + cachemanifest.getCachedCampaignAmount() > 2)
				return true;
		}
		
		return false;
	}
	
	
	/* PRIVATE METHODS */
	

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
				_vp.playVideo();
				
				if (_videoListener != null)
					_videoListener.onVideoStarted();
			}
		});
		
		_vp = new ApplifierVideoPlayView(_currentActivity.getBaseContext(), new MediaPlayer.OnCompletionListener() {			
			@Override
			public void onCompletion(MediaPlayer mp) {				
				if (_videoListener != null)
					_videoListener.onVideoCompleted();
				
				closeImpactView(_vp, false);
				_currentActivity.addContentView(_vc, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
				focusToView(_vc);
			}
		});
		
		_vp.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
			}
		});		
	}
}
