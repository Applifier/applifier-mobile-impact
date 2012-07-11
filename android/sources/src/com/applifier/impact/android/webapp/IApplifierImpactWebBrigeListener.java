package com.applifier.impact.android.webapp;

public interface IApplifierImpactWebBrigeListener {
	public void onPlayVideo (String data);
	public void onPauseVideo (String data);
	public void onVideoCompleted (String data);
	public void onCloseView (String data);
}
