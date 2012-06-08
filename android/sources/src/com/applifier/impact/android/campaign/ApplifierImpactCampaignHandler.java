package com.applifier.impact.android.campaign;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import android.os.AsyncTask;
import android.util.Log;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactCampaignHandler {
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
	
	public void handleCampaign () {
		cacheNextFile();
	}
	
	public ApplifierImpactCampaign getCampaign () {
		return _campaign;
	}
	
	public void setListener (IApplifierImpactCampaignHandlerListener listener) {
		_handlerListener = listener;
	}
	
	
	/* INTERNAL METHODS */
	
	private void addToFileDownloads (String fileUrl) {
		if (fileUrl == null) return;
		if (_downloadList == null) _downloadList = new ArrayList<String>();
		
		_downloadList.add(fileUrl);
	}
	
	private void checkCampaign () {
		// TODO: Check that you don't start a download for a file that is already downloading.
		
		// Check video
		if (!isFileCached(_campaign.getVideoFilename()))
			addToFileDownloads(_campaign.getVideoUrl());
		
		ApplifierImpactCampaign possiblyCachedCampaign = ApplifierImpact.cachemanifest.getCachedCampaignById(_campaign.getCampaignId());
		
		// If manifest has this campaign and their files are not the same, remove the cached file if not needed anymore.
		if (possiblyCachedCampaign != null && !_campaign.getVideoUrl().equals(possiblyCachedCampaign.getVideoUrl()) && 
			!ApplifierImpactUtils.isFileRequiredByCampaigns(possiblyCachedCampaign.getVideoUrl(), _activeCampaigns))
			ApplifierImpactUtils.removeFile(possiblyCachedCampaign.getVideoUrl());
	}
	
	private boolean isFileCached (String fileName) {
		File targetFile = new File (fileName);
		File cachedFile = new File (ApplifierImpactUtils.getCacheDirectory() + "/" + targetFile.getName());
		
		return cachedFile.exists();
	}
	
	private void cacheFile (String url, String id) {
		CacheDownload cd = new CacheDownload();
		cd.execute(url, id);
	}
	
	private void cacheNextFile () {
		if (_downloadList != null && _downloadList.size() > 0) {
			cacheFile(_downloadList.get(0), _campaign.getCampaignId());
		}
		else if (_downloadList != null) {
			if (_handlerListener != null)
				_handlerListener.onCampaignHandled(this);
		}
	}
	
	private FileOutputStream getOutputStreamFor (String fileName) {
		File tdir = ApplifierImpactUtils.createCacheDir();
		File outf = new File (tdir, fileName);
		FileOutputStream fos = null;
		
		try {
			fos = new FileOutputStream(outf);
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Problems creating FOS: " + fileName);
		}
		
		return fos;
	}
	
	
	/* INTERNAL CLASSES */
	
	private class CacheDownload extends AsyncTask<String, Integer, String> {
		private URL _downloadUrl = null;
		//private String _campaignId = null;
		
		@Override
	    protected String doInBackground(String... sUrl) {
			URLConnection connection = null;
			//_campaignId = sUrl[1];
			int downloadLength = 0;
			
			try {
				_downloadUrl = new URL(sUrl[0]);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems with url: " + e.getMessage());
			}
			
			try {
				connection = _downloadUrl.openConnection();
				connection.connect();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems opening connection: " + e.getMessage());
			}
			
			if (connection != null) {
				downloadLength = connection.getContentLength();
				InputStream input = null;
				OutputStream output = null;
				
				try {
					input = new BufferedInputStream(_downloadUrl.openStream());
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems opening stream: " + e.getMessage());
				}
				
				File target = new File(sUrl[0]);
				output = getOutputStreamFor(target.getName());
				
				byte data[] = new byte[1024];
				long total = 0;
				int count = 0;
				
				try {
					while ((count = input.read(data)) != -1) {
						total += count;
						publishProgress((int)(total * 100 / downloadLength));
						output.write(data, 0, count);
					}
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems downloading file: " + e.getMessage());
				}
				
				try {
					output.flush();
					output.close();
					input.close();
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems closing connection: " + e.getMessage());
				}
			}
						
			return null;
		}
		
	    @Override
	    protected void onPreExecute() {
	        super.onPreExecute();
	    }

	    @Override
	    protected void onProgressUpdate(Integer... progress) {
	        super.onProgressUpdate(progress);
	        
	        if (progress[0] == 100) {		        
	        	if (_downloadList != null && _downloadList.size() > 0)
	        		_downloadList.remove(0);
	        	
	        	cacheNextFile();
	        	
	        	/*
	        	_videosToDownload--;
	        	
	        	Log.d(ApplifierImpactProperties.LOG_NAME, "Downloaded file: " + _downloadUrl.toExternalForm());
	        	
	        	if (_downloadListener != null)
	        		_downloadListener.onFileDownloaded(_campaignId, "", _downloadUrl.toExternalForm());
	        	
        		Log.d(ApplifierImpactProperties.LOG_NAME, "All downloads completed.");

        		if (_videosToDownload == 0) {	        		
	        		if (_downloadListener != null)
	        			_downloadListener.onAllDownloadsCompleted();
	        		
	        		_downloadingCampaigns = null;	        		
	        	}*/
	        }
	    }
	}
}
