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
import android.util.Log;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactDownloader {
	
	private static ArrayList<String> _downloadList = null;
	private static ArrayList<IApplifierImpactDownloadListener> _downloadListeners = null;
	private static boolean _isDownloading = false;
	private static enum ApplifierDownloadEventType { DownloadCompleted, DownloadCancelled };
	private static Vector<CacheDownload> _cacheDownloads = null;
	
	public static void addDownload (String downloadUrl) {
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
			Log.d(ApplifierImpactProperties.LOG_NAME, "ApplifierImpactDownloader->stopAllDownloads()");
			for (CacheDownload cd : _cacheDownloads) {
				cd.cancel(true);
			}
		}
	}
	
	
	/* INTERNAL METHODS */
	
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
				case DownloadCancelled:
					listener.onFileDownloadCancelled(downloadUrl);
					break;
			}
		}
	}
	
	private static void cacheFile (String url) {
		if (ApplifierImpactProperties.CURRENT_ACTIVITY == null || ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext() == null) return;
		
		ConnectivityManager cm = (ConnectivityManager)ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext().getSystemService(Context.CONNECTIVITY_SERVICE);
	    
		if (cm != null && cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI).isConnected()) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Starting download for: " + url);
			CacheDownload cd = new CacheDownload();
			addToCacheDownloads(cd);
			cd.execute(url);
	    }
		else {
			Log.d(ApplifierImpactProperties.LOG_NAME, "No WIFI detected, not downloading: " + url);
		}
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
		private File _targetFile = null;
		private int _downloadLength = 0;
		private URLConnection _urlConnection = null;
		private boolean _cancelled = false;
		
		@Override
	    protected String doInBackground(String... sUrl) {
			try {
				_downloadUrl = new URL(sUrl[0]);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems with url: " + e.getMessage());
			}
			
			try {
				_urlConnection = _downloadUrl.openConnection();
				_urlConnection.setConnectTimeout(10000);
				_urlConnection.setReadTimeout(10000);
				_urlConnection.connect();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems opening connection: " + e.getMessage());
			}
			
			if (_urlConnection != null) {
				_downloadLength = _urlConnection.getContentLength();
				
				try {
					_input = new BufferedInputStream(_downloadUrl.openStream());
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems opening stream: " + e.getMessage());
				}
				
				_targetFile = new File(sUrl[0]);
				_output = getOutputStreamFor(_targetFile.getName());
				
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
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems downloading file: " + e.getMessage());
					cancelDownload();
					cacheNextFile();
					return null;
				}
				
				closeAndFlushConnection();
			}
						
			return null;
		}
		
		protected void onCancelled (Object result) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Force stopping download!");
			_cancelled = true;
			cancelDownload();
		}

		@Override
		protected void onPostExecute(String result) {
        	if (!_cancelled) {
    			removeDownload(_downloadUrl.toString());
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
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems closing connection: " + e.getMessage());
			}	    	
	    }
	    
	    private void cancelDownload () {
	    	Log.d(ApplifierImpactProperties.LOG_NAME, "Download cancelled for: " + _downloadUrl.toString());
			closeAndFlushConnection();
			ApplifierImpactUtils.removeFile(_targetFile.toString());
        	removeDownload(_downloadUrl.toString());
        	removeFromCacheDownloads(this);
        	sendToListeners(ApplifierDownloadEventType.DownloadCancelled, _downloadUrl.toString());
	    }
	}
}
