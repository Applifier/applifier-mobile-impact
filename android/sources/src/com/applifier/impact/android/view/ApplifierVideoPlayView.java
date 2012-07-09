package com.applifier.impact.android.view;

import java.util.Timer;
import java.util.TimerTask;

import com.applifier.impact.android.ApplifierImpactProperties;

import android.app.Activity;
import android.content.Context;
import android.media.MediaPlayer;
import android.os.PowerManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.VideoView;

// TODO: Show play icon after paused
public class ApplifierVideoPlayView extends RelativeLayout {

	private IApplifierVideoPlayerListener _listener;
	private Timer _videoPausedTimer = null;
	private Activity _currentActivity = null;
	private VideoView _videoView = null;
	private String _videoFileName = null;
	private ApplifierImpactBufferingView _bufferingView = null;
	private ApplifierImpactVideoPausedView _pausedView = null;
	private boolean _videoPlayheadPrepared = false;
	
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
		if (fileName == null) return;
		
		_videoPlayheadPrepared = false;
		_videoFileName = fileName;
		Log.d(ApplifierImpactProperties.LOG_NAME, "Playing video from: " + _videoFileName);
		_videoView.setVideoPath(_videoFileName);
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
			_videoPausedTimer.scheduleAtFixedRate(new VideoStateChecker(), 300, 300);
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
					createAndAddPausedView();
				}
			});
		}		
	}
	
	private void purgeVideoPausedTimer () {
		if (_videoPausedTimer != null) {
			_videoPausedTimer.cancel();
			_videoPausedTimer.purge();
			_videoPausedTimer = null;
		}
	}

	private void createView () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Creating custom view");
		setBackgroundColor(0xFF000000);
		_videoView = new VideoView(getContext());
		RelativeLayout.LayoutParams videoLayoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT);
		videoLayoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
		_videoView.setLayoutParams(videoLayoutParams);		
		addView(_videoView, videoLayoutParams);
		_videoView.setClickable(true);
		_videoView.setOnCompletionListener(_listener);
		_videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {			
			@Override
			public void onPrepared(MediaPlayer mp) {
				_videoPlayheadPrepared = true;
				hideBufferingView();
			}
		});
		
		setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				if (!_videoView.isPlaying()) {
					hideVideoPausedView();
					startVideo();
				}
			}
		});
		setOnFocusChangeListener(new View.OnFocusChangeListener() {			
			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (!hasFocus) {
					pauseVideo();
				}
			}
		});
	}
	
	private void createAndAddPausedView () {
		if (_pausedView == null)
			_pausedView = new ApplifierImpactVideoPausedView(getContext());
				
		if (_pausedView != null && _pausedView.getParent() == null) {
			RelativeLayout.LayoutParams pausedViewParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT);
			pausedViewParams.addRule(RelativeLayout.CENTER_IN_PARENT);
			addView(_pausedView, pausedViewParams);		
		}
	}
	
	private void createAndAddBufferingView () {
		if (_bufferingView == null) {
    		_bufferingView = new ApplifierImpactBufferingView(getContext());
    	}
    	
    	if (_bufferingView != null && _bufferingView.getParent() == null) {
    		RelativeLayout.LayoutParams bufferingLayoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
    		bufferingLayoutParams.addRule(RelativeLayout.CENTER_IN_PARENT);
    		addView(_bufferingView, bufferingLayoutParams);
    	}  		
	}
	
	private void hideBufferingView () {
		if (_bufferingView != null && _bufferingView.getParent() != null)
			removeView(_bufferingView);
	}
	
	private void hideVideoPausedView () {
		if (_pausedView != null && _pausedView.getParent() != null)
			removeView(_pausedView);
	}
	
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
		switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
				purgeVideoPausedTimer();
				_videoView.stopPlayback();
				setKeepScreenOn(false);
				hideBufferingView();
				hideVideoPausedView();
				
				if (_listener != null)
					_listener.onBackButtonClicked(this);
				
		    	return true;
		}
    	
    	return false;
    } 
    
    @Override
    protected void onAttachedToWindow() {
    	super.onAttachedToWindow();    	
  		createAndAddBufferingView();
  		hideVideoPausedView();
    }
    
    /* INTERNAL CLASSES */
    
	private class VideoStateChecker extends TimerTask {
		@Override
		public void run () {
			PowerManager pm = (PowerManager)getContext().getSystemService(Context.POWER_SERVICE);			
			if (!pm.isScreenOn()) {
				pauseVideo();
			}
			
			if (_currentActivity != null && _videoView != null && _videoView.getBufferPercentage() < 15 && _videoView.getParent() == null) {				
				_currentActivity.runOnUiThread(new Runnable() {					
					@Override
					public void run() {
						createAndAddBufferingView();
					}
				});				
			}
			else if (_currentActivity != null && _videoPlayheadPrepared && _bufferingView != null && _bufferingView.getParent() != null) {
				_currentActivity.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						hideBufferingView();
					}
				});
			}
		}
	}
}
