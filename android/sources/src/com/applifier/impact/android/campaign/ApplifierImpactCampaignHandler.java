package com.applifier.impact.android.campaign;

import java.io.File;
import java.util.ArrayList;

import android.util.Log;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactDownloadListener;

public class ApplifierImpactCampaignHandler implements IApplifierImpactDownloadListener {
	private ArrayList<String> _downloadList = null;
	private ApplifierImpactCampaign _campaign = null;
	private ArrayList<ApplifierImpactCampaign> _activeCampaigns = null;
	private IApplifierImpactCampaignHandlerListener _handlerListener = null;
	
	public ApplifierImpactCampaignHandler (ApplifierImpactCampaign campaign, ArrayList<ApplifierImpactCampaign> activeList) {
		_campaign = campaign;
		_activeCampaigns = activeList;
		checkCampaign();
	}
	
	public boolean hasDownloads () {
		return (_downloadList != null && _downloadList.size() > 0);
	}

	public ApplifierImpactCampaign getCampaign () {
		return _campaign;
	}
	
	public void setListener (IApplifierImpactCampaignHandlerListener listener) {
		_handlerListener = listener;
	}
	
	@Override
	public void onFileDownloadCompleted (String downloadUrl) {
		removeDownload(downloadUrl);
		
		if (_downloadList != null && _downloadList.size() == 0 && _handlerListener != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Reporting campaign download completion: " + _campaign.getCampaignId());
			ApplifierImpactDownloader.removeListener(this);
			_handlerListener.onCampaignHandled(this);
		}
	}	
	
	
	/* INTERNAL METHODS */
	
	private void addToFileDownloads (String fileUrl) {
		if (fileUrl == null) return;
		if (_downloadList == null) _downloadList = new ArrayList<String>();
		
		_downloadList.add(fileUrl);
		ApplifierImpactDownloader.addDownload(fileUrl);
	}
	
	private void checkCampaign () {
		// Check video
		if (!isFileCached(_campaign.getVideoFilename())) {
			if (!hasDownloads())
				ApplifierImpactDownloader.addListener(this);
			
			addToFileDownloads(_campaign.getVideoUrl());
		}
		
		ApplifierImpactCampaign possiblyCachedCampaign = ApplifierImpact.cachemanifest.getCachedCampaignById(_campaign.getCampaignId());
		
		// If manifest has this campaign and their files are not the same, remove the cached file if not needed anymore.
		if (possiblyCachedCampaign != null && !_campaign.getVideoUrl().equals(possiblyCachedCampaign.getVideoUrl()) && 
			!ApplifierImpactUtils.isFileRequiredByCampaigns(possiblyCachedCampaign.getVideoUrl(), _activeCampaigns))
			ApplifierImpactUtils.removeFile(possiblyCachedCampaign.getVideoUrl());
		
		// No downloads, report campaign done
		if (!hasDownloads() && _handlerListener != null)
			_handlerListener.onCampaignHandled(this);
	}
	
	private boolean isFileCached (String fileName) {
		File targetFile = new File (fileName);
		File cachedFile = new File (ApplifierImpactUtils.getCacheDirectory() + "/" + targetFile.getName());
		
		return cachedFile.exists();
	}
	
	private void removeDownload (String downloadUrl) {
		if (_downloadList == null) return;
		
		int removeIndex = -1;
		
		for (int i = 0; i < _downloadList.size(); i++) {
			if (_downloadList.get(i).equals(downloadUrl)) {
				removeIndex = i;
				break;
			}
		}
		
		if (removeIndex > -1)
			_downloadList.remove(removeIndex);
	}
}
