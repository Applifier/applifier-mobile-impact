package com.applifier.impact.android.cache;

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

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactDownloader {
	private static ArrayList<String> _downloadList = null;
	private static ArrayList<IApplifierImpactDownloadListener> _downloadListeners = null;
	private static boolean _isDownloading = false;
	private static enum ApplifierDownloadEventType { DownloadCompleted };
	
	public static void addDownload (String downloadUrl) {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Got download: " + downloadUrl);
		
		if (_downloadList == null) _downloadList = new ArrayList<String>();
		
		if (!isInDownloads(downloadUrl)) {
			_downloadList.add(downloadUrl);
		}
		
		if (!_isDownloading) {
			_isDownloading = true;
			cacheNextFile();
		}
	}
	
	public static void addListener (IApplifierImpactDownloadListener listener) {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Got listener: ");
		if (_downloadListeners == null) _downloadListeners = new ArrayList<IApplifierImpactDownloadListener>();
		
		if (!_downloadListeners.contains(listener))
			_downloadListeners.add(listener);
	}
	
	public static void removeListener (IApplifierImpactDownloadListener listener) {
		if (_downloadListeners == null) return;		
		if (_downloadListeners.contains(listener)) {
			_downloadListeners.remove(listener);
			Log.d(ApplifierImpactProperties.LOG_NAME, "Removing listener");
		}
			
	}
	
	private static void removeDownload (String downloadUrl) {
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
	
	private static boolean isInDownloads (String downloadUrl) {
		if (_downloadList != null) {
			for (String download : _downloadList) {
				if (download.equals(downloadUrl))
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
			}
		}
	}
	
	private static void cacheFile (String url) {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Starting download for: " + url);
		CacheDownload cd = new CacheDownload();
		cd.execute(url);
	}
	
	private static void cacheNextFile () {
		if (_downloadList != null && _downloadList.size() > 0) {
			cacheFile(_downloadList.get(0));
		}
		else if (_downloadList != null) {
			_isDownloading = false;
			Log.d(ApplifierImpactProperties.LOG_NAME, "All downloads completed.");
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
			Log.d(ApplifierImpactProperties.LOG_NAME, "Problems creating FOS: " + fileName);
		}
		
		return fos;
	}
	
	
	/* INTERNAL CLASSES */
	
	private static class CacheDownload extends AsyncTask<String, Integer, String> {
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
	        	removeDownload(_downloadUrl.toString());
	        	cacheNextFile();
	        	sendToListeners(ApplifierDownloadEventType.DownloadCompleted, _downloadUrl.toString());
	        }
	    }
	}
}
