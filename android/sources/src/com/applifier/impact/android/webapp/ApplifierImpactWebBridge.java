package com.applifier.impact.android.webapp;

import org.json.JSONObject;

import android.util.Log;

import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactWebBridge {
	private enum ApplifierImpactWebEvent { PlayVideo, PauseVideo, CloseView, InitComplete;
		@Override
		public String toString () {
			String retVal = null;
			switch (this) {
				case PlayVideo:
					retVal = "playVideo";
					break;
				case PauseVideo:
					retVal = "pauseVideo";
					break;
				case CloseView:
					retVal = "close";
					break;
				case InitComplete:
					retVal = "initComplete";
					break;
			}
			return retVal;
		}
	}
	
	private IApplifierImpactWebBrigeListener _listener = null;
	
	private ApplifierImpactWebEvent getEventType (String event) {
		for (ApplifierImpactWebEvent evt : ApplifierImpactWebEvent.values()) {
			if (evt.toString().equals(event))
				return evt;
		}
		
		return null;
	}
	
	public ApplifierImpactWebBridge (IApplifierImpactWebBrigeListener listener) {
		_listener = listener;
	}
	
	public void handleWebEvent (String type, String data) {
		Log.d(ApplifierImpactConstants.LOG_NAME, "handleWebEvent: "+ type + ", " + data);

		if (_listener == null || data == null) return;
		
		JSONObject jsonData = null;
		JSONObject parameters = null;
		String event = type;
		
		try {
			jsonData = new JSONObject(data);
			parameters = jsonData.getJSONObject("data");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactConstants.LOG_NAME, "Error while parsing parameters: " + e.getMessage());
		}
		
		if (jsonData == null || event == null) return;
		
		ApplifierImpactWebEvent eventType = getEventType(event);
		
		if (eventType == null) return;
		
		switch (eventType) {
			case PlayVideo:
				_listener.onPlayVideo(parameters);
				break;
			case PauseVideo:
				_listener.onPauseVideo(parameters);
				break;
			case CloseView:
				_listener.onCloseImpactView(parameters);
				break;
			case InitComplete:
				_listener.onWebAppInitComplete(parameters);
				break;
		}
	}
}
