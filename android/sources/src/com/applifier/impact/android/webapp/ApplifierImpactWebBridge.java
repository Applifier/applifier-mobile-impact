package com.applifier.impact.android.webapp;

import org.json.JSONObject;

import android.util.Log;

import com.applifier.impact.android.ApplifierImpactProperties;

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
	
	public void handleWebEvent (String data) {
		if (_listener == null || data == null) return;
		
		JSONObject paramObj = null;
		String event = null;
		
		try {
			paramObj = new JSONObject(data);
			event = paramObj.getString("type");
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Error while parsing parameters: " + e.getMessage());
		}
		
		if (paramObj == null || event == null) return;
		
		ApplifierImpactWebEvent eventType = getEventType(event);
		
		if (eventType == null) return;
		
		switch (eventType) {
			case PlayVideo:
				_listener.onPlayVideo(paramObj);
				break;
			case PauseVideo:
				_listener.onPauseVideo(paramObj);
				break;
			case CloseView:
				_listener.onCloseView(paramObj);
				break;
			case InitComplete:
				_listener.onWebAppInitComplete(paramObj);
				break;
		}
	}
}
