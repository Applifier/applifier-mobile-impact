package com.applifier.impact.android.view;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.applifier.impact.android.R;

public class ApplifierVideoSelectView extends FrameLayout {

	public ApplifierVideoSelectView(Context context) {
		super(context);
		createView();
	}

	public ApplifierVideoSelectView(Context context, AttributeSet attrs) {
		super(context, attrs);
		createView();
	}

	public ApplifierVideoSelectView(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		createView();
	}

	private void createView () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "Creating custom view");
		setBackgroundColor(0xBA000000);
		inflate(getContext(), R.layout.applifier_selectvideo, this);
		
        ((ImageView)findViewById(R.id.closeb)).setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
		    	onKeyDown(KeyEvent.KEYCODE_BACK, null);
			}
		});
	}
	
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
		switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
		    	ApplifierImpact.instance.closeImpactView(this, true);
		    	return true;
		}
    	
		return false;
    }  
}
