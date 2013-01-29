package com.applifier.impact.android;

public interface IApplifierImpactListener {
	// Impact view events
	public void onImpactClose ();
	public void onImpactOpen ();
	
	// Impact video events
	public void onVideoStarted ();
	public void onVideoCompleted ();
	
	// Impact campaign events
	public void onCampaignsAvailable ();
}
