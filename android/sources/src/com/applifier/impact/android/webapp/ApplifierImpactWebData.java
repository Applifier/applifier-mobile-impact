package com.applifier.impact.android.webapp;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.cache.ApplifierImpactCacheManager;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.campaign.ApplifierImpactRewardItem;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;

public class ApplifierImpactWebData {
	
	private JSONObject _campaignJson = null;
	private ArrayList<ApplifierImpactCampaign> _campaigns = null;
	private IApplifierImpactWebDataListener _listener = null;
	private ArrayList<ApplifierImpactUrlLoader> _urlLoaders = null;
	private ArrayList<ApplifierImpactUrlLoader> _failedUrlLoaders = null;
	private ApplifierImpactUrlLoader _currentLoader = null;
	private ApplifierImpactRewardItem _defaultRewardItem = null;
	private ArrayList<ApplifierImpactRewardItem> _rewardItems = null;
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
		return _campaigns;
	}
	
	public ApplifierImpactCampaign getCampaignById (String campaignId) {
		if (campaignId != null) {
			for (int i = 0; i < _campaigns.size(); i++) {
				if (_campaigns.get(i).getCampaignId().equals(campaignId))
					return _campaigns.get(i);
			}
		}
		
		return null;
	}
	
	public ArrayList<ApplifierImpactCampaign> getViewableVideoPlanCampaigns () {
		ArrayList<ApplifierImpactCampaign> viewableCampaigns = null;
		ApplifierImpactCampaign currentCampaign = null; 
		
		if (_campaigns != null) {
			viewableCampaigns = new ArrayList<ApplifierImpactCampaign>();
			for (int i = 0; i < _campaigns.size(); i++) {
				currentCampaign = _campaigns.get(i);
				if (currentCampaign != null && !currentCampaign.getCampaignStatus().equals(ApplifierImpactCampaignStatus.VIEWED))
					viewableCampaigns.add(currentCampaign);
			}
		}
		
		return viewableCampaigns;
	}

	public boolean initCampaigns () {
		String url = ApplifierImpactProperties.getCampaignQueryUrl();
		ApplifierImpactUrlLoader loader = new ApplifierImpactUrlLoader(url, ApplifierImpactRequestType.VideoPlan, 0);
		ApplifierImpactUtils.Log("VIDEOPLAN_URL: " + loader.getUrl(), this);
		addLoader(loader);
		startNextLoader();
		checkFailedUrls();
		
		return true;
	}
	
	public boolean sendCampaignViewProgress (ApplifierImpactCampaign campaign, ApplifierVideoPosition position) {
		if (campaign == null) return false;

		ApplifierImpactUtils.Log("VP: " + position.toString() + ", " + getGamerId(), this);
		
		if (position != null && getGamerId() != null && (position.equals(ApplifierVideoPosition.Start)  || position.equals(ApplifierVideoPosition.End))) {			
			String viewUrl = String.format("%s%s", ApplifierImpactProperties.IMPACT_BASE_URL, ApplifierImpactConstants.IMPACT_ANALYTICS_TRACKING_PATH);
			viewUrl = String.format("%s%s/%s/%s", viewUrl, ApplifierImpactProperties.IMPACT_GAMER_ID, position.toString(), campaign.getCampaignId());
			viewUrl = String.format("%s?%s=%s", viewUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_GAMEID_KEY, ApplifierImpactProperties.IMPACT_GAME_ID);
			viewUrl = String.format("%s&%s=%s", viewUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_REWARDITEM_KEY, getCurrentRewardItemKey());
			ApplifierImpactUrlLoader loader = new ApplifierImpactUrlLoader(viewUrl, ApplifierImpactRequestType.VideoViewed, 0);
			addLoader(loader);
			startNextLoader();
			return true;
		}
		else if (position != null && getGamerId() != null) {
			String analyticsUrl = String.format("%s", ApplifierImpactProperties.ANALYTICS_BASE_URL);
			analyticsUrl = String.format("%s?%s=%s", analyticsUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_GAMEID_KEY, ApplifierImpactProperties.IMPACT_GAME_ID);
			analyticsUrl = String.format("%s&%s=%s", analyticsUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_EVENTTYPE_KEY, position.toString());
			analyticsUrl = String.format("%s&%s=%s", analyticsUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_TRACKINGID_KEY, ApplifierImpactProperties.IMPACT_GAMER_ID);
			analyticsUrl = String.format("%s&%s=%s", analyticsUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_PROVIDERID_KEY, campaign.getCampaignId());
			analyticsUrl = String.format("%s&%s=%s", analyticsUrl, ApplifierImpactConstants.IMPACT_ANALYTICS_QUERYPARAM_REWARDITEM_KEY, getCurrentRewardItemKey());
			ApplifierImpactUrlLoader loader = new ApplifierImpactUrlLoader(analyticsUrl, ApplifierImpactRequestType.VideoViewed, 0);
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
	
	public JSONObject getData () {
		return _campaignJson;
	}
	
	public String getVideoPlan () {
		if (_campaignJson != null)
			return _campaignJson.toString();
		
		return null;
	}
	
	public String getGamerId () {
		if (_campaignJson != null) {
			if (_campaignJson.has("data")) {				
				JSONObject dataObj = null;
				try {
					dataObj = _campaignJson.getJSONObject("data");
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Malformed JSON", this);
					return null;
				}
				
				if (dataObj != null) {
					try {						
						return dataObj.getString("gamerId");
					}
					catch (Exception e) {
						ApplifierImpactUtils.Log("Malformed JSON", this);
					}
				}
			}
		}
			
		return null;
	}
	
	public String getCurrentRewardItemKey () {
		return _defaultRewardItem.getKey();
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
				campaignDataReceived(loader.getData());
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
				campaignDataFailed();
				break;
		}
		
		_isLoading = false;
		startNextLoader();
	}
	
	private void checkFailedUrls () {
		File pendingRequestFile = new File(ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactConstants.PENDING_REQUESTS_FILENAME);
		
		if (pendingRequestFile.exists()) {
			String contents = ApplifierImpactUtils.readFile(pendingRequestFile, true);
			JSONObject pendingRequestsJson = null;
			JSONArray pendingRequestsArray = null;
			ApplifierImpactUrlLoader loader = null;
			
			try {
				pendingRequestsJson = new JSONObject(contents);
				pendingRequestsArray = pendingRequestsJson.getJSONArray("data");
				
				if (pendingRequestsArray != null && pendingRequestsArray.length() > 0) {
					for (int i = 0; i < pendingRequestsArray.length(); i++) {
						JSONObject failedUrl = pendingRequestsArray.getJSONObject(i);
						loader = new ApplifierImpactUrlLoader(
								failedUrl.getString(ApplifierImpactConstants.IMPACT_FAILED_URL_URL_KEY), 
								ApplifierImpactRequestType.getValueOf(failedUrl.getString(ApplifierImpactConstants.IMPACT_FAILED_URL_REQUESTTYPE_KEY)), 
								failedUrl.getInt(ApplifierImpactConstants.IMPACT_FAILED_URL_RETRIES_KEY) + 1
								);
						
						if (loader.getRetries() <= ApplifierImpactProperties.MAX_NUMBER_OF_ANALYTICS_RETRIES)
							addLoader(loader);
					}
				}
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Problems while sending some of the failed urls.", this);
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
		
		JSONObject failedUrlsJson = new JSONObject();
		JSONArray failedUrlsArray = new JSONArray();
		
		try {
			JSONObject failedUrl = null;
			for (ApplifierImpactUrlLoader failedLoader : _failedUrlLoaders) {
				failedUrl = new JSONObject();
				failedUrl.put(ApplifierImpactConstants.IMPACT_FAILED_URL_URL_KEY, failedLoader.getUrl());
				failedUrl.put(ApplifierImpactConstants.IMPACT_FAILED_URL_REQUESTTYPE_KEY, failedLoader.getRequestType());
				failedUrl.put(ApplifierImpactConstants.IMPACT_FAILED_URL_METHODTYPE_KEY, "GET");
				failedUrl.put(ApplifierImpactConstants.IMPACT_FAILED_URL_BODY_KEY, "");
				failedUrl.put(ApplifierImpactConstants.IMPACT_FAILED_URL_RETRIES_KEY, failedLoader.getRetries());
				
				failedUrlsArray.put(failedUrl);
			}
			
			failedUrlsJson.put("data", failedUrlsArray);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Error collecting failed urls", this);
		}
		
		if (_failedUrlLoaders != null && _failedUrlLoaders.size() > 0) {
			File pendingRequestFile = new File(ApplifierImpactUtils.getCacheDirectory() + "/" + ApplifierImpactConstants.PENDING_REQUESTS_FILENAME);
			ApplifierImpactUtils.writeFile(pendingRequestFile, failedUrlsJson.toString());
		}
	}
	
	private void campaignDataReceived (String json) {
		Boolean validData = true;
		
		try {
			_campaignJson = new JSONObject(json);
			JSONObject data = null;
			
			if (_campaignJson.has(ApplifierImpactConstants.IMPACT_JSON_DATA_ROOTKEY)) {
				try {
					data = _campaignJson.getJSONObject(ApplifierImpactConstants.IMPACT_JSON_DATA_ROOTKEY);
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Malformed data JSON", this);
				}
				
				if (!data.has(ApplifierImpactConstants.IMPACT_WEBVIEW_URL_KEY)) validData = false;
				if (!data.has(ApplifierImpactConstants.IMPACT_ANALYTICS_URL_KEY)) validData = false;
				if (!data.has(ApplifierImpactConstants.IMPACT_URL_KEY)) validData = false;
				if (!data.has(ApplifierImpactConstants.IMPACT_GAMER_ID_KEY)) validData = false;
				if (!data.has(ApplifierImpactConstants.IMPACT_CAMPAIGNS_KEY)) validData = false;
				if (!data.has(ApplifierImpactConstants.IMPACT_REWARD_ITEM_KEY)) validData = false;
				
				// Parse basic properties
				ApplifierImpactProperties.WEBVIEW_BASE_URL = data.getString(ApplifierImpactConstants.IMPACT_WEBVIEW_URL_KEY);
				ApplifierImpactProperties.ANALYTICS_BASE_URL = data.getString(ApplifierImpactConstants.IMPACT_ANALYTICS_URL_KEY);
				ApplifierImpactProperties.IMPACT_BASE_URL = data.getString(ApplifierImpactConstants.IMPACT_URL_KEY);
				ApplifierImpactProperties.IMPACT_GAMER_ID = data.getString(ApplifierImpactConstants.IMPACT_GAMER_ID_KEY);
				
				// Parse campaigns
				if (validData) {
					JSONArray campaigns = data.getJSONArray(ApplifierImpactConstants.IMPACT_CAMPAIGNS_KEY);
					if (campaigns != null)
						_campaigns = deserializeCampaigns(campaigns);
				}
				
				ApplifierImpactUtils.Log("Parsed total of " + _campaigns.size() + " campaigns", this);

				
				// Parse default reward item
				if (validData) {
					_defaultRewardItem = new ApplifierImpactRewardItem(data.getJSONObject(ApplifierImpactConstants.IMPACT_REWARD_ITEM_KEY));
					if (!_defaultRewardItem.hasValidData()) {
						campaignDataFailed();
						return;
					}
				}
				
				// Parse possible multiple reward items
				if (validData && data.has(ApplifierImpactConstants.IMPACT_REWARD_ITEMS_KEY)) {
					JSONArray rewardItems = data.getJSONArray(ApplifierImpactConstants.IMPACT_REWARD_ITEMS_KEY);
					ApplifierImpactRewardItem currentRewardItem = null;
					
					for (int i = 0; i < rewardItems.length(); i++) {
						currentRewardItem = new ApplifierImpactRewardItem(rewardItems.getJSONObject(i));
						if (currentRewardItem.hasValidData()) {
							if (_rewardItems == null)
								_rewardItems = new ArrayList<ApplifierImpactRewardItem>();
							
							_rewardItems.add(currentRewardItem);
						}
					}
					
					ApplifierImpactUtils.Log("Parsed total of " + _rewardItems.size() + " reward items", this);
				}
			}
			else {
				campaignDataFailed();
				return;
			}
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Malformed JSON: " + json, this);
			campaignDataFailed();
			return;
		}
			
		if (_campaigns != null)
			ApplifierImpactUtils.Log(_campaigns.toString(), this);
		
		if (_listener != null && validData && _campaigns != null && _campaigns.size() > 0) {
			ApplifierImpactUtils.Log("WebDataCompleted: " + json, this);
			_listener.onWebDataCompleted();
			return;
		}
		else {
			campaignDataFailed();
			return;
		}
	}
	
	private void campaignDataFailed () {
		if (_listener != null)
			_listener.onWebDataFailed();		
	}
	
	private ArrayList<ApplifierImpactCampaign> deserializeCampaigns (JSONArray campaignsArray) {
		if (campaignsArray != null && campaignsArray.length() > 0) {			
			ApplifierImpactCampaign campaign = null;
			ArrayList<ApplifierImpactCampaign> retList = new ArrayList<ApplifierImpactCampaign>();
			
			for (int i = 0; i < campaignsArray.length(); i++) {
				try {
					JSONObject jsonCampaign = campaignsArray.getJSONObject(i);
					campaign = new ApplifierImpactCampaign(jsonCampaign);
					
					if (campaign.hasValidData()) {
						ApplifierImpactUtils.Log("Adding campaign to cache", this);
						retList.add(campaign);
					}
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Problem with the campaign, skipping.", this);
				}
			}
			
			return retList;
		}
		
		return null;
	}
	
	
	/* INTERNAL CLASSES */
	
	private class ApplifierImpactUrlLoader extends AsyncTask<String, Integer, String> {
		private URL _url = null;
		private URLConnection _urlConnection = null;
		private int _downloadLength = 0;
		private InputStream _input = null;
		private String _urlData = "";
		private ApplifierImpactRequestType _requestType = null;
		private int _retries = 0;
		
		public ApplifierImpactUrlLoader (String url, ApplifierImpactRequestType requestType, int existingRetries) {
			super();
			try {
				_url = new URL(url);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Problems with url: " + e.getMessage(), this);
			}
			_requestType = requestType;
			_retries = existingRetries;
		}
		
		public int getRetries () {
			return _retries;
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
				ApplifierImpactUtils.Log("Problems opening connection: " + e.getMessage(), this);
			}
			
			if (_urlConnection != null) {
				_downloadLength = _urlConnection.getContentLength();
				
				try {
					_input = new BufferedInputStream(_url.openStream());
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Problems opening stream: " + e.getMessage(), this);
				}
				
				byte data[] = new byte[1024];
				long total = 0;
				int count = 0;
				
				try {
					ApplifierImpactUtils.Log("Reading data from: " + _url.toString(), this);
					while ((count = _input.read(data)) != -1) {
						total += count;
						publishProgress((int)(total * 100 / _downloadLength));
						_urlData = _urlData.concat(new String(data));
						
						if (isCancelled())
							return null;
					}
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Problems loading url: " + e.getMessage(), this);
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
				ApplifierImpactUtils.Log("Problems closing connection: " + e.getMessage(), this);
			}	
		}
	}
}
