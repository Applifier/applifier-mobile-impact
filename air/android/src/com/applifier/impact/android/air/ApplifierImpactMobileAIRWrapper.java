package com.applifier.impact.android.air;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.IApplifierImpactListener;

public class ApplifierImpactMobileAIRWrapper implements FREExtension, IApplifierImpactListener {
	public static ApplifierImpactMobileAIRWrapper instance = null;
	private ApplifierImpactMobileExtension _extensionContext = null;
	
	@Override
	public FREContext createContext(String arg0) {
		_extensionContext = new ApplifierImpactMobileExtension();
		return _extensionContext;
	}

	@Override
	public void dispose() {
	}

	@Override
	public void initialize() {
		instance = this;
	}
	
	/* Impact */
	
    @Override
	public void onImpactClose () {
    	_extensionContext.dispatchStatusEventAsync("impactWillClose", "now");
    	_extensionContext.dispatchStatusEventAsync("impactDidClose", "now");
    }
    
    @Override
	public void onImpactOpen () {
    	_extensionContext.dispatchStatusEventAsync("impactWillOpen", "now");
    	_extensionContext.dispatchStatusEventAsync("impactDidOpen", "now");
    }
	
	// Impact video events
    @Override
	public void onVideoStarted () {
    	_extensionContext.dispatchStatusEventAsync("impactVideoStarted", "now");
    }
    
    @Override
	public void onVideoCompleted (String rewardItemKey) {
    	_extensionContext.dispatchStatusEventAsync("impactVideoCompletedWithReward", ApplifierImpact.instance.getCurrentRewardItemKey());
    }
	
	// Impact campaign events
    @Override
	public void onCampaignsAvailable () {
    	_extensionContext.dispatchStatusEventAsync("impactInitComplete", "now");
	}
    
    @Override
    public void onCampaignsFetchFailed () {
    	_extensionContext.dispatchStatusEventAsync("impactInitFailed", "no campaigns");
    }
}
