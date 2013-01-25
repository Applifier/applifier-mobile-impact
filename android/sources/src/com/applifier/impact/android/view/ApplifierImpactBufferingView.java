package com.applifier.impact.android.view;

import com.applifier.impact.android.ApplifierImpactUtils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.util.AttributeSet;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class ApplifierImpactBufferingView extends LinearLayout {

	private TextView _textView = null;
	private ImageView _ball1 = null;
	private ImageView _ball2 = null;
	private ImageView _ball3 = null;
	
	public ApplifierImpactBufferingView(Context context) {
		super(context);
		createView();
	}

	public ApplifierImpactBufferingView(Context context, AttributeSet attrs) {
		super(context, attrs);
		createView();
	}

	private void createView () {
		setOrientation(LinearLayout.HORIZONTAL);
		setPadding(10, 8, 10, 10);
		
		_textView = new TextView(getContext());
		_textView.setTextColor(0xFFFFFFFF);
		_textView.setText("Buffering");
		_textView.setId(10000);
		addView(_textView, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
	
		ShapeDrawable bgShape = new ShapeDrawable(new RoundRectShape(new float[] {12,12, 12,12, 12,12, 12,12}, null, null));
		bgShape.getPaint().setColor(0x88000000);
		bgShape.getPaint().setStyle(Style.FILL);
		setBackgroundDrawable(bgShape);
		
		LinearLayout balls = new LinearLayout(getContext());
		balls.setOrientation(LinearLayout.HORIZONTAL);

		LinearLayout.LayoutParams singleBall = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		singleBall.leftMargin = 3;
		
		_ball1 = createBall(10001);
		_ball2 = createBall(10002);
		_ball3 = createBall(10003);
		
		balls.addView(_ball1, singleBall);
		balls.addView(_ball2, singleBall);
		balls.addView(_ball3, singleBall);
		
		LinearLayout.LayoutParams ballsLp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		ballsLp.setMargins(3, 9, 0, 0);
		addView(balls, ballsLp);
	}
	
	private AnimationSet createBlinkAnimation (long offset) {
		AnimationSet animSet = new AnimationSet(false);
		
		Animation scaleAnimation = new ScaleAnimation(1, 0, 1, 0, 8, 8);
		scaleAnimation.setRepeatCount(Animation.INFINITE);
		scaleAnimation.setRepeatMode(Animation.REVERSE);
		scaleAnimation.setFillBefore(true);
		scaleAnimation.setFillAfter(true);
		scaleAnimation.setDuration(800);
		
		Animation alphaAnimation = new AlphaAnimation(1, 0);
		alphaAnimation.setRepeatCount(Animation.INFINITE);
		alphaAnimation.setRepeatMode(Animation.REVERSE);
		alphaAnimation.setFillBefore(true);
		alphaAnimation.setFillAfter(true);
		alphaAnimation.setDuration(800);
		
		animSet.addAnimation(scaleAnimation);
		animSet.addAnimation(alphaAnimation);
		
		return animSet;
	}
	
	private ImageView createBall (int id) {		
		Bitmap bmp = Bitmap.createBitmap(17, 17, Bitmap.Config.ARGB_4444);
		Canvas cnv = new Canvas(bmp);
		Paint pnt = new Paint(Paint.ANTI_ALIAS_FLAG);
		pnt.setColor(Color.WHITE);
		cnv.drawCircle(8, 8, 8, pnt);
		ImageView img = new ImageView(getContext());
		img.setImageBitmap(bmp);
		img.setId(id);
		return img;
	}

	@Override
	protected void onAttachedToWindow() {
		super.onAttachedToWindow();
		ApplifierImpactUtils.Log("Attached to window", this);
		
		if (_ball1 != null)
			_ball1.setAnimation(createBlinkAnimation(0));
		if (_ball2 != null)			
			_ball2.setAnimation(createBlinkAnimation(150));
		if (_ball3 != null)
			_ball3.setAnimation(createBlinkAnimation(300));
	}
	
	@Override
	protected void onDetachedFromWindow () {
		super.onDetachedFromWindow();
		
		if (_ball1 != null)
			_ball1.clearAnimation();
		if (_ball2 != null)			
			_ball2.clearAnimation();
		if (_ball3 != null)
			_ball3.clearAnimation();
	}
}