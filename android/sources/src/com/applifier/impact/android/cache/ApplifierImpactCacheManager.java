package com.applifier.impact.android.cache;

import java.io.File;
import java.util.ArrayList;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaignHandler;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignHandlerListener;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactCacheManager implements IApplifierImpactCampaignHandlerListener {
	
	private IApplifierImpactCacheListener _downloadListener = null;	
	private ArrayList<ApplifierImpactCampaignHandler> _downloadingHandlers = null;
	private ArrayList<ApplifierImpactCampaignHandler> _handlers = null;	
	private int _amountPrepared = 0;
	private int _totalCampaigns = 0;
	
	
	public ApplifierImpactCacheManager () {
		if (ApplifierImpactUtils.canUseExternalStorage()) {
			ApplifierImpactUtils.Log("External storagedir: " + ApplifierImpactUtils.getCacheDirectory() + " created with result: " + ApplifierImpactUtils.createCacheDir(), this);
		}
		else {
			ApplifierImpactUtils.Log("Could not create cache, no external memory present", this);
		}
	}
	
	public void setDownloadListener (IApplifierImpactCacheListener listener) {
		_downloadListener = listener;
	}
	
	public boolean hasDownloadingHandlers () {
		return (_downloadingHandlers != null && _downloadingHandlers.size() > 0);
	}
	
	public void initCache (ArrayList<ApplifierImpactCampaign> activeList) {
		updateCache(activeList);
	}
		
	public void updateCache (ArrayList<ApplifierImpactCampaign> activeList) {
		if (_downloadListener != null)
			_downloadListener.onCampaignUpdateStarted();
		
		_amountPrepared = 0;
		
		if (activeList != null)
			ApplifierImpactUtils.Log(activeList.toString(), this);
		
		// Check cache directory and delete all files that don't match the current files in campaigns
		if (ApplifierImpactUtils.getCacheDirectory() != null) {
			File dir = new File(ApplifierImpactUtils.getCacheDirectory());
			File[] fileList = dir.listFiles();
			
			if (fileList != null) {
				for (File currentFile : fileList) {
					ApplifierImpactUtils.Log("Checking file: " + currentFile.getName(), this);
					if (!currentFile.getName().equals(ApplifierImpactConstants.PENDING_REQUESTS_FILENAME) && 
						!currentFile.getName().equals(ApplifierImpactConstants.CACHE_MANIFEST_FILENAME) && 
						!ApplifierImpactUtils.isFileRequiredByCampaigns(currentFile.getName(), activeList)) {
						ApplifierImpactUtils.removeFile(currentFile.getName());
					}
				}
			}
		}

		// Active -list contains campaigns that came with the videoPlan
		if (activeList != null) {
			_totalCampaigns = activeList.size();
			ApplifierImpactUtils.Log("Updating cache: Going through active campaigns: " + _totalCampaigns, this);			
			for (ApplifierImpactCampaign campaign : activeList) {
				ApplifierImpactCampaignHandler campaignHandler = new ApplifierImpactCampaignHandler(campaign);
				addToUpdatingHandlers(campaignHandler);
				campaignHandler.setListener(this);
				campaignHandler.initCampaign();
				
				if (campaignHandler.hasDownloads()) {
					addToDownloadingHandlers(campaignHandler);
				}					
			}
		}
	}
	
	public void clearData () {
		if (_downloadListener != null)
			_downloadListener = null;
		
		if (_downloadingHandlers != null) {
			for (ApplifierImpactCampaignHandler ch : _downloadingHandlers) {
				ch.setListener(null);
				ch.clearData();
				ch = null;	
			}
			
			_downloadingHandlers.clear();
			_downloadingHandlers = null;
		}
		
		if (_handlers != null) {
			for (ApplifierImpactCampaignHandler ch : _handlers) {
				ch.setListener(null);
				ch.clearData();
				ch = null;
			}
			
			_handlers.clear();
			_handlers = null;
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
