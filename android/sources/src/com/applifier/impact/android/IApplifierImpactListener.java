package com.applifier.impact.android;

public interface IApplifierImpactListener {
	// Impact view events
	public void onImpactClose ();
	public void onImpactOpen ();
	
	// Impact video events
	public void onVideoStarted ();
	public void onVideoCompleted (String rewardItemKey);
	
	// Impact campaign events
	public void onCampaignsAvailable ();
	public void onCampaignsFetchFailed ();
}
