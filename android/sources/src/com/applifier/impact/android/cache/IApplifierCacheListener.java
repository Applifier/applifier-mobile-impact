package com.applifier.impact.android.cache;

import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;

public interface IApplifierCacheListener {
	public void onCampaignUpdateStarted ();
	public void onCampaignReady (ApplifierImpactCampaignHandler campaignHandler);
	public void onAllCampaignsReady ();
}
