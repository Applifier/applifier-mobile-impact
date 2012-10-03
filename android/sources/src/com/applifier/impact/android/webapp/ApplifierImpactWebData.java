package com.applifier.impact.android.webapp;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;

public class ApplifierImpactWebData {
	
	private JSONObject _videoPlan = null;
	private ArrayList<ApplifierImpactCampaign> _videoPlanCampaigns = null;
	private IApplifierImpactWebDataListener _listener = null;
	private ArrayList<ApplifierImpactUrlLoader> _urlLoaders = null;
	private ArrayList<ApplifierImpactUrlLoader> _failedUrlLoaders = null;
	private ApplifierImpactUrlLoader _currentLoader = null;
	private boolean _isLoading = false;
	
	public static enum ApplifierVideoPosition { Start, FirstQuartile, MidPoint, ThirdQuartile, End;
		@Override
		public String toString () {
			String output = null;
			switch (this) {
				case FirstQuartile:
					output = "first_quartile";
					break;
				case MidPoint:
					output = "mid_point";
					break;
				case ThirdQuartile:
					output = "third_quartile";
					break;
				case End:
					output = "view";
					break;
				default:
					output = name().toString().toLowerCase();
					break;					
			}
			
			return output;
		}
	};
	
	private static enum ApplifierImpactRequestType { VideoPlan, VideoViewed, Unsent;
		@Override
		public String toString () {
			String output = name().toString().toLowerCase();
			return output;
		}
		
		public static ApplifierImpactRequestType getValueOf (String value) {
			if (VideoPlan.toString().equals(value.toLowerCase()))
				return VideoPlan;
			else if (VideoViewed.toString().equals(value.toLowerCase()))
				return VideoViewed;
			else if (Unsent.toString().equals(value.toLowerCase()))
				return Unsent;
			
			return null;
		}
	};
	
	public ApplifierImpactWebData () {	
	}
	
	public void setWebDataListener (IApplifierImpactWebDataListener listener) {
		_listener = listener;
	}
	
	public ArrayList<ApplifierImpactCampaign> getVideoPlanCampaigns () {
		return _videoPlanCampaigns;
	}
	
	public ApplifierImpactCampaign getCampaignById (String campaignId) {
		if (campaignId != null) {
			for (int i = 0; i < _videoPlanCampaigns.size(); i++) {
				if (_videoPlanCampaigns.get(i).getCampaignId().equals(campaignId))
					return _videoPlanCampaigns.get(i);
			}
		}
		
		return null;
	}
	
	public ArrayList<ApplifierImpactCampaign> getViewableVideoPlanCampaigns () {
		ArrayList<ApplifierImpactCampaign> viewableCampaigns = null;
		ApplifierImpactCampaign currentCampaign = null; 
		
		if (_videoPlanCampaigns != null) {
			viewableCampaigns = new ArrayList<ApplifierImpactCampaign>();
			for (int i = 0; i < _videoPlanCampaigns.size(); i++) {
				currentCampaign = _videoPlanCampaigns.get(i);
				if (currentCampaign != null && !currentCampaign.getCampaignStatus().equals(ApplifierImpactCampaignStatus.VIEWED))
					viewableCampaigns.add(currentCampaign);
			}
		}
		
		return viewableCampaigns;
	}

	public boolean initVideoPlan () {
		String url = ApplifierImpactProperties.IMPACT_BASEURL + ApplifierImpactProperties.IMPACT_MOBILEPATH + "/" + ApplifierImpactProperties.IMPACT_CAMPAIGNPATH;
		String queryString = "gameId=" + ApplifierImpactProperties.IMPACT_APP_ID + "&openUdid=someudid&device=iphone&iosVersion=6.0";
		
		ApplifierImpactUrlLoader loader = new ApplifierImpactUrlLoader(url + "?" + queryString, ApplifierImpactRequestType.VideoPlan);
		addLoader(loader);
		startNextLoader();
		checkFailedUrls();
		
		return true;
	}
	
	public boolean sendCampaignViewProgress (ApplifierImpactCampaign campaign, ApplifierVideoPosition position) {
		if (campaign == null) return false;

		Log.d(ApplifierImpactProperties.LOG_NAME, "VP: " + position.toString() + ", " + getGamerId());
		
		if (position != null && getGamerId() != null && (position.equals(ApplifierVideoPosition.Start)  || position.equals(ApplifierVideoPosition.End))) {
			String viewUrl = ApplifierImpactProperties.IMPACT_BASEURL + ApplifierImpactProperties.IMPACT_GAMERPATH + "/" + getGamerId() + "/" + position.toString() + "/" + campaign.getCampaignId();
			ApplifierImpactUrlLoader loader = new ApplifierImpactUrlLoader(viewUrl, ApplifierImpactRequestType.VideoViewed);
			addLoader(loader);
			startNextLoader();
			return true;
		}
		
		return false;
	}
	
	public void stopAllRequests () {
		_urlLoaders.clear();
		
		if (_currentLoader != null)
			_currentLoader.cancel(true);
	}
	
	public String getVideoPlan () {
		if (_videoPlan != null)
			return _videoPlan.toString();
		
		return null;
	}
	
	public String getGamerId () {
		if (_videoPlan != null) {
			if (_videoPlan.has("data")) {				
				JSONObject dataObj = null;
				try {
					dataObj = _videoPlan.getJSONObject("data");
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON");
					return null;
				}
				
				if (dataObj != null) {
					try {						
						return dataObj.getString("gamerId");
					}
					catch (Exception e) {
						Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON");
					}
				}
			}
		}
			
		return null;
	}
	
	
	/* INTERNAL METHODS */
	
