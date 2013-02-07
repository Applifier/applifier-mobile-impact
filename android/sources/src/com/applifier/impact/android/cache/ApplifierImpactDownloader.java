package com.applifier.impact.android.cache;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Vector;

import android.content.Context;
import android.net.ConnectivityManager;
import android.os.AsyncTask;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.properties.ApplifierImpactProperties;

public class ApplifierImpactDownloader {
	
	private static ArrayList<ApplifierImpactCampaign> _downloadList = null;
	private static ArrayList<IApplifierImpactDownloadListener> _downloadListeners = null;
	private static boolean _isDownloading = false;
	private static enum ApplifierDownloadEventType { DownloadCompleted, DownloadCancelled };
	private static Vector<CacheDownload> _cacheDownloads = null;
	
	public static void addDownload (ApplifierImpactCampaign downloadCampaign) {
		if (_downloadList == null) _downloadList = new ArrayList<ApplifierImpactCampaign>();
		
		if (!isInDownloads(downloadCampaign.getVideoUrl())) {
			_downloadList.add(downloadCampaign);
		}
		
		if (!_isDownloading) {
			_isDownloading = true;
			cacheNextFile();
		}
	}
	
	public static void addListener (IApplifierImpactDownloadListener listener) {
		if (_downloadListeners == null) _downloadListeners = new ArrayList<IApplifierImpactDownloadListener>();		
		if (!_downloadListeners.contains(listener))
			_downloadListeners.add(listener);
	}
	
	public static void removeListener (IApplifierImpactDownloadListener listener) {
		if (_downloadListeners == null) return;		
		if (_downloadListeners.contains(listener)) {
			_downloadListeners.remove(listener);
		}
	}
	
	public static void stopAllDownloads () {
		if (_cacheDownloads != null) {
			ApplifierImpactUtils.Log("ApplifierImpactDownloader->stopAllDownloads()", ApplifierImpactDownloader.class);
			for (CacheDownload cd : _cacheDownloads) {
				cd.cancel(true);
			}
		}
	}
	
	public static void clearData () {
		if (_cacheDownloads != null) {
			_cacheDownloads.clear();
			_cacheDownloads = null;
		}
		
		_isDownloading = false;
		
		if (_downloadListeners != null) {
			_downloadListeners.clear();
			_downloadListeners = null;
		}
	}
	
	
	/* INTERNAL METHODS */
	
	private static void removeDownload (ApplifierImpactCampaign campaign) {
		if (_downloadList == null) return;
		
		int removeIndex = -1;
		
		for (int i = 0; i < _downloadList.size(); i++) {
			if (_downloadList.get(i).equals(campaign)) {
				removeIndex = i;
				break;
			}
		}
		
		if (removeIndex > -1)
			_downloadList.remove(removeIndex);
	}
	
	private static boolean isInDownloads (String downloadUrl) {
		if (_downloadList != null) {
			for (ApplifierImpactCampaign download : _downloadList) {
				if (download.getVideoUrl().equals(downloadUrl))
					return true;
			}
		}
		
		return false;
	}
	
	private static void sendToListeners (ApplifierDownloadEventType type, String downloadUrl) {
		if (_downloadListeners == null) return;

		ArrayList<IApplifierImpactDownloadListener> tmpListeners = (ArrayList<IApplifierImpactDownloadListener>)_downloadListeners.clone();
		
		for (IApplifierImpactDownloadListener listener : tmpListeners) {
			switch (type) {
				case DownloadCompleted:
					listener.onFileDownloadCompleted(downloadUrl);
					break;
				case DownloadCancelled:
					listener.onFileDownloadCancelled(downloadUrl);
					break;
			}
		}
	}
	
