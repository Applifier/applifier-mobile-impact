package com.applifier.impact.android.campaign;

import java.util.ArrayList;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactDownloadListener;

public class ApplifierImpactCampaignHandler implements IApplifierImpactDownloadListener {
	
	private ArrayList<String> _downloadList = null;
	private ApplifierImpactCampaign _campaign = null;
	private IApplifierImpactCampaignHandlerListener _handlerListener = null;
	private boolean _cancelledDownloads = false;
	
	
	public ApplifierImpactCampaignHandler (ApplifierImpactCampaign campaign) {
		_campaign = campaign;
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
		if (finishDownload(downloadUrl))
			ApplifierImpactUtils.Log("Reporting campaign download completion: " + _campaign.getCampaignId(), this);
		
	}
	
	@Override
	public void onFileDownloadCancelled (String downloadUrl) {	
		if (finishDownload(downloadUrl)) {
			ApplifierImpactUtils.Log("Download cancelled: " + _campaign.getCampaignId(), this);
			_cancelledDownloads = true;
		}
	}
	
	public void initCampaign () {
		// Check video
		checkFileAndDownloadIfNeeded(_campaign.getVideoUrl());
		
		if (_handlerListener != null) {
			_handlerListener.onCampaignHandled(this);
		}
		
		/*
		if (!hasDownloads() && _handlerListener != null && !_cancelledDownloads) {
			_handlerListener.onCampaignHandled(this);
		}
		*/
	}
	
	
	/* INTERNAL METHODS */
	
	private boolean finishDownload (String downloadUrl) {
		removeDownload(downloadUrl);
		
		if (_downloadList != null && _downloadList.size() == 0 && _handlerListener != null) {
			ApplifierImpactDownloader.removeListener(this);
			//_handlerListener.onCampaignHandled(this);
			return true;
		}
		
		return false;
	}
	
	private void checkFileAndDownloadIfNeeded (String fileUrl) {
		if (_campaign.shouldCacheVideo() && !ApplifierImpactUtils.isFileInCache(_campaign.getVideoFilename()) && ApplifierImpactUtils.canUseExternalStorage()) {
			if (!hasDownloads())
				ApplifierImpactDownloader.addListener(this);
			
			addCampaignToDownloads();
		}
		else if (!isFileOk(fileUrl) && _campaign.shouldCacheVideo() && ApplifierImpactUtils.canUseExternalStorage()) {
			ApplifierImpactUtils.removeFile(fileUrl);
			ApplifierImpactDownloader.addListener(this);
			addCampaignToDownloads();
		}		
	}
	
	private boolean isFileOk (String fileUrl) {
		// TODO: Implement isFileOk
		return true;
	}
	
	private void addCampaignToDownloads () {
		if (_campaign == null) return;
		if (_downloadList == null) _downloadList = new ArrayList<String>();
		
		_downloadList.add(_campaign.getVideoUrl());
		ApplifierImpactDownloader.addDownload(_campaign);
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
