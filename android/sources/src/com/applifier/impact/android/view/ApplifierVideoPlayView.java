package com.applifier.impact.android.view;

import java.util.Timer;
import java.util.TimerTask;

import com.applifier.impact.android.ApplifierImpactProperties;

import android.app.Activity;
import android.content.Context;
import android.os.PowerManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.VideoView;

// TODO: Show buffering if possible
// TODO: Show play icon after paused
public class ApplifierVideoPlayView extends RelativeLayout {

	private IApplifierVideoPlayerListener _listener;
	private Timer _videoPausedTimer = null;
	private Activity _currentActivity = null;
	private VideoView _videoView = null;
	
	public ApplifierVideoPlayView(Context context, IApplifierVideoPlayerListener listener, Activity activity) {
		super(context);
		_currentActivity = activity;
		_listener = listener;
		createView();
	}

	public ApplifierVideoPlayView(Context context, AttributeSet attrs) {
		super(context, attrs);
		createView();
	}

	public ApplifierVideoPlayView(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		createView();
	}
	
	public void playVideo (String fileName) {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Playing video from: " + fileName);
		_videoView.setVideoPath(fileName);
		startVideo();
	}
	
	public void setActivity (Activity activity) {
		_currentActivity = activity;
	}
	
	
	/* INTERNAL METHODS */
	
	private void startVideo () {
		if (_currentActivity != null) {
			_currentActivity.runOnUiThread(new Runnable() {			
				@Override
				public void run() {
					_videoView.start();
					setKeepScreenOn(true);
				}
			});
		}
		
		if (_videoPausedTimer == null) {
			_videoPausedTimer = new Timer();
			_videoPausedTimer.scheduleAtFixedRate(new VideoPausedTask(), 500, 500);
		}
	}
	
	private void pauseVideo () {
		purgeVideoPausedTimer();
		
		if (_currentActivity != null) {
			_currentActivity.runOnUiThread(new Runnable() {			
				@Override
				public void run() {
					_videoView.pause();
					setKeepScreenOn(false);
				}
			});
		}
	}
	
	private void purgeVideoPausedTimer () {
		if (_videoPausedTimer != null) {
			_videoPausedTimer.purge();
			_videoPausedTimer = null;
		}
	}

	private void createView () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Creating custom view");
		setBackgroundColor(0xFF000000);
		_videoView = new VideoView(getContext());
		RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT);
		layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
		_videoView.setLayoutParams(layoutParams);		
		addView(_videoView, layoutParams);
		
		_videoView.setClickable(true);
		_videoView.setOnCompletionListener(_listener);
		setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				if (!_videoView.isPlaying()) {
					startVideo();
				}
			}
		});
		setOnFocusChangeListener(new View.OnFocusChangeListener() {			
			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (!hasFocus)
					pauseVideo();
			}
		});
	}
	
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
		switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
				_videoView.stopPlayback();
				setKeepScreenOn(false);
				
				if (_listener != null)
					_listener.onBackButtonClicked(this);
				
		    	return true;
		}
    	
    	return false;
    } 
    
    
    /* INTERNAL CLASSES */
    
	private class VideoPausedTask extends TimerTask {
		@Override
		public void run () {
			PowerManager pm = (PowerManager)getContext().getSystemService(Context.POWER_SERVICE);			
			if (!pm.isScreenOn())
				pauseVideo();
		}
	}
}
