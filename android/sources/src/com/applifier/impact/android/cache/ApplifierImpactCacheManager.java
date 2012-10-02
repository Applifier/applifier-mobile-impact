package com.applifier.impact.android.cache;

import java.io.File;
import java.util.ArrayList;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignHandlerListener;

import android.util.Log;

public class ApplifierImpactCacheManager implements IApplifierImpactCampaignHandlerListener {
	
	private IApplifierImpactCacheListener _downloadListener = null;	
	private ArrayList<ApplifierImpactCampaignHandler> _downloadingHandlers = null;
	private ArrayList<ApplifierImpactCampaignHandler> _handlers = null;	
	private int _amountPrepared = 0;
	private int _totalCampaigns = 0;
	
	
	public ApplifierImpactCacheManager () {
		ApplifierImpactUtils.createCacheDir();
		Log.d(ApplifierImpactProperties.LOG_NAME, "External storagedir: " + ApplifierImpactUtils.getCacheDirectory());
	}
	
	public void setDownloadListener (IApplifierImpactCacheListener listener) {
		_downloadListener = listener;
	}
	
	public boolean hasDownloadingHandlers () {
		return (_downloadingHandlers != null && _downloadingHandlers.size() > 0);
	}
	
	//public void initCache (ArrayList<ApplifierImpactCampaign> activeList, ArrayList<ApplifierImpactCampaign> pruneList) {
	public void initCache (ArrayList<ApplifierImpactCampaign> activeList) {
		updateCache(activeList);
	}
		
	//public void updateCache (ArrayList<ApplifierImpactCampaign> activeList, ArrayList<ApplifierImpactCampaign> pruneList) {
	public void updateCache (ArrayList<ApplifierImpactCampaign> activeList) {
		if (_downloadListener != null)
			_downloadListener.onCampaignUpdateStarted();
		
		_amountPrepared = 0;
		
		Log.d(ApplifierImpactProperties.LOG_NAME, activeList.toString());
		
		// Check cache directory and delete all files that don't match the current files in campaigns
		if (ApplifierImpactUtils.getCacheDirectory() != null) {
			File dir = new File(ApplifierImpactUtils.getCacheDirectory());
			File[] fileList = dir.listFiles();
			
			if (fileList != null) {
				for (File currentFile : fileList) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Checking file: " + currentFile.getName());
					if (!currentFile.getName().equals(ApplifierImpactProperties.PENDING_REQUESTS_FILENAME) && 
						!currentFile.getName().equals(ApplifierImpactProperties.CACHE_MANIFEST_FILENAME) && 
						!ApplifierImpactUtils.isFileRequiredByCampaigns(currentFile.getName(), activeList)) {
						ApplifierImpactUtils.removeFile(currentFile.getName());
					}
				}
			}
		}
		
		// Prune -list contains campaigns that were still in cache but not in the received videoPlan.
		// Therefore they will not be put into cache. Check that the existing videos for those
		// campaigns are not needed by current active ones and remove them if needed.
		/*
		if (pruneList != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating cache: Pruning old campaigns");
			for (ApplifierImpactCampaign campaign : pruneList) {
				ApplifierImpact.cachemanifest.removeCampaignFromManifest(campaign.getCampaignId());
				if (!ApplifierImpactUtils.isFileRequiredByCampaigns(campaign.getVideoUrl(), activeList)) {
					ApplifierImpactUtils.removeFile(campaign.getVideoUrl());
				}
			}
		}*/
		
		// Active -list contains campaigns that came with the videoPlan
		if (activeList != null) {
			_totalCampaigns = activeList.size();
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating cache: Going through active campaigns");			
			for (ApplifierImpactCampaign campaign : activeList) {
				ApplifierImpactCampaignHandler campaignHandler = new ApplifierImpactCampaignHandler(campaign, activeList);
				addToUpdatingHandlers(campaignHandler);
				campaignHandler.setListener(this);
				campaignHandler.initCampaign();
				
				if (campaignHandler.hasDownloads()) {
					addToDownloadingHandlers(campaignHandler);
				}					
			}
		}
	}

	
	// EVENT METHDOS
	
	@Override
	public void onCampaignHandled(ApplifierImpactCampaignHandler campaignHandler) {
		_amountPrepared++;
		removeFromDownloadingHandlers(campaignHandler);
		removeFromUpdatingHandlers(campaignHandler);
		_downloadListener.onCampaignReady(campaignHandler);
		
		if (_amountPrepared == _totalCampaigns)
			_downloadListener.onAllCampaignsReady();
	}	
	
	
	// INTERNAL METHODS
	
	private void removeFromUpdatingHandlers (ApplifierImpactCampaignHandler campaignHandler) {
		if (_handlers != null)
			_handlers.remove(campaignHandler);
	}
	
	private void addToUpdatingHandlers (ApplifierImpactCampaignHandler campaignHandler) {
		if (_handlers == null)
			_handlers = new ArrayList<ApplifierImpactCampaignHandler>();
		
		_handlers.add(campaignHandler);
	}
	
	private void removeFromDownloadingHandlers (ApplifierImpactCampaignHandler campaignHandler) {
		if (_downloadingHandlers != null)
			_downloadingHandlers.remove(campaignHandler);
	}
	
	private void addToDownloadingHandlers (ApplifierImpactCampaignHandler campaignHandler) {
		if (_downloadingHandlers == null)
			_downloadingHandlers = new ArrayList<ApplifierImpactCampaignHandler>();
		
		_downloadingHandlers.add(campaignHandler);
	}
}
