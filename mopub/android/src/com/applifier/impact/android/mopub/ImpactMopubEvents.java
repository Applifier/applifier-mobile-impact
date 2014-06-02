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
	private String gameId = null;
	private String zoneId = null;
	private Map<String, Object> options = null;

	@Override
	protected void loadInterstitial(Context context,
			CustomEventInterstitialListener customEventInterstitialListener,
			Map<String, Object> localExtras, Map<String, String> serverExtras) {
		listener = customEventInterstitialListener;	
		
		if(serverExtras.get("gameId") == null || !(serverExtras.get("gameId") instanceof String)) {
			listener.onInterstitialFailed(MoPubErrorCode.ADAPTER_CONFIGURATION_ERROR);
			return;
		}
		
		gameId = serverExtras.get("gameId");
		zoneId = serverExtras.get("zoneId");
		
		options = new HashMap<String, Object>();
		options.putAll(localExtras);
		options.putAll(serverExtras);
		
		if(ApplifierImpact.instance == null) {
			new ApplifierImpact((Activity)context, gameId, this);
		} else {
			ApplifierImpact.instance.changeActivity((Activity)context);
			ApplifierImpact.instance.setImpactListener(this);
			listener.onInterstitialLoaded();
		}		
	}

	@Override
	protected void showInterstitial() {
		if(ApplifierImpact.instance.canShowImpact() && ApplifierImpact.instance.canShowCampaigns()) {
			ApplifierImpact.instance.setZone(zoneId);			
			ApplifierImpact.instance.showImpact(options);
		} else {
			listener.onInterstitialFailed(MoPubErrorCode.NO_FILL);
		}
	}

	@Override 
	protected void onInvalidate() {
		Log.d("ApplifierImpact", "onInvalidate");
	}

	@Override
	public void onImpactClose() {
		Log.d("ApplifierImpact", "onImpactClose");
		listener.onInterstitialDismissed();
	}

	@Override
	public void onImpactOpen() {
		Log.d("ApplifierImpact", "onImpactOpen");
		listener.onInterstitialShown();
	}
	
	@Override
	public void onVideoStarted() {
		Log.d("ApplifierImpact", "onVideoStarted");
	}
	
	@Override
	public void onVideoCompleted(String rewardItemKey, boolean skipped) {
		Log.d("ApplifierImpact", "onVideoCompleted - " + rewardItemKey + " - " + skipped);
	}

	@Override
	public void onCampaignsAvailable() {
		Log.d("ApplifierImpact", "onCampaignsAvailable");
		listener.onInterstitialLoaded();
	}

	@Override
	public void onCampaignsFetchFailed() {
		Log.d("ApplifierImpact", "onCampaignsFetchFailed");
		listener.onInterstitialFailed(MoPubErrorCode.NO_FILL);	
	}
}