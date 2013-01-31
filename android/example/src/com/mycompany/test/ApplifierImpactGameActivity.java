package com.mycompany.test;

import java.util.HashMap;
import java.util.Map;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.IApplifierImpactListener;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactGameActivity extends Activity implements IApplifierImpactListener {
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactGameActivity->onCreate()");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.game);
        
        ((ImageView)findViewById(R.id.plissken)).setAlpha(60);
        ((ImageView)findViewById(R.id.unlock)).setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				ApplifierImpactUtils.Log("Opened with key: " + ApplifierImpact.instance.getCurrentRewardItemKey(), this);
				
				// Open with options test
				Map<String, Boolean> optionsMap = new HashMap<String, Boolean>();
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, false);
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY, false);
				ApplifierImpact.instance.showImpact(optionsMap);
				
				// Open without options (defaults)
				//ApplifierImpact.instance.showImpact();
			}
		});
        
        ApplifierImpact.instance.setImpactListener(this);
    }
    
    @Override
    public void onResume () {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactGameActivity->onResume()");
    	super.onResume();
    	
    	ApplifierImpact.instance.changeActivity(this);
		ApplifierImpact.instance.setImpactListener(this);
		
		if (!ApplifierImpact.instance.canShowCampaigns()) {
			((ImageView)findViewById(R.id.unlock)).setVisibility(View.INVISIBLE);
		}
    }
    
    public void onImpactClose () {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "HOST: Impact close");
    }
    
    public void onImpactOpen () {   	
    	Log.d(ApplifierImpactConstants.LOG_NAME, "HOST: Impact open");
    }
    
	public void onVideoStarted () {
		Log.d(ApplifierImpactConstants.LOG_NAME, "HOST: Video started!");
	}
	
	public void onVideoCompleted () {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactGameActivity->onVideoCompleted()");
    	((ImageView)findViewById(R.id.plissken)).setAlpha(255);
    	((ImageView)findViewById(R.id.unlock)).setVisibility(View.INVISIBLE);
    	Log.d(ApplifierImpactConstants.LOG_NAME, "HOST: Video completed!");
	}
	
    @Override
	public void onCampaignsAvailable () {
	}
    
    @Override
    public void onCampaignsFetchFailed () {
    }
}