	private void addLoader (ApplifierImpactUrlLoader loader) {
		if (_urlLoaders == null)
			_urlLoaders = new ArrayList<ApplifierImpactWebData.ApplifierImpactUrlLoader>();
		
		_urlLoaders.add(loader);
	}
	
	private void startNextLoader () {
		if (_urlLoaders.size() > 0 && !_isLoading) {
			_isLoading = true;
			_currentLoader = (ApplifierImpactUrlLoader)_urlLoaders.remove(0).execute();
		}			
	}
	
	private void urlLoadCompleted (ApplifierImpactUrlLoader loader) {
		switch (loader.getRequestType()) {
			case VideoPlan:
				videoPlanReceived(loader.getData());
				break;
			case VideoViewed:
				break;
			case Unsent:
				break;
		}
		
		_isLoading = false;
		startNextLoader();
	}
	
	private void urlLoadFailed (ApplifierImpactUrlLoader loader) {
		switch (loader.getRequestType()) {
			case VideoViewed:
			case Unsent:
				writeFailedUrl(loader);
				break;
			case VideoPlan:
				videoPlanFailed();
				break;
		}
		
		_isLoading = false;
		startNextLoader();
	}
	
	private void checkFailedUrls () {
		File pendingRequestFile = new File(ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactProperties.PENDING_REQUESTS_FILENAME);
		
		if (pendingRequestFile.exists()) {
			String contents = ApplifierImpactUtils.readFile(pendingRequestFile, true);
			String[] failedUrls = contents.split("\\r?\\n");
			String[] splittedLine = null;
			
			for (String line : failedUrls) {
				splittedLine = line.split("  ");
				ApplifierImpactUrlLoader loader = new ApplifierImpactUrlLoader(splittedLine[0], ApplifierImpactRequestType.getValueOf(splittedLine[1]));
				addLoader(loader);
			}
			
			ApplifierImpactUtils.removeFile(pendingRequestFile.toString());
		}
		
		startNextLoader();
	}
	
	private void writeFailedUrl (ApplifierImpactUrlLoader loader) {
		if (loader == null) return;
		if (_failedUrlLoaders == null)
			_failedUrlLoaders = new ArrayList<ApplifierImpactWebData.ApplifierImpactUrlLoader>();
		
		if (!_failedUrlLoaders.contains(loader)) {
			_failedUrlLoaders.add(loader);
		}
		
		String fileContent = "";
		
		for (ApplifierImpactUrlLoader failedLoader : _failedUrlLoaders) {
			fileContent = fileContent.concat(failedLoader.getUrl() + "  " + failedLoader.getRequestType().toString() + "\n");
		}
		
		File pendingRequestFile = new File(ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactProperties.PENDING_REQUESTS_FILENAME);
		ApplifierImpactUtils.writeFile(pendingRequestFile, fileContent);
	}
	
	private void videoPlanReceived (String json) {
		try {
			_videoPlan = new JSONObject(json);
			JSONObject data = null;
			
			if (_videoPlan.has("data")) {
				try {
					data = _videoPlan.getJSONObject("data");
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed data JSON");
				}
				
				_videoPlanCampaigns = ApplifierImpactUtils.createCampaignsFromJson(data);
			}	
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON!");
		}
		
		if (_listener != null)
			_listener.onWebDataCompleted();
		
		Log.d(ApplifierImpactProperties.LOG_NAME, _videoPlanCampaigns.toString());
	}
	
	private void videoPlanFailed () {
		if (_listener != null)
			_listener.onWebDataFailed();		
	}
	
	
	/* INTERNAL CLASSES */
	
	private class ApplifierImpactUrlLoader extends AsyncTask<String, Integer, String> {
		private URL _url = null;
		private URLConnection _urlConnection = null;
		private int _downloadLength = 0;
		private InputStream _input = null;
		private String _urlData = "";
		private ApplifierImpactRequestType _requestType = null;
		
		public ApplifierImpactUrlLoader (String url, ApplifierImpactRequestType requestType) {
			super();
			try {
				_url = new URL(url);
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems with url: " + e.getMessage());
			}
			_requestType = requestType;
		}
		
		public String getUrl () {
			return _url.toString();
		}
		
		public String getData () {
			return _urlData;
		}
		
		public ApplifierImpactRequestType getRequestType () {
			return _requestType;
		}
		
		@Override
		protected String doInBackground(String... params) {
			try {
				_urlConnection = _url.openConnection();
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
					_input = new BufferedInputStream(_url.openStream());
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems opening stream: " + e.getMessage());
				}
				
				byte data[] = new byte[1024];
				long total = 0;
				int count = 0;
				
				try {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Reading data from: " + _url.toString());
					while ((count = _input.read(data)) != -1) {
						total += count;
						publishProgress((int)(total * 100 / _downloadLength));
						_urlData = _urlData.concat(new String(data));
						
						if (isCancelled())
							return null;
					}
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems loading url: " + e.getMessage());
					cancel(true);
					return null;
				}
			}
			
			return null;
		}

		protected void onCancelled(Object result) {
			closeAndFlushConnection();
			urlLoadFailed(this);
		}

		@Override
		protected void onPostExecute(String result) {
			if (!isCancelled()) {
				closeAndFlushConnection();
				urlLoadCompleted(this);
 			}
			
			super.onPostExecute(result);
		}

		@Override
		protected void onProgressUpdate(Integer... values) {
			super.onProgressUpdate(values);
		}
		
		private void closeAndFlushConnection () {
			try {
				_input.close();
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems closing connection: " + e.getMessage());
			}	
		}
	}
}
