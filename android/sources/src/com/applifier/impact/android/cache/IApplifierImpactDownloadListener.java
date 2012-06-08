package com.applifier.impact.android.cache;

import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;

public interface IApplifierImpactDownloadListener {
	public void onDownloadsStarted ();
	public void onCampaignFilesDownloaded (ApplifierImpactCampaignHandler campaignHandler);
	public void onAllDownloadsCompleted ();
}
