package com.applifier.impact.android.webapp;

import org.json.JSONObject;

public interface IApplifierImpactWebBrigeListener {
	public void onPlayVideo (JSONObject data);
	public void onPauseVideo (JSONObject data);
	public void onCloseView (JSONObject data);
}
