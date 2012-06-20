package com.applifier.impact.android.cache;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign;

public class ApplifierImpactWebData {
	
	private JSONObject _videoPlan = null;
	private VideoPlanLoader _videoPlanLoader = null;
	private ArrayList<ApplifierImpactCampaign> _videoPlanCampaigns = null;
	private IApplifierImpactWebDataListener _listener = null;
	
	public ApplifierImpactWebData () {	
	}
	
	public void setWebDataListener (IApplifierImpactWebDataListener listener) {
		_listener = listener;
	}
	
	public ArrayList<ApplifierImpactCampaign> getVideoPlanCampaigns () {
		return _videoPlanCampaigns;
	}
	
	public int getCampaignAmount () {
		if (_videoPlanCampaigns == null) return 0;
		return _videoPlanCampaigns.size();
	}
	
	public ApplifierImpactCampaign getCampaignById (String campaignId) {
		for (ApplifierImpactCampaign currentCampaign : _videoPlanCampaigns) {
			if (currentCampaign.getCampaignId().equals(campaignId))
				return currentCampaign;
		}
		
		return null;
	}
	
	public boolean initVideoPlan (ArrayList<String> cachedCampaignIds) {		
		JSONObject data = getCachedCampaignIdsArray(cachedCampaignIds);
		String cachedCampaignData = "";
		
		if (data != null)
			cachedCampaignData = data.toString();
					
		_videoPlanLoader = new VideoPlanLoader();
		_videoPlanLoader.execute(ApplifierImpactProperties.WEBDATA_URL + "?c=" + cachedCampaignData);
		
		return true;
	}
	
	
	/* INTERNAL METHODS */
	
	private JSONObject getCachedCampaignIdsArray (ArrayList<String> cachedCampaignIds) {
		JSONObject data = new JSONObject();
		JSONArray campaignIds = null;
		
		if (cachedCampaignIds != null && cachedCampaignIds.size() > 0) {
			campaignIds = new JSONArray();
			
			for (String id : cachedCampaignIds) {
				campaignIds.put(id);
			}
		}
		
		try {
			data.put("c", campaignIds);
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON");
			return null;
		}
		
		return data;
	}
	
	private void videoPlanReceived (String json) {
		try {
			_videoPlan = new JSONObject(json);
			_videoPlanCampaigns = ApplifierImpactUtils.createCampaignsFromJson(_videoPlan);
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Malformed JSON!");
		}
		
		if (_listener != null)
			_listener.onWebDataCompleted();
	}
	
	
	/* INTERNAL CLASSES */
	
	private class VideoPlanLoader extends AsyncTask<String, Integer, String> {
		private URL _videoPlanUrl = null;
		private URLConnection _urlConnection = null;
		private int _downloadLength = 0;
		private InputStream _input = null;
		private String _urlData = "";
		
		@Override
		protected String doInBackground(String... params) {
			try {
				_videoPlanUrl = new URL(params[0]);				
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "Problems with url: " + e.getMessage());
			}
			
			try {
				_urlConnection = _videoPlanUrl.openConnection();
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
					_input = new BufferedInputStream(_videoPlanUrl.openStream());
				}
				catch (Exception e) {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems opening stream: " + e.getMessage());
				}
				
				byte data[] = new byte[1024];
				long total = 0;
				int count = 0;
				
				try {
					Log.d(ApplifierImpactProperties.LOG_NAME, "Reading data from: " + _videoPlanUrl.toString());
					while ((count = _input.read(data)) != -1) {
						total += count;
						publishProgress((int)(total * 100 / _downloadLength));
						_urlData = _urlData.concat(new String(data));
						
						if (isCancelled())
							return null;
					}
				}
				catch (Exception e) {
					closeAndFlushConnection();
					Log.d(ApplifierImpactProperties.LOG_NAME, "Problems downloading file: " + e.getMessage());
					return null;
				}
			}
			
			return null;
		}

		protected void onCancelled(Object result) {
			closeAndFlushConnection();
		}

		@Override
		protected void onPostExecute(String result) {
			if (!isCancelled()) {
				closeAndFlushConnection();
				videoPlanReceived(_urlData);
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
