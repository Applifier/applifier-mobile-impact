package com.applifier.impact.android.video;

import com.applifier.impact.android.view.IApplifierImpactViewListener;
import com.applifier.impact.android.webapp.ApplifierImpactWebData.ApplifierVideoPosition;

import android.media.MediaPlayer.OnCompletionListener;


public interface IApplifierImpactVideoPlayerListener extends IApplifierImpactViewListener,
		OnCompletionListener {
	
	public void onEventPositionReached (ApplifierVideoPosition position);
}
