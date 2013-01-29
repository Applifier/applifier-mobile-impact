package com.applifier.impact.android.view;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

import android.app.Activity;
import android.os.Bundle;

public class ApplifierImpactFullscreenActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onCreate()", this);
		ApplifierImpact.instance.changeActivity(this);
    }
    
    @Override
    public void onResume () {
    	super.onResume();
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onResume()", this);
		ApplifierImpact.instance.changeActivity(this);
    }
    
    @Override
	protected void onDestroy() {
    	super.onDestroy();		
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onDestroy()", this);
	}
}
