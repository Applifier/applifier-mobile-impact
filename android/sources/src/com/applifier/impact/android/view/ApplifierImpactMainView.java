package com.applifier.impact.android.view;

import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.campaign.ApplifierImpactCampaign.ApplifierImpactCampaignStatus;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;
import com.applifier.impact.android.video.ApplifierImpactVideoPlayView;
import com.applifier.impact.android.video.IApplifierImpactVideoPlayerListener;
import com.applifier.impact.android.webapp.ApplifierImpactWebBridge;
import com.applifier.impact.android.webapp.ApplifierImpactWebView;
import com.applifier.impact.android.webapp.IApplifierImpactWebViewListener;
import com.applifier.impact.android.webapp.ApplifierImpactWebData.ApplifierVideoPosition;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.media.MediaPlayer;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

public class ApplifierImpactMainView extends RelativeLayout implements 	IApplifierImpactWebViewListener, 
																		IApplifierImpactVideoPlayerListener {

	public static enum ApplifierImpactMainViewState { WebView, VideoPlayer };
	public static enum ApplifierImpactMainViewAction { VideoStart, VideoEnd, BackButtonPressed };
	
	// Views
	public ApplifierImpactVideoPlayView videoplayerview = null;
	public ApplifierImpactWebView webview = null;

	// Listener
	private IApplifierImpactMainViewListener _listener = null;
	

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
		if (ApplifierImpactProperties.CURRENT_ACTIVITY != null && ApplifierImpactProperties.CURRENT_ACTIVITY.getClass().getName().equals(ApplifierImpactConstants.IMPACT_FULLSCREEN_ACTIVITY_CLASSNAME)) {
			webview.setWebViewCurrentView(view, data);
						
			if (this.getParent() == null)
				ApplifierImpactProperties.CURRENT_ACTIVITY.addContentView(this, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
			
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
		webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_START, data);
	}
	
	public void setViewState (ApplifierImpactMainViewState state) {
		switch (state) {
			case WebView:
				if (webview == null)
					createWebView();
				
				if (webview.getParent() == null)
					addView(webview, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
				else
					bringChildToFront(webview);
				
				focusToView(webview);
				break;
			case VideoPlayer:
				if (videoplayerview == null)
					createVideoPlayerView();
				
				if (videoplayerview.getParent() == null) {
					videoplayerview.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.FILL_PARENT, FrameLayout.LayoutParams.FILL_PARENT));
					addView(videoplayerview, ((ViewGroup)this).getChildCount());
				}
				
				if (webview != null)
					bringChildToFront(webview);
				
				break;
		}
	}
	
	
	/* PRIVATE METHODS */
	
	private void init () {
		createWebView();
	}
	
	private void destroyVideoPlayerView () {
		removeFromMainView(videoplayerview);
		videoplayerview = null;
	}
	
	private void createVideoPlayerView () {
		videoplayerview = new ApplifierImpactVideoPlayView(ApplifierImpactProperties.CURRENT_ACTIVITY.getBaseContext(), this);
	}
	
	private void createWebView () {
		webview = new ApplifierImpactWebView(ApplifierImpactProperties.CURRENT_ACTIVITY, this, new ApplifierImpactWebBridge(ApplifierImpact.instance));
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
		sendActionToListener(ApplifierImpactMainViewAction.BackButtonPressed);
	}
	
	// IApplifierImpactVideoPlayerListener
	@Override
	public void onVideoPlaybackStarted () {
		ApplifierImpactUtils.Log("onVideoPlaybackStarted", this);
		
		JSONObject params = null;
		
		try {
			params = new JSONObject("{\"campaignId\":\"" + ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignId() + "\"}");
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create JSON", this);
		}
		
		sendActionToListener(ApplifierImpactMainViewAction.VideoStart);
		bringChildToFront(videoplayerview);
		removeFromMainView(webview);
		focusToView(videoplayerview);
		webview.setWebViewCurrentView(ApplifierImpactConstants.IMPACT_WEBVIEW_VIEWTYPE_COMPLETED, params);
	}
	
	@Override
	public void onEventPositionReached (ApplifierVideoPosition position) {
		if (ApplifierImpactProperties.SELECTED_CAMPAIGN != null && !ApplifierImpactProperties.SELECTED_CAMPAIGN.getCampaignStatus().equals(ApplifierImpactCampaignStatus.VIEWED))
			ApplifierImpact.webdata.sendCampaignViewProgress(ApplifierImpactProperties.SELECTED_CAMPAIGN, position);
	}
	
	@Override
	public void onCompletion(MediaPlayer mp) {				
		videoplayerview.setKeepScreenOn(false);
		setViewState(ApplifierImpactMainViewState.WebView);
		onEventPositionReached(ApplifierVideoPosition.End);
		ApplifierImpactProperties.CURRENT_ACTIVITY.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
		ApplifierImpactProperties.SELECTED_CAMPAIGN.setCampaignStatus(ApplifierImpactCampaignStatus.VIEWED);
		ApplifierImpactProperties.SELECTED_CAMPAIGN = null;
		destroyVideoPlayerView();
		sendActionToListener(ApplifierImpactMainViewAction.VideoEnd);
	}
	
	// IApplifierImpactWebViewListener
	@Override
	public void onWebAppLoaded () {
		webview.initWebApp(ApplifierImpact.webdata.getData());
	}
}