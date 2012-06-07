package com.applifier.impact.android.view;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;

import android.content.Context;
import android.media.MediaPlayer;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.FrameLayout;
import android.widget.VideoView;

import com.applifier.impact.android.R;

public class ApplifierVideoPlayView extends FrameLayout {

	private MediaPlayer.OnCompletionListener _listener;
	
	public ApplifierVideoPlayView(Context context, MediaPlayer.OnCompletionListener listener) {
		super(context);
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
	
	public void playVideo () {
		((VideoView)findViewById(R.id.videoplayer)).start();
	}

	private void createView () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Creating custom view");
		setBackgroundColor(0xBA000000);
		inflate(getContext(), R.layout.applifier_showvideo, this);
		((VideoView)findViewById(R.id.videoplayer)).setVideoPath(ApplifierImpactUtils.getCacheDirectory() + "/video5.mp4");
		((VideoView)findViewById(R.id.videoplayer)).setOnCompletionListener(_listener);
	}
	
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
		switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
		    	((VideoView)findViewById(R.id.videoplayer)).stopPlayback();
		    	ApplifierImpact.instance.closeImpactView(this, true);
		    	return true;
		}
    	
    	return false;
    }  
}
