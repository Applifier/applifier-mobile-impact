package com.applifier.impact.android.cache;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;

import android.os.AsyncTask;
import android.util.Log;

public class ApplifierImpactCacheManager {
	private IApplifierImpactCacheListener _listener = null;	
	private int _videosToDownload = 0;
	
	public ApplifierImpactCacheManager () {
		createCacheDir();
		Log.d(ApplifierImpactProperties.LOG_NAME, "External storagedir: " + ApplifierImpactUtils.getCacheDirectory());
	}
	
	public void setCacheListener (IApplifierImpactCacheListener listener) {
		_listener = listener;
	}
	
	public void cacheFile (String url, String id) {
		CacheDownload cd = new CacheDownload();
		cd.execute(url, id);
	}
	
	
	public boolean isFileRequiredByCampaigns (String fileName, ArrayList<ApplifierImpactCampaign> campaigns) {
		if (fileName == null) return false;
		
		for (ApplifierImpactCampaign campaign : campaigns) {
			if (campaign.getVideoUrl().equals(fileName))
				return true;
		}
		
		return false;
	}
	
	public boolean isFileCached (String fileName) {
		File videoFile = new File (fileName);
		File cachedVideoFile = new File (ApplifierImpactUtils.getCacheDirectory() + "/" + videoFile.getName());
		
		return cachedVideoFile.exists();
	}
		
	public void updateCache (ArrayList<ApplifierImpactCampaign> activeList, ArrayList<ApplifierImpactCampaign> pruneList) {
		if (activeList != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating cache: Going through active campaigns");
			for (ApplifierImpactCampaign campaign : activeList) {
				if (!isFileCached(campaign.getVideoFilename())) {
					_videosToDownload++;
					cacheFile(campaign.getVideoUrl(), campaign.getCampaignId());
				}					
			}
		}
			
		if (pruneList != null) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Updating cache: Pruning old campaigns");
			for (ApplifierImpactCampaign campaign : pruneList) {
				if (!isFileRequiredByCampaigns(campaign.getVideoUrl(), activeList)) {
					removeCachedFile(campaign.getVideoUrl());
				}
			}
		}
	}
	
	public void initCache (ArrayList<ApplifierImpactCampaign> activeList, ArrayList<ApplifierImpactCampaign> pruneList) {
		updateCache(activeList, pruneList);
	}
	
	
	// INTERNAL METHODS
	
	private File createCacheDir () {
		File tdir = new File (ApplifierImpactUtils.getCacheDirectory());
		tdir.mkdirs();
		return tdir;
	}
	
	private FileOutputStream getOutputStreamFor (String fileName) {
		File tdir = createCacheDir();
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
	
	private void removeCachedFile (String fileName) {
		File videoFile = new File (fileName);
		File cachedVideoFile = new File (ApplifierImpactUtils.getCacheDirectory() + "/" + videoFile.getName());
		
		if (cachedVideoFile.exists()) {
			if (!cachedVideoFile.delete())
				Log.d(ApplifierImpactProperties.LOG_NAME, "Could not delete: " + cachedVideoFile.getAbsolutePath());
			else
				Log.d(ApplifierImpactProperties.LOG_NAME, "Deleted: " + cachedVideoFile.getAbsolutePath());
		}
	}
	
	
	/* INTERNAL CLASSES */
	
	private class CacheDownload extends AsyncTask<String, Integer, String> {
		private URL _downloadUrl = null;
		
		@Override
	    protected String doInBackground(String... sUrl) {
			URLConnection connection = null;
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
	        	_videosToDownload--;
	        	
	        	Log.d(ApplifierImpactProperties.LOG_NAME, "Downloaded file: " + _downloadUrl);
	        	
	        	if (_videosToDownload == 0) {
	        		// TODO: report downloads completed
	        		Log.d(ApplifierImpactProperties.LOG_NAME, "All Downloads completed.");
	        	}
	        }
	    }
	}
}
