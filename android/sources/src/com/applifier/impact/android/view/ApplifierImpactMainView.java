package com.applifier.impact.android.view;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.media.MediaPlayer;
import android.os.Build;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;
import com.applifier.impact.android.video.ApplifierImpactVideoPlayView;
import com.applifier.impact.android.video.IApplifierImpactVideoPlayerListener;
import com.applifier.impact.android.webapp.ApplifierImpactInstrumentation;
import com.applifier.impact.android.webapp.ApplifierImpactWebBridge;
import com.applifier.impact.android.webapp.ApplifierImpactWebData;
import com.applifier.impact.android.webapp.ApplifierImpactWebData.ApplifierVideoPosition;
import com.applifier.impact.android.webapp.ApplifierImpactWebView;
import com.applifier.impact.android.webapp.IApplifierImpactWebViewListener;
import com.applifier.impact.android.zone.ApplifierImpactZone;

public class ApplifierImpactMainView extends RelativeLayout implements 	IApplifierImpactWebViewListener, 
																		IApplifierImpactVideoPlayerListener {

	public static enum ApplifierImpactMainViewState { WebView, VideoPlayer };
	public static enum ApplifierImpactMainViewAction { VideoStart, VideoEnd, VideoSkipped, BackButtonPressed, RequestRetryVideoPlay };
	private static final int FILL_PARENT = -1;
	
	// Views
	public ApplifierImpactVideoPlayView videoplayerview = null;
	public ApplifierImpactWebView webview = null;

	// Listener
	private IApplifierImpactMainViewListener _listener = null;
	private ApplifierImpactMainViewState _currentState = ApplifierImpactMainViewState.WebView;

	
	public ApplifierImpactMainView(Context context, IApplifierImpactMainViewListener listener) {
		super(context);
		_listener = listener;
		init();
	}
	
	
	public ApplifierImpactMainView(Context context) {
		super(context);
		init();
	}

	public ApplifierImpactMainView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public ApplifierImpactMainView(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);		
		init();
	}
	
	
	/* PUBLIC METHODS */
	
	public void openImpact (String view, JSONObject data) {
		if (ApplifierImpactProperties.getCurrentActivity() != null && ApplifierImpactProperties.getCurrentActivity().getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
			webview.setWebViewCurrentView(view, data);
			
			if (this.getParent() != null && (ViewGroup)this.getParent() != null)
				((ViewGroup)this.getParent()).removeView(this);
			
			if (this.getParent() == null)
				ApplifierImpactProperties.getCurrentActivity().addContentView(this, new FrameLayout.LayoutParams(FILL_PARENT, FILL_PARENT));
			
			setViewState(ApplifierImpactMainViewState.WebView);
		}
		else {
			ApplifierImpactUtils.Log("Cannot open, wrong activity", this);
		}
	}
	
	public void closeImpact (JSONObject data) {		
		if (this.getParent() != null) {
			ViewGroup vg = (ViewGroup)this.getParent();
			if (vg != null)
				vg.removeView(this);
		}
		
		destroyVideoPlayerView();
		ApplifierImpactProperties.SELECTED_CAMPAIGN = null;
	}
	
	public void setViewState (ApplifierImpactMainViewState state) {
		if (!_currentState.equals(state)) {
			_currentState = state;
			
			switch (state) {
				case WebView:
					removeFromMainView(webview);
					addView(webview, new FrameLayout.LayoutParams(FILL_PARENT, FILL_PARENT));
					focusToView(webview);
					break;
				case VideoPlayer:
					if (videoplayerview == null) {
						createVideoPlayerView();
						bringChildToFront(webview);
						focusToView(webview);
					}
					break;
			}
		}
	}
	
	public ApplifierImpactMainViewState getViewState () {
		return _currentState;
	}
	
	public void afterVideoPlaybackOperations () {
		if (videoplayerview != null) {
			videoplayerview.setKeepScreenOn(false);
		}
		
		destroyVideoPlayerView();
		setViewState(ApplifierImpactMainViewState.WebView);		
		ApplifierImpactProperties.getCurrentActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
	}
	
	@Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
		switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
				onBackButtonClicked(this);
		    	return true;
		}
    	
    	return false;
    }
	
    protected void onAttachedToWindow() {
    	super.onAttachedToWindow();
    	focusToView(this);
    }
	
	/* PRIVATE METHODS */
	
	private void init () {
		ApplifierImpactUtils.Log("Init", this);
		this.setId(1001);
		createWebView();
	}
	
	private void destroyVideoPlayerView () {
		ApplifierImpactUtils.Log("Destroying player", this);
		
		if (videoplayerview != null)
			videoplayerview.clearVideoPlayer();
		
		removeFromMainView(videoplayerview);
		videoplayerview = null;
	}
	
	private void createVideoPlayerView () {
		videoplayerview = new ApplifierImpactVideoPlayView(ApplifierImpactProperties.getCurrentActivity().getBaseContext(), this);
		videoplayerview.setLayoutParams(new FrameLayout.LayoutParams(FILL_PARENT, FILL_PARENT));
		videoplayerview.setId(1002);
		addView(videoplayerview);
	}
	
	private void createWebView () {
		webview = new ApplifierImpactWebView(ApplifierImpactProperties.getCurrentActivity(), this, new ApplifierImpactWebBridge(ApplifierImpact.instance));
		webview.setId(1003);
		addView(webview, new FrameLayout.LayoutParams(FILL_PARENT, FILL_PARENT));
	}
	
	private void removeFromMainView (View view) {
		if (view != null) {
			view.setFocusable(false);
			view.setFocusableInTouchMode(false);
			
			ViewGroup vg = (ViewGroup)view.getParent();
			if (vg != null)
				vg.removeView(view);
		}
	}
	
	private void focusToView (View view) {
		if (view != null) {
			view.setFocusable(true);
			view.setFocusableInTouchMode(true);
			view.requestFocus();
		}
	}
	
	private void sendActionToListener (ApplifierImpactMainViewAction action) {
		if (_listener != null) {
			_listener.onMainViewAction(action);
		}		
	}
	
	
	// IApplifierImpactViewListener
	@Override
	public void onBackButtonClicked (View view) {
		ApplifierImpactUtils.Log("Current state: " + _currentState.toString(), this);
		
		if (videoplayerview != null) {
			ApplifierImpactUtils.Log("Seconds: " + videoplayerview.getSecondsUntilBackButtonAllowed(), this);
		}
		
		if ((ApplifierImpactProperties.SELECTED_CAMPAIGN != null &&
			ApplifierImpactProperties.SELECTED_CAMPAIGN.isViewed()) ||
			_currentState != ApplifierImpactMainViewState.VideoPlayer || 
			(_currentState == ApplifierImpactMainViewState.VideoPlayer && videoplayerview != null && videoplayerview.getSecondsUntilBackButtonAllowed() == 0) ||
			(_currentState == ApplifierImpactMainViewState.VideoPlayer && ApplifierImpactWebData.getZoneManager().getCurrentZone().disableBackButtonForSeconds() == 0)) {
			sendActionToListener(ApplifierImpactMainViewAction.BackButtonPressed);
		}
		else {
			ApplifierImpactUtils.Log("Prevented back-button", this);
		}
	}
	
	// IApplifierImpactVideoPlayerListener
	@Override
	public void onVideoPlaybackStarted () {
		ApplifierImpactUtils.Log("onVideoPlaybackStarted", this);
		
		JSONObject params = new JSONObject();
		JSONObject spinnerParams = new JSONObject();
		
		try {
			params.put(ApplifierImpactConstants.IMPACT_NATIVEEVENT_CAMPAIGNID_KEY, ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId());
			spinnerParams.put(ApplifierImpactConstants.IMPACT_TEXTKEY_KEY, ApplifierImpactConstants.IMPACT_TEXTKEY_BUFFERING);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create JSON", this);
		}
		
		sendActionToListener(ApplifierImpactMainViewAction.VideoStart);
		bringChildToFront(videoplayerview);
		
		// SENSOR_LANDSCAPE
		int targetOrientation = 6;
		
		if (Build.VERSION.SDK_INT < 9)
			targetOrientation = 0;
		
		ApplifierImpactZone currentZone = ApplifierImpactWebData.getZoneManager().getCurrentZone();
		if (currentZone.useDeviceOrientationForVideo()) {
			ApplifierImpactProperties.getCurrentActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
			
			// UNSPECIFIED
			targetOrientation = -1;
		}
		
		ApplifierImpactProperties.getCurrentActivity().setRequestedOrientation(targetOrientation);
		
		focusToView(videoplayerview);
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_HIDESPINNER, spinnerParams);
		webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_COMPLETED, params);
	}
	
	@Override
	public void onEventPositionReached (ApplifierVideoPosition position) {
		if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null && !ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignStatus().equals(ApplifierImpactCampaignStatus.VIEWED))
			ApplifierImpact.webdata.sendCampaignViewProgress(ApplifierImpactProperties.SELECTED_CAMPAIGN, position);
	}
	
	@Override
	public void onCompletion(MediaPlayer mp) {
		ApplifierImpactUtils.Log("onCompletion", this);
		afterVideoPlaybackOperations();
		onEventPositionReached(ApplifierVideoPosition.End);
		
		JSONObject params = new JSONObject();
		
		try {
			params.put(ApplifierImpactConstants.IMPACT_NATIVEEVENT_CAMPAIGNID_KEY, ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId());
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create JSON", this);
		}
		
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_VIDEOCOMPLETED, params);
		sendActionToListener(ApplifierImpactMainViewAction.VideoEnd);
	}
	
	public void onVideoPlaybackError () {
		afterVideoPlaybackOperations();
		
		ApplifierImpactUtils.Log("onVideoPlaybackError", this);		
		ApplifierImpact.webdata.sendAnalyticsRequest(ApplifierImpactConstants.IMPACT_ANALYTICS_EVENTTYPE_VIDEOERROR, ApplifierImpactProperties.SELECTED_CAMPAIGN);
		
		JSONObject errorParams = new JSONObject();
		JSONObject spinnerParams = new JSONObject();
		JSONObject params = new JSONObject();
		
		try {
			errorParams.put(ApplifierImpactConstants.IMPACT_TEXTKEY_KEY, ApplifierImpactConstants.IMPACT_TEXTKEY_VIDEOPLAYBACKERROR);
			spinnerParams.put(ApplifierImpactConstants.IMPACT_TEXTKEY_KEY, ApplifierImpactConstants.IMPACT_TEXTKEY_BUFFERING);
			params.put(ApplifierImpactConstants.IMPACT_NATIVEEVENT_CAMPAIGNID_KEY, ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId());
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create JSON", this);
		}
		
		webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_COMPLETED, params);
		
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_SHOWERROR, errorParams);
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_VIDEOCOMPLETED, params);
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_HIDESPINNER, spinnerParams);
		
		ApplifierImpactProperties.SELECTED_CAMPAIGN.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
		ApplifierImpactProperties.SELECTED_CAMPAIGN = null;
	}
	
	public void onVideoSkip () {
		Map<String, Object> values = null;
		values = new HashMap<String, Object>();
		values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_BUFFERINGDURATION_KEY, videoplayerview.getBufferingDuration());
		values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VALUE_KEY, ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOABORT_SKIP);
		ApplifierImpactInstrumentation.gaInstrumentationVideoAbort(ApplifierImpactProperties.SELECTED_CAMPAIGN, values);
				
		afterVideoPlaybackOperations();
		JSONObject params = new JSONObject();
		
		try {
			params.put(ApplifierImpactConstants.IMPACT_NATIVEEVENT_CAMPAIGNID_KEY, ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId());
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create JSON", this);
		}
		
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_VIDEOCOMPLETED, params);
		sendActionToListener(ApplifierImpactMainViewAction.VideoSkipped);
	}

	// Almost like onVideoSkip but this is a bit different situation
	// This covers situations where user has e.g. pressed home button and hidden the video instead of pressing skip button
	public void onVideoHidden() {
		Map<String, Object> values = null;
		values = new HashMap<String, Object>();
		values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_BUFFERINGDURATION_KEY, videoplayerview.getBufferingDuration());
		values.put(ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VALUE_KEY, ApplifierImpactConstants.IMPACT_GOOGLE_ANALYTICS_EVENT_VIDEOABORT_HIDDEN);
		ApplifierImpactInstrumentation.gaInstrumentationVideoAbort(ApplifierImpactProperties.SELECTED_CAMPAIGN, values);

		if (videoplayerview != null) {
			videoplayerview.setKeepScreenOn(false);
		}

		removeFromMainView(videoplayerview);
		videoplayerview = null;

		setViewState(ApplifierImpactMainViewState.WebView);
		ApplifierImpactProperties.getCurrentActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);

		JSONObject params = new JSONObject();
		try {
			params.put(ApplifierImpactConstants.IMPACT_NATIVEEVENT_CAMPAIGNID_KEY, ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId());
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create JSON", this);
		}
		webview.sendNativeEventToWebApp(ApplifierImpactConstants.IMPACT_NATIVEEVENT_VIDEOCOMPLETED, params);

		sendActionToListener(ApplifierImpactMainViewAction.VideoSkipped);
	}

	// IApplifierImpactWebViewListener
	@Override
	public void onWebAppLoaded () {
		webview.initWebApp(ApplifierImpact.webdata.getData());
	}
}