package com.applifier.impact.android.mopub;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.IApplifierImpactListener;
import com.mopub.mobileads.CustomEventInterstitial;
import com.mopub.mobileads.MoPubErrorCode;

public class ImpactMopubEvents extends CustomEventInterstitial implements IApplifierImpactListener {
	
	private CustomEventInterstitialListener listener = null;
	private ApplifierImpact impactInstance = null;
	private String gameId = null;
	private String zoneId = null;
	private Map<String, Object> options = null;

	@Override
	protected void loadInterstitial(Context context,
			CustomEventInterstitialListener customEventInterstitialListener,
			Map<String, Object> localExtras, Map<String, String> serverExtras) {
		Log.i("foo", "Got loadInterstitial");
		this.listener = customEventInterstitialListener;
		
		// The gameId must be sent from the server-side
		if(serverExtras.get("gameId") == null || !(serverExtras.get("gameId") instanceof String)) {
			this.listener.onInterstitialFailed(MoPubErrorCode.ADAPTER_CONFIGURATION_ERROR);
			return;
		}
		
		this.gameId = serverExtras.get("gameId");
		this.zoneId = serverExtras.get("zoneId");
		
		this.options = new HashMap<String, Object>();
		this.options.putAll(localExtras);
		this.options.putAll(serverExtras);
		
		ApplifierImpact.setDebugMode(true);
		this.impactInstance = new ApplifierImpact((Activity)context, gameId, this);
		
		Log.d("foo", "impact inited");	
	}

	@Override
	protected void showInterstitial() {
		if(this.impactInstance.canShowCampaigns()) {
			this.impactInstance.setZone(this.zoneId);			
			this.impactInstance.showImpact(options);
		}
	}

	@Override 
	protected void onInvalidate() {}

	@Override
	public void onImpactClose() {
		this.listener.onInterstitialDismissed();
	}

	@Override
	public void onImpactOpen() {
		this.listener.onInterstitialShown();
	}
	
	@Override
	public void onVideoStarted() {}
	@Override
	public void onVideoCompleted(String rewardItemKey, boolean skipped) {}

	@Override
	public void onCampaignsAvailable() {
		Log.d("foo", "onCampaignsAvailable");
		this.listener.onInterstitialLoaded();
	}

	@Override
	public void onCampaignsFetchFailed() {
		this.listener.onInterstitialFailed(MoPubErrorCode.NO_FILL);	
	}
}