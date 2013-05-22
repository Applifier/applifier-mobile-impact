package com.applifier.impact.android.view;

import com.applifier.impact.android.data.ApplifierImpactDevice;
import com.applifier.impact.android.data.ApplifierImpactGraphicsBundle;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

public class ApplifierImpactMuteVideoButton extends ImageButton {

	private ApplifierImpactMuteVideoButtonState _state = ApplifierImpactMuteVideoButtonState.UnMuted;
	private ApplifierImpactMuteVideoButtonSize _size = ApplifierImpactMuteVideoButtonSize.Medium;
	
	public static enum ApplifierImpactMuteVideoButtonState { UnMuted, Muted };
	public static enum ApplifierImpactMuteVideoButtonSize { Small, Medium, Large };
	
	public ApplifierImpactMuteVideoButton(Context context) {
		super(context);
		setupView();
	}

	public ApplifierImpactMuteVideoButton(Context context, AttributeSet attrs) {
		super(context, attrs);
		setupView();
	}

	public ApplifierImpactMuteVideoButton(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		setupView();
	}
	
	public void setState (ApplifierImpactMuteVideoButtonState state) {
		if (state != null && !state.equals(_state)) {
			_state = state;
			setImageBitmap(selectBitmap());
		}
	}
	
	private Bitmap selectBitmap () {
		String bitmapString = "";
		if (_size != null && _size.equals(ApplifierImpactMuteVideoButtonSize.Medium)) {
			switch (_state) {
				case UnMuted:
					bitmapString = ApplifierImpactGraphicsBundle.ICON_AUDIO_UNMUTED_50x50;
					if (ApplifierImpactDevice.getScreenDensity() == DisplayMetrics.DENSITY_LOW) {
						bitmapString = ApplifierImpactGraphicsBundle.ICON_AUDIO_UNMUTED_32x32;
					}
					return ApplifierImpactGraphicsBundle.getBitmapFromString(bitmapString);
				case Muted:
					bitmapString = ApplifierImpactGraphicsBundle.ICON_AUDIO_MUTED_50x50;
					if (ApplifierImpactDevice.getScreenDensity() == DisplayMetrics.DENSITY_LOW) {
						bitmapString = ApplifierImpactGraphicsBundle.ICON_AUDIO_MUTED_32x32;
					}

					return ApplifierImpactGraphicsBundle.getBitmapFromString(bitmapString);
			}
		}
		
		return null;
	}
	
	private void setupView () {
		setAdjustViewBounds(true);
		setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT));
		setImageBitmap(selectBitmap());
		setBackgroundResource(0);
		setPadding(0, 0, 0, 0);
	}
}
