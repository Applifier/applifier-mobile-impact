package com.applifier.impact.android.view;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class ApplifierImpactFullscreenActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactFullscreenActivity->onCreate()");
        super.onCreate(savedInstanceState);
		ApplifierImpact.instance.changeActivity(this);
    }
    
    @Override
    public void onResume () {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactFullscreenActivity->onResume()");
    	super.onResume();
    }
    
    @Override
	protected void onDestroy() {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactFullscreenActivity->onDestroy()");
    	super.onDestroy();		
	}
}
