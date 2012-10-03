package com.applifier.impact.android.campaign;

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
	private boolean _cancelledDownloads = false;
	
	
	public ApplifierImpactCampaignHandler (ApplifierImpactCampaign campaign, ArrayList<ApplifierImpactCampaign> activeList) {
		_campaign = campaign;
		_activeCampaigns = activeList;
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
			Log.d(ApplifierImpactProperties.LOG_NAME, "Reporting campaign download completion: " + _campaign.getCampaignId());
		
	}
	
	@Override
	public void onFileDownloadCancelled (String downloadUrl) {	
		if (finishDownload(downloadUrl)) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Download cancelled: " + _campaign.getCampaignId());
			_cancelledDownloads = true;
		}
	}
	
	public void initCampaign () {
		// Check video
		checkFileAndDownloadIfNeeded(_campaign.getVideoUrl());
		
		// No downloads, report campaign done
		if (!hasDownloads() && _handlerListener != null && !_cancelledDownloads) {
			_handlerListener.onCampaignHandled(this);
		}
	}
	
	
	/* INTERNAL METHODS */
	
	private boolean finishDownload (String downloadUrl) {
		removeDownload(downloadUrl);
		
		if (_downloadList != null && _downloadList.size() == 0 && _handlerListener != null) {
			ApplifierImpactDownloader.removeListener(this);
			_handlerListener.onCampaignHandled(this);
			return true;
		}
		
		return false;
	}
	
	private void checkFileAndDownloadIfNeeded (String fileUrl) {
		if (!ApplifierImpactUtils.isFileInCache(fileUrl)) {
			if (!hasDownloads())
				ApplifierImpactDownloader.addListener(this);
			
			addToFileDownloads(fileUrl);
		}
		else if (!isFileOk(fileUrl)) {
			ApplifierImpactUtils.removeFile(fileUrl);
			ApplifierImpactDownloader.addListener(this);
			addToFileDownloads(fileUrl);
		}		
	}
	
	private boolean isFileOk (String fileUrl) {
		// TODO: Implement isFileOk
		return true;
	}
	
	private void addToFileDownloads (String fileUrl) {
		if (fileUrl == null) return;
		if (_downloadList == null) _downloadList = new ArrayList<String>();
		
		_downloadList.add(fileUrl);
		ApplifierImpactDownloader.addDownload(fileUrl);
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
