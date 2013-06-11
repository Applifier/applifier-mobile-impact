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
	
	public static String IMPACT_MOPUB_MUTE_OPTION = "muteSounds";
	public static String IMPACT_MOPUB_ORIENTATION_OPTION = "deviceOrientation";
	
	private boolean optionMute = false;
	private boolean optionDeviceOrientation = false;

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
		
		// First go through the local extras, then the server extras so we can easily
		// over-ride the settings on the server-side
		Map[] maps = new Map[] {localExtras, serverExtras};
		
		for(Map<String, String> opMap : maps) {
			for(String key : opMap.keySet()) {
				if(IMPACT_MOPUB_MUTE_OPTION.equals(key)) {
					if("true".equals(opMap.get(IMPACT_MOPUB_MUTE_OPTION))) {
						this.optionMute = true;
					}
				}
				if(IMPACT_MOPUB_ORIENTATION_OPTION.equals(key)) {
					if("true".equals(opMap.get(IMPACT_MOPUB_ORIENTATION_OPTION))) {
						this.optionDeviceOrientation = true;
					}
				}
			}
		}
		
		ApplifierImpact.setDebugMode(true);
		this.impactInstance = new ApplifierImpact((Activity)context, gameId, this);
		
		Log.d("foo", "impact inited");
		
		
	}

	@Override
	protected void showInterstitial() {
		if(this.impactInstance.canShowCampaigns()) {
			
			HashMap<String, Object> options = new HashMap<String, Object>();
			
			// Always use no offer screen as MoPub is always non-incent
			options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, true);
			
			// Configured options
			options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION, this.optionDeviceOrientation);
			options.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS, this.optionMute);
			
			this.impactInstance.showImpact(options);
		}
	}

	@Override 
	protected void onInvalidate() {

	}

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
	public void onVideoCompleted(String rewardItemKey) {}

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
