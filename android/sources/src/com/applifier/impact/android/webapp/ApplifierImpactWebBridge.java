package com.applifier.impact.android.webapp;


public class ApplifierImpactWebBridge {
	private enum ApplifierImpactWebEvent { PlayVideo, PauseVideo, VideoCompleted, CloseView;
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
				case VideoCompleted:
					retVal = "videoCompleted";
					break;
				case CloseView:
					retVal = "close";
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
	
	public void handleWebEvent (String event, String data) {
		if (_listener == null) return;
		
		ApplifierImpactWebEvent eventType = getEventType(event);
		
		switch (eventType) {
			case PlayVideo:
				_listener.onPlayVideo(data);
				break;
			case PauseVideo:
				_listener.onPauseVideo(data);
				break;
			case CloseView:
				_listener.onCloseView(data);
				break;
			case VideoCompleted:
				_listener.onVideoCompleted(data);
				break;
		}
	}
}
