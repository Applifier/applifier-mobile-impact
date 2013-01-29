package com.applifier.impact.android.view;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

import android.app.Activity;
import android.os.Bundle;

public class ApplifierImpactFullscreenActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onCreate()", this);
        super.onCreate(savedInstanceState);
		ApplifierImpact.instance.changeActivity(this);
    }
    
    @Override
    public void onResume () {
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onResume()", this);
    	super.onResume();
    }
    
    @Override
	protected void onDestroy() {
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onDestroy()", this);
    	super.onDestroy();		
	}
}
