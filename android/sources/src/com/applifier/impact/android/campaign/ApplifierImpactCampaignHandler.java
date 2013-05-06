package com.applifier.impact.android.campaign;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.cache.ApplifierImpactDownloader;
import com.applifier.impact.android.cache.IApplifierImpactDownloadListener;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.webapp.ApplifierImpactInstrumentation;

public class ApplifierImpactCampaignHandler implements IApplifierImpactDownloadListener {
	
	private ArrayList<String> _downloadList = null;
	private ApplifierImpactCampaign _campaign = null;
	private IApplifierImpactCampaignHandlerListener _handlerListener = null;
	private long _cacheStartMillis = 0;
	private long _cacheSolvedMillis = 0;
	//private boolean _cancelledDownloads = false;
	
	
	public ApplifierImpactCampaignHandler (ApplifierImpactCampaign campaign) {
		_campaign = campaign;
	}
	
	public boolean hasDownloads () {
		return (_downloadList != null && _downloadList.size() > 0);
	}

	public ApplifierImpactCampaign getCampaign () {
		return _campaign;
	}
	
	public long getCachingDurationInMillis () {
		if (_cacheStartMillis > 0 && _cacheSolvedMillis > 0) {
			return _cacheSolvedMillis - _cacheStartMillis;
		}
		
		return 0;
	}
	
	public void setListener (IApplifierImpactCampaignHandlerListener listener) {
		_handlerListener = listener;
	}
	
	@Override
	public void onFileDownloadCompleted (String downloadUrl) {
		if (finishDownload(downloadUrl)) {
			ApplifierImpactUtils.Log("Reporting campaign download completion: " + _campaign.getCampaignId(), this);
			
			// Analytics / Instrumentation
			Map<String, Object> values = new HashMap<String, Object>();
			values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VALUE_KEY, ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOCACHING_COMPLETED);
			values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_CACHINGDURATION_KEY, getCachingDurationInMillis());
			ApplifierImpactInstrumentation.gaInstrumentationVideoCaching(_campaign, values);		
		}
	}
	
	@Override
	public void onFileDownloadCancelled (String downloadUrl) {	
		if (finishDownload(downloadUrl)) {
			ApplifierImpactUtils.Log("Download cancelled: " + _campaign.getCampaignId(), this);
			
			// Analytics / Instrumentation
			Map<String, Object> values = new HashMap<String, Object>();
			values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VALUE_KEY, ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOCACHING_FAILED);			
			ApplifierImpactInstrumentation.gaInstrumentationVideoCaching(_campaign, values);	
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
		
	public void clearData () {
		if (_handlerListener != null)
			_handlerListener = null;
		
		if (_downloadList != null) {
			_downloadList.clear();
		}
		
		if (_campaign != null) {
			_campaign.clearData();
			_campaign = null;
		}
	}
	
	
	/* INTERNAL METHODS */
	
	private boolean finishDownload (String downloadUrl) {
		_cacheSolvedMillis = System.currentTimeMillis();
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
		else if (_campaign.shouldCacheVideo() && !isFileOk(fileUrl) && ApplifierImpactUtils.canUseExternalStorage()) {
			ApplifierImpactUtils.Log("The file was not okay, redownloading", this);
			ApplifierImpactUtils.removeFile(_campaign.getVideoFilename());
			ApplifierImpactDownloader.addListener(this);
			addCampaignToDownloads();
		}		
	}
	
	private boolean isFileOk (String fileUrl) {
		long localSize = ApplifierImpactUtils.getSizeForLocalFile(_campaign.getVideoFilename());
		long expectedSize = _campaign.getVideoFileExpectedSize();
		
		ApplifierImpactUtils.Log("isFileOk: localSize=" + localSize + ", expectedSize=" + expectedSize, this);
				
		if (localSize == -1)
			return false;
		
		if (expectedSize == -1)
			return true;
		
		if (localSize > 0 && expectedSize > 0 && localSize == expectedSize)
			return true;
			
		return false;
	}
	
	private void addCampaignToDownloads () {
		if (_campaign == null) return;
		if (_downloadList == null) _downloadList = new ArrayList<String>();
		
		_downloadList.add(_campaign.getVideoUrl());
		_cacheStartMillis = System.currentTimeMillis();
		
		// Analytics / Instrumentation
		Map<String, Object> values = new HashMap<String, Object>();
		values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VALUE_KEY, ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOCACHING_START);			
		ApplifierImpactInstrumentation.gaInstrumentationVideoCaching(_campaign, values);
		
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
