package com.applifier.impact.android.video;

import android.media.MediaPlayer.OnCompletionListener;

import com.applifier.impact.android.view.IApplifierImpactViewListener;
import com.applifier.impact.android.webapp.ApplifierImpactWebData.ApplifierVideoPosition;


public interface IApplifierImpactVideoPlayerListener extends IApplifierImpactViewListener,
		OnCompletionListener {
	
	public void onEventPositionReached (ApplifierVideoPosition position);
	public void onVideoPlaybackStarted ();
	public void onVideoPlaybackError ();
	public void onVideoSkip ();
	public void onVideoHidden ();
}
