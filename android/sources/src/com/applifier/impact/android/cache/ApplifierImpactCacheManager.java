package com.applifier.impact.android.cache;

import java.util.ArrayList;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignHandlerListener;

import android.util.Log;

public class ApplifierImpactCacheManager {
	private IApplifierImpactDownloadListener _downloadListener = null;	
	private ArrayList<ApplifierImpactCampaign> _downloadingCampaigns = null;
	private ArrayList<ApplifierImpactCampaignHandler> _downloadingHandlers = null;
	
	public ApplifierImpactCacheManager () {
		ApplifierImpactUtils.createCacheDir();
		Log.d(ApplifierImpactProperties.LOG_NAME, "External storagedir: " + ApplifierImpactUtils.getCacheDirectory());
	}
	
	public ArrayList<ApplifierImpactCampaign> getDownloadingCampaigns () {
		return _downloadingCampaigns;
	}
	
	public void setDownloadListener (IApplifierImpactDownloadListener listener) {
		_downloadListener = listener;
	}
	
	public boolean isDownloading () {
		return (_downloadingHandlers != null && _downloadingHandlers.size() > 0);
	}
	
	public void initCache (ArrayList<ApplifierImpactCampaign> activeList, ArrayList<ApplifierImpactCampaign> pruneList) {
		updateCache(activeList, pruneList);
	}
	
	public void updateCache (ArrayList<ApplifierImpactCampaign> activeList, ArrayList<ApplifierImpactCampaign> pruneList) {
		if (activeList != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating cache: Going through active campaigns");
			
			for (ApplifierImpactCampaign campaign : activeList) {
				ApplifierImpactCampaignHandler campaignHandler = new ApplifierImpactCampaignHandler(campaign, activeList);
				
				if (campaignHandler.hasDownloads()) {
					campaignHandler.setListener(new IApplifierImpactCampaignHandlerListener() {
						@Override
						public void onCampaignHandled(ApplifierImpactCampaignHandler campaignHandler) {
							removeFromDownloadingHandlers(campaignHandler);
							_downloadListener.onCampaignFilesDownloaded(campaignHandler);
							
							if (!isDownloading() && _downloadListener != null)
			        			_downloadListener.onAllDownloadsCompleted();
						}
					});
					
					// TODO: Could be in a better place?
					if (!isDownloading() && _downloadListener != null)
						_downloadListener.onDownloadsStarted();
					
					addToDownloadingHandlers(campaignHandler);
				}
				
				campaignHandler.handleCampaign();
			}
		}
		
		if (pruneList != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating cache: Pruning old campaigns");
			for (ApplifierImpactCampaign campaign : pruneList) {
				if (!ApplifierImpactUtils.isFileRequiredByCampaigns(campaign.getVideoUrl(), activeList)) {
					ApplifierImpactUtils.removeFile(campaign.getVideoUrl());
				}
			}
		}
	}

	
	// INTERNAL METHODS
	
	private void removeFromDownloadingHandlers (ApplifierImpactCampaignHandler campaignHandler) {
		if (_downloadingHandlers != null)
			_downloadingHandlers.remove(campaignHandler);
		
		if (_downloadingCampaigns != null)
			_downloadingCampaigns.remove(campaignHandler.getCampaign());
	}
	
	private void addToDownloadingHandlers (ApplifierImpactCampaignHandler campaignHandler) {
		if (_downloadingHandlers == null)
			_downloadingHandlers = new ArrayList<ApplifierImpactCampaignHandler>();
		
		_downloadingHandlers.add(campaignHandler);
		
		if (_downloadingCampaigns == null)
			_downloadingCampaigns = new ArrayList<ApplifierImpactCampaign>();
		
		_downloadingCampaigns.add(campaignHandler.getCampaign());
	}
}
