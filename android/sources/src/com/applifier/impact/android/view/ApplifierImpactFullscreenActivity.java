package com.applifier.impact.android.view;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactFullscreenActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onCreate()", this);
    	
    	if (ApplifierImpact.instance != null)
    		ApplifierImpact.instance.changeActivity(this);
    	else
        	ApplifierImpactUtils.Log("onCreate() Impact instance is NULL!", this);
    }
    
    @Override
    public void onResume () {
    	super.onResume();
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onResume()", this);
    	
    	if (ApplifierImpact.instance != null)
    		ApplifierImpact.instance.changeActivity(this);
    	else
        	ApplifierImpactUtils.Log("onResume() Impact instance is NULL!", this);
    }
    
    @Override
	protected void onDestroy() {
    	super.onDestroy();		
    	ApplifierImpactUtils.Log("ApplifierImpactFullscreenActivity->onDestroy()", this);
	}
    
	@Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
    	return false;
    }
}
