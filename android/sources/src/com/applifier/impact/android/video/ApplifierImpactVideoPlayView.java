package com.applifier.impact.android.video;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;
import com.applifier.impact.android.view.ApplifierImpactBufferingView;
import com.applifier.impact.android.webapp.ApplifierImpactWebData.ApplifierVideoPosition;

import android.content.Context;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.PowerManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.VideoView;

public class ApplifierImpactVideoPlayView extends RelativeLayout {

	private IApplifierImpactVideoPlayerListener _listener;
	private Timer _videoPausedTimer = null;
	private VideoView _videoView = null;
	private String _videoFileName = null;
	private ApplifierImpactBufferingView _bufferingView = null;
	private ApplifierImpactVideoPausedView _pausedView = null;
	private boolean _videoPlayheadPrepared = false;
	private Map<ApplifierVideoPosition, Boolean> _sentPositionEvents = new HashMap<ApplifierVideoPosition, Boolean>();
	private RelativeLayout _countDownText = null;
	private TextView _timeLeftInSecondsText = null;
	
	public ApplifierImpactVideoPlayView(Context context, IApplifierImpactVideoPlayerListener listener) {
		super(context);
		_listener = listener;
		createView();
	}

	public ApplifierImpactVideoPlayView(Context context, AttributeSet attrs) {
		super(context, attrs);
		createView();
	}

	public ApplifierImpactVideoPlayView(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		createView();
	}
	
	public void playVideo (String fileName) {
		if (fileName == null) return;
		
		_videoPlayheadPrepared = false;
		_videoFileName = fileName;
		Log.d(ApplifierImpactConstants.LOG_NAME, "Playing video from: " + _videoFileName);
		_videoView.setVideoPath(_videoFileName);
		_timeLeftInSecondsText.setText("" + Math.round(Math.ceil(_videoView.getDuration() / 1000)));
		startVideo();
	}

	public void pauseVideo () {
		purgeVideoPausedTimer();
		
		if (ApplifierImpactProperties.CURRENT_ACTIVITY != null && _videoView != null && _videoView.isPlaying()) {
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {			
				@Override
				public void run() {
					_videoView.pause();
					setKeepScreenOn(false);
					createAndAddPausedView();
				}
			});
		}		
	}
	
	
	/* INTERNAL METHODS */
	
	private void startVideo () {
		if (ApplifierImpactProperties.CURRENT_ACTIVITY != null) {
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {			
				@Override
				public void run() {
					_videoView.start();
					if (!_sentPositionEvents.containsKey(ApplifierVideoPosition.Start)) {
						_listener.onEventPositionReached(ApplifierVideoPosition.Start);
						_sentPositionEvents.put(ApplifierVideoPosition.Start, true);
					}
					setKeepScreenOn(true);
				}
			});
		}
		
		if (_videoPausedTimer == null) {
			_videoPausedTimer = new Timer();
			_videoPausedTimer.scheduleAtFixedRate(new VideoStateChecker(), 300, 300);
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
		Log.d(ApplifierImpactConstants.LOG_NAME, "Creating custom view");
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
		
		_countDownText = new RelativeLayout(getContext());
		RelativeLayout.LayoutParams countDownParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		countDownParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		countDownParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		countDownParams.bottomMargin = 3;
		countDownParams.rightMargin = 3;
		_countDownText.setLayoutParams(countDownParams);
		
		TextView tv = new TextView(getContext());
		tv.setTextColor(Color.WHITE);
		tv.setText("This video ends in ");
		tv.setId(10001);
		
		_timeLeftInSecondsText = new TextView(getContext());
		_timeLeftInSecondsText.setTextColor(Color.WHITE);
		_timeLeftInSecondsText.setText("00");
		_timeLeftInSecondsText.setId(10002);
		RelativeLayout.LayoutParams tv2params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		tv2params.addRule(RelativeLayout.RIGHT_OF, 10001);
		tv2params.leftMargin = 1;
		_timeLeftInSecondsText.setLayoutParams(tv2params);
		
		TextView tv3 = new TextView(getContext());
		tv3.setTextColor(Color.WHITE);
		tv3.setText("seconds.");
		RelativeLayout.LayoutParams tv3params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		tv3params.addRule(RelativeLayout.RIGHT_OF, 10002);
		tv3params.leftMargin = 4;
		tv3.setLayoutParams(tv3params);
		
		_countDownText.addView(tv);
		_countDownText.addView(_timeLeftInSecondsText);
		_countDownText.addView(tv3);
		
		addView(_countDownText);
		
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
		private Float _curPos = 0f;
		
		@Override
		public void run () {
			PowerManager pm = (PowerManager)getContext().getSystemService(Context.POWER_SERVICE);			
			if (!pm.isScreenOn()) {
				pauseVideo();
			}
			
			_curPos = new Float(_videoView.getCurrentPosition());
			Float position = _curPos / _videoView.getDuration();
			
			ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {				
				@Override
				public void run() {
					_timeLeftInSecondsText.setText("" + Math.round(Math.ceil((_videoView.getDuration() - _curPos) / 1000)));
				}
			});
			
			if (position > 0.25 && !_sentPositionEvents.containsKey(ApplifierVideoPosition.FirstQuartile)) {
				_listener.onEventPositionReached(ApplifierVideoPosition.FirstQuartile);
				_sentPositionEvents.put(ApplifierVideoPosition.FirstQuartile, true);
			}
			if (position > 0.5 && !_sentPositionEvents.containsKey(ApplifierVideoPosition.MidPoint)) {
				_listener.onEventPositionReached(ApplifierVideoPosition.MidPoint);
				_sentPositionEvents.put(ApplifierVideoPosition.MidPoint, true);
			}
			if (position > 0.75 && !_sentPositionEvents.containsKey(ApplifierVideoPosition.ThirdQuartile)) {
				_listener.onEventPositionReached(ApplifierVideoPosition.ThirdQuartile);
				_sentPositionEvents.put(ApplifierVideoPosition.ThirdQuartile, true);
			}
			
			if (ApplifierImpactProperties.CURRENT_ACTIVITY != null && _videoView != null && _videoView.getBufferPercentage() < 15 && _videoView.getParent() == null) {				
				ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {					
					@Override
					public void run() {
						createAndAddBufferingView();
					}
				});				
			}
			else if (ApplifierImpactProperties.CURRENT_ACTIVITY != null && _videoPlayheadPrepared && _bufferingView != null && _bufferingView.getParent() != null) {
				ApplifierImpactProperties.CURRENT_ACTIVITY.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						hideBufferingView();
					}
				});
			}
		}
	}
}
