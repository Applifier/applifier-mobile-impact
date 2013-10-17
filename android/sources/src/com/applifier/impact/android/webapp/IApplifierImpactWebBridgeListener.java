package com.applifier.impact.android.webapp;

import org.json.JSONObject;

public interface IApplifierImpactWebBridgeListener {
	public void onPlayVideo (JSONObject data);
	public void onPauseVideo (JSONObject data);
	public void onCloseImpactView (JSONObject data);
	public void onWebAppInitComplete (JSONObject data);
	public void onOpenPlayStore (JSONObject data);
}