	private static void cacheCampaign (ApplifierImpactCampaign campaign) {
		if (ApplifierImpactProperties.CURRENT_ACTIVITY == null || ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext() == null) return;
		
		ConnectivityManager cm = (ConnectivityManager)ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext().getSystemService(Context.CONNECTIVITY_SERVICE);
	    
		if (cm != null && cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI).isConnected()) {
			ApplifierImpactUtils.Log("Starting download for: " + campaign.getVideoFilename(), ApplifierImpactDownloader.class);
			CacheDownload cd = new CacheDownload(campaign);
			addToCacheDownloads(cd);
			cd.execute(campaign.getVideoUrl());
	    }
		else {
			ApplifierImpactUtils.Log("No WIFI detected, not downloading: " + campaign.getVideoUrl(), ApplifierImpactDownloader.class);
			removeDownload(campaign);
			sendToListeners(ApplifierDownloadEventType.DownloadCancelled, campaign.getVideoUrl());
			cacheNextFile(); 
		}
	}
	
	private static void cacheNextFile () {
		if (_downloadList != null && _downloadList.size() > 0) {
			cacheCampaign(_downloadList.get(0));
		}
		else if (_downloadList != null) {
			_isDownloading = false;
			ApplifierImpactUtils.Log("All downloads completed.", ApplifierImpactDownloader.class);
		}
	}
	
	private static FileOutputStream getOutputStreamFor (String fileName) {
		File tdir = ApplifierImpactUtils.createCacheDir();
		File outf = new File (tdir, fileName);
		FileOutputStream fos = null;
		
		try {
			fos = new FileOutputStream(outf);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Problems creating FOS: " + fileName, ApplifierImpactDownloader.class);
			return null;
		}
		
		return fos;
	}
	
	private static void addToCacheDownloads (CacheDownload cd) {
		if (_cacheDownloads == null) 
			_cacheDownloads = new Vector<ApplifierImpactDownloader.CacheDownload>();
		
		_cacheDownloads.add(cd);
	}
	
	private static void removeFromCacheDownloads (CacheDownload cd) {
		if (_cacheDownloads != null)
			_cacheDownloads.remove(cd);
	}
	
	
	/* INTERNAL CLASSES */
	
	private static class CacheDownload extends AsyncTask<String, Integer, String> {
		private URL _downloadUrl = null;
		private InputStream _input = null;
		private OutputStream _output = null;
		private int _downloadLength = 0;
		private URLConnection _urlConnection = null;
		private boolean _cancelled = false;
		private ApplifierImpactCampaign _campaign = null;
		
		public CacheDownload (ApplifierImpactCampaign campaign) {
			_campaign = campaign;
		}
		
		@Override
	    protected String doInBackground(String... sUrl) {
			long startTime = System.currentTimeMillis();
			long duration = 0;
			
			try {
				_downloadUrl = new URL(sUrl[0]);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Problems with url: " + e.getMessage(), this);
			}
			
			try {
				_urlConnection = _downloadUrl.openConnection();
				_urlConnection.setConnectTimeout(10000);
				_urlConnection.setReadTimeout(10000);
				_urlConnection.connect();
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Problems opening connection: " + e.getMessage(), this);
			}
			
			if (_urlConnection != null) {
				_downloadLength = _urlConnection.getContentLength();
				
				try {
					_input = new BufferedInputStream(_downloadUrl.openStream());
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Problems opening stream: " + e.getMessage(), this);
				}
				
				_output = getOutputStreamFor(_campaign.getVideoFilename());
				if (_output == null)
					onCancelled(this);
				
				byte data[] = new byte[1024];
				long total = 0;
				int count = 0;
				
				try {
					while ((count = _input.read(data)) != -1) {
						total += count;
						publishProgress((int)(total * 100 / _downloadLength));
						_output.write(data, 0, count);
						
						if (_cancelled) {
							return null;
						}
					}
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Problems downloading file: " + e.getMessage(), this);
					cancelDownload();
					cacheNextFile();
					return null;
				}
				
				closeAndFlushConnection();
				duration = System.currentTimeMillis() - startTime;
				ApplifierImpactUtils.Log("File: " + _campaign.getVideoFilename() + " of size: " + total + " downloaded in: " + duration + "ms", this);
			}
						
			return null;
		}
		
		protected void onCancelled (Object result) {
			ApplifierImpactUtils.Log("Force stopping download!", this);
			_cancelled = true;
			cancelDownload();
		}

		@Override
		protected void onPostExecute(String result) {
        	if (!_cancelled) {
    			removeDownload(_campaign);
            	removeFromCacheDownloads(this);
            	cacheNextFile();
            	sendToListeners(ApplifierDownloadEventType.DownloadCompleted, _downloadUrl.toString());
    			super.onPostExecute(result);
        	}
		}

		@Override
	    protected void onPreExecute() {
	        super.onPreExecute();
	    }

	    @Override
	    protected void onProgressUpdate(Integer... progress) {
	        super.onProgressUpdate(progress);
	        
	        if (progress[0] == 100) {
	        }
	    }
	    
	    private void closeAndFlushConnection () {			
			try {
				_output.flush();
				_output.close();
				_input.close();
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Problems closing connection: " + e.getMessage(), this);
			}	    	
	    }
	    
	    private void cancelDownload () {
	    	ApplifierImpactUtils.Log("Download cancelled for: " + _downloadUrl.toString(), this);
			closeAndFlushConnection();
			ApplifierImpactUtils.removeFile(_campaign.getVideoFilename());
        	removeDownload(_campaign);
        	removeFromCacheDownloads(this);
        	sendToListeners(ApplifierDownloadEventType.DownloadCancelled, _downloadUrl.toString());
	    }
	}
}
