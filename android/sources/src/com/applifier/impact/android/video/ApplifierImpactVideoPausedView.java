package com.applifier.impact.android.video;

import com.applifier.impact.android.properties.ApplifierImpactProperties;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Canvas.VertexMode;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class ApplifierImpactVideoPausedView extends RelativeLayout {
	private ImageView _playButtonBase = null;
	private ImageView _outerStroke = null;
	private ImageView _triangle = null;
	private TextView _textView = null;
	
	public ApplifierImpactVideoPausedView(Context context) {
		super(context);
		createView();
	}

	public ApplifierImpactVideoPausedView(Context context, AttributeSet attrs) {
		super(context, attrs);
		createView();
	}

	public ApplifierImpactVideoPausedView(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		createView();
	}
	
	private void createView () {
		DisplayMetrics metrics = ApplifierImpactProperties.getCurrentActivity().getResources().getDisplayMetrics();
		setBackgroundColor(0xC0000000);
		
		RelativeLayout.LayoutParams strokeParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		strokeParams.addRule(RelativeLayout.CENTER_IN_PARENT);
		_outerStroke = createOuterStroke(60006);		
		addView(_outerStroke, strokeParams);
		
		RelativeLayout.LayoutParams ballParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		ballParams.addRule(RelativeLayout.CENTER_IN_PARENT);
		_playButtonBase = createBall(60001);
		addView(_playButtonBase, ballParams);
		
		
		RelativeLayout.LayoutParams arrowParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		arrowParams.addRule(RelativeLayout.CENTER_VERTICAL);
		arrowParams.addRule(RelativeLayout.ALIGN_LEFT, 60001);
		arrowParams.leftMargin = Math.round(31 * metrics.density);
		_triangle = createTriangle(60002);
		addView(_triangle, arrowParams);
		
		_textView = new TextView(getContext());
		_textView.setTextColor(0xFFFFFFFF);
		_textView.setText("Video paused. Tap screen to continue watching.");
		_textView.setId(60003);
		RelativeLayout.LayoutParams textViewParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
		textViewParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
		textViewParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		textViewParams.bottomMargin = Math.round(20 * metrics.density);
		addView(_textView, textViewParams);
	}
	
	private ImageView createOuterStroke (int id) {
		DisplayMetrics metrics = ApplifierImpactProperties.getCurrentActivity().getResources().getDisplayMetrics();
		Bitmap bmp = Bitmap.createBitmap(Math.round(113 * metrics.density), Math.round(113 * metrics.density), Bitmap.Config.ARGB_4444);
		Canvas cnv = new Canvas(bmp);
		Paint pnt = new Paint(Paint.ANTI_ALIAS_FLAG);
		pnt.setColor(0xFFFFFFFF);
		pnt.setStyle(Style.STROKE);
		pnt.setStrokeWidth(5);
		cnv.drawCircle(Math.round(56 * metrics.density), Math.round(56 * metrics.density), Math.round(53 * metrics.density), pnt);
		ImageView img = new ImageView(getContext());
		img.setImageBitmap(bmp);
		img.setId(id);
		return img;
	}
	
	private ImageView createBall (int id) {
		DisplayMetrics metrics = ApplifierImpactProperties.getCurrentActivity().getResources().getDisplayMetrics();
		Bitmap bmp = Bitmap.createBitmap(Math.round(101 * metrics.density), Math.round(101 * metrics.density), Bitmap.Config.ARGB_4444);
		Canvas cnv = new Canvas(bmp);
		Paint pnt = new Paint(Paint.ANTI_ALIAS_FLAG);
		pnt.setColor(0x90000000);
		cnv.drawCircle(Math.round(50 * metrics.density), Math.round(50 * metrics.density), Math.round(50 * metrics.density), pnt);
		ImageView img = new ImageView(getContext());
		img.setImageBitmap(bmp);
		img.setId(id);
		return img;
	}
	
	private ImageView createTriangle (int id) {
		DisplayMetrics metrics = ApplifierImpactProperties.getCurrentActivity().getResources().getDisplayMetrics();
		Bitmap bmp = Bitmap.createBitmap(Math.round(47 * metrics.density), Math.round(51 * metrics.density), Bitmap.Config.ARGB_4444);
		Canvas cnv = new Canvas(bmp);
		Paint pnt = new Paint(Paint.ANTI_ALIAS_FLAG);
		pnt.setColor(Color.WHITE);
		pnt.setStyle(Paint.Style.FILL);
		
		float[] points = new float[8];
		points[0] = 0f;
		points[1] = 0f;
		
		points[2] = 47f * metrics.density;
		points[3] = 25f * metrics.density;

		points[4] = 0f;
		points[5] = 51f * metrics.density;

		points[6] = 0f;
		points[7] = 0f;

		cnv.drawVertices(VertexMode.TRIANGLES, 8, points, 0, null, 0, null, 0, null, 0, 0, pnt);
				
		Path path = new Path();
	    path.moveTo(points[0], points[1]);
	    path.lineTo(points[2], points[3]);
	    path.lineTo(points[4], points[5]);
	    cnv.drawPath(path, pnt);
		
		ImageView img = new ImageView(getContext());
		img.setImageBitmap(bmp);
		img.setId(id);
	    
		return img;
	}
	
	private AnimationSet createBlinkAnimation (long offset) {
		AnimationSet animSet = new AnimationSet(false);
		
		Animation alphaAnimation = new AlphaAnimation(1, 0);
		alphaAnimation.setRepeatCount(Animation.INFINITE);
		alphaAnimation.setRepeatMode(Animation.REVERSE);
		alphaAnimation.setFillBefore(true);
		alphaAnimation.setFillAfter(true);
		alphaAnimation.setDuration(800);
		
		animSet.addAnimation(alphaAnimation);
		
		return animSet;
	}
	
	@Override
	protected void onAttachedToWindow() {
		super.onAttachedToWindow();
		
		if (_outerStroke != null)
			_outerStroke.setAnimation(createBlinkAnimation(0));
	}
	
	@Override
	protected void onDetachedFromWindow () {
		super.onDetachedFromWindow();
		
		if (_outerStroke != null)
			_outerStroke.clearAnimation();
	}
}
