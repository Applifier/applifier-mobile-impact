package com.applifier.impact.android.burstly;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.IApplifierImpactListener;
import com.burstly.lib.component.IBurstlyAdaptor;
import com.burstly.lib.component.IBurstlyAdaptorListener;

/**
 * Applifier Impact adaptor for Burstly
 * 
 * @author tuomasrinta
 *
 */
public class ImpactAdaptor implements IBurstlyAdaptor, IApplifierImpactListener {
	
	public static String FEATURE_PRECACHE = "precacheInterstitial";
	
	public final static String KEY_IMPACT_GAME_ID ="impact_game_id";
	public final static String KEY_TEST_MODE = "impact_test_mode";
	public final static String KEY_CLIENT_TARGETING_PARAMS = "clientTargetingParams";
	
	private String gameId = null;
	
	private boolean campaignLoadingComplete = false;
	
	/**
	 * If we're using non-precache, the request to show ads gets fired
	 * before we know if we have campaigns or not, so we need to store
	 * the fact that we've been requested
	 */
	private boolean adShowRequested = false;
	
	/**
	 * Lifecycle status
	 */
	private boolean isLCRunning = true;

	/**
	 * The context
	 */
	private Context mContext = null;
	
	/**
	 * The ApplifierImpact instance
	 */
	private ApplifierImpact impact = null;
	
	/**
	 * Our AdaptorListener
	 */
	private IBurstlyAdaptorListener listener;
	
	/**
	 * Custom SID, if any
	 */
	private String customSid = null;

	/**
	 * Construct a new ImpactAdaptor
	 * @param ctx
	 */
	public ImpactAdaptor(Context ctx) {
		this.mContext = ctx;
	}

	@Override
	public void destroy() {
		// Tell Impact to shut down
		if(this.impact != null) {
			this.impact.stopAll();
		}

	}

	@Override
	public BurstlyAdType getAdType() {
		return BurstlyAdType.INTERSTITIAL_AD_TYPE;
	}

	@Override
	public String getNetworkName() {
		return "applifierimpact";
	}
	
	private void notifyBurstlyOfAdLoading() {
		Log.d("burstly_applifier", "notifyBurstlyOfAdLoading: " + this.impact.canShowCampaigns());
		if(this.impact.canShowCampaigns()) {
			this.listener.didLoad(this.getNetworkName(), true);
			if(this.adShowRequested) {
				// We've been requested to show stuff
				this.showPrecachedInterstitialAd();
			}
		} else {
			this.listener.failedToLoad(this.getNetworkName(), true, "No ads available");
		}
	}
	

	@Override
	public void precacheInterstitialAd() {
		
		Log.d("burstly_applifier", "ImpactAdaptor.precacheInterstitialAd()");
		
		// Do nothing, as Impact by default precaches interstitials
		if(this.campaignLoadingComplete) {
			this.notifyBurstlyOfAdLoading();
		}
		return;
	}


	/**
	 * Get the AdaptorListener that we notify of events
	 */
	@Override
	public void setAdaptorListener(IBurstlyAdaptorListener adaptorListener) {
		this.listener = adaptorListener;
	}

	/**
	 * Show an already cached (loaded) interstitial
	 */
	@Override
	public void showPrecachedInterstitialAd() {
		
		// If pause() or stop() have been called, do not show ads
		if(!this.isLCRunning) {
			return;
		}
		
		if(this.impact.canShowImpact() && this.impact.canShowCampaigns()) {
			if(this.customSid != null) {
				HashMap<String, Object> props = new HashMap<String, Object>();
				props.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY, this.customSid);
				props.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, false);
				this.impact.showImpact(props);
				
				
				
			} else {
				this.impact.showImpact();
			}
		}
	}

	/**
	 * Initialize the adaptor
	 */
	@Override
	public void startTransaction(Map<String, ?> impactParams)
			throws IllegalArgumentException {
		
		this.isLCRunning = true;
		
		for(Object k : impactParams.keySet()) {
			Log.d("burstly_applifier", "startTransaction: " + k.toString() + " -> " + impactParams.get(k));
		}
		
		this.gameId = (String)impactParams.get(ImpactAdaptor.KEY_IMPACT_GAME_ID);
		
		Log.d("burstly_applifier", "ImpactAdaptor.startTransaction(" + this.gameId + ")"); 
		
		if(gameId == null) {
			throw new IllegalArgumentException("Server must return impact_game_id");
		}
		
	    boolean testModeEnabled = "true".equals(impactParams.get(ImpactAdaptor.KEY_TEST_MODE));
	    ApplifierImpact.setDebugMode(testModeEnabled); 
	    ApplifierImpact.setTestMode(testModeEnabled);
		
		this.impact = new ApplifierImpact((Activity)this.mContext, this.gameId, this);
		this.impact.setImpactListener(this);
		
		// See if we have a custom user ID
		if(impactParams.get(ImpactAdaptor.KEY_CLIENT_TARGETING_PARAMS) != null) {
			Map targetingParams = (Map)impactParams.get(ImpactAdaptor.KEY_CLIENT_TARGETING_PARAMS);
			if(targetingParams.get("sid") != null) {
				this.customSid = targetingParams.get("sid").toString(); 
			}
		}
		
		Log.d("burstly_applifier", "Impact initialized");
	}
	 

	@Override
	public View getNewAd() {

		// This gets called pretty fast, so we must delay
		// unless loading is complete
		if(this.campaignLoadingComplete) {
			this.showPrecachedInterstitialAd();
		} else {
			this.adShowRequested = true;
		}
		
		
		return null;
	}
	
	@Override
	public void pause() {
		this.isLCRunning = false;
	}
	
	@Override
	public void resume() {
		this.isLCRunning = true;
	}
	
	@Override
	public void stop() {
		this.isLCRunning = false;
	}

	@Override
	public boolean supports(String feature) {
		
		Log.d("burstly_applifier", "ImpactAdaptor.supports(" + feature + ")");

		if(FEATURE_PRECACHE.equals(feature)) {
			return true;
		}
		
		return false;
	}
	

	/* Lifecycle methods, not used */
	@Override
	public void endTransaction(TransactionCode tx) {}
	@Override
	public void endViewSession() {}
	@Override
	public void startViewSession() {}


	/*========================
	 * Impact listener methods
	 */

	
	@Override
	public void onImpactClose() {
		this.listener.dismissedFullscreen(
				new IBurstlyAdaptorListener.FullscreenInfo(this.getNetworkName(), true));
	} 

	@Override
	public void onImpactOpen() {
		this.listener.shownFullscreen(
				new IBurstlyAdaptorListener.FullscreenInfo(this.getNetworkName(), true));
		
	}

	@Override
	public void onCampaignsAvailable() {
		this.campaignLoadingComplete = true;
		Log.d("burstly_applifier","ImpactAdator.onCampaignsAvailable");
		this.notifyBurstlyOfAdLoading();
	}

	@Override
	public void onCampaignsFetchFailed() {
		this.campaignLoadingComplete = true;
		Log.d("burstly_applifier","ImpactAdator.onCampaignsFetchFailed");		
		this.notifyBurstlyOfAdLoading();
	}	

	/*
	 * No Burstly equivelants for these
	 */
	@Override
	public void onVideoStarted() {}

	@Override
	public void onVideoCompleted(String key, boolean skipped) {
		// TODO Auto-generated method stub
		
	}


	/*=====================================
	 * METHODS NOT USED AS NO BANNERS USED
	 */

	@Override
	public View precacheAd() {
		// No banners here
		return null;
	}

	
}
