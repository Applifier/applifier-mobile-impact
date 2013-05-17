
package com.mycompany.test;

import java.util.HashMap;
import java.util.Map;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.IApplifierImpactListener;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

import com.mycompany.test.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;

public class ApplifierImpactTestStartActivity extends Activity implements IApplifierImpactListener {
	private ApplifierImpact ai = null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactTestStartActivity->onCreate()");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        //((ImageView)findViewById(R.id.playbtn)).setAlpha(80);
		Log.d(ApplifierImpactConstants.LOG_NAME, "Init impact");
		ApplifierImpact.setDebugMode(true);
		ApplifierImpact.setTestMode(true);
		
		ai = new ApplifierImpact(this, "16", this);
    }
    
    @Override
    public void onResume () {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactTestStartActivity->onResume()");
    	super.onResume();
		ApplifierImpact.instance.changeActivity(this);
		ApplifierImpact.instance.setImpactListener(this);
    }
    
	@Override
	public boolean onCreateOptionsMenu (Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.layout.menu, menu);
		return true;
	}
	
	@Override
	public boolean onOptionsItemSelected (MenuItem item) {
		switch (item.getItemId()) {
			case R.id.kill:
		    	ai.stopAll();
		    	System.runFinalizersOnExit(true);		
				finish();
		    	Log.d(ApplifierImpactConstants.LOG_NAME, "Quitting");

		    	break;
		}
		
		return true;
	}
	
    @Override
	protected void onDestroy() {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactTestStartActivity->onDestroy()");
    	super.onDestroy();		
	}
	
    @Override
	public void onImpactClose () {
    	
    }
    
    @Override
	public void onImpactOpen () {
    	
    }
	
	// Impact video events
    @Override
	public void onVideoStarted () {
    	
    }
    
    @Override
	public void onVideoCompleted (String rewardItemKey) {
    }
	
	// Impact campaign events
    @Override
	public void onCampaignsAvailable () {
    	Log.d(ApplifierImpactConstants.LOG_NAME, "ApplifierImpactTestStartActivity->onCampaignsAvailable()");
    	/*
    	((ImageView)findViewById(R.id.playbtn)).setAlpha(255);
    	((ImageView)findViewById(R.id.playbtn)).setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				Intent newIntent = new Intent(getBaseContext(), ApplifierImpactGameActivity.class);
				newIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(newIntent);
			}
		});*/  
	}
    
    @Override
    public void onCampaignsFetchFailed () {
    }
    
    
    
    
    
    
    
    
    /*
       ((ImageView)findViewById(R.id.plissken)).setAlpha(60);
        ((ImageView)findViewById(R.id.unlock)).setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				ApplifierImpactUtils.Log("Opening with key: " + ApplifierImpact.instance.getCurrentRewardItemKey(), this);
				
				// Open with options test
				Map<String, Object> optionsMap = new HashMap<String, Object>();
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, false);
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY, false);
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY, "gom");
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS, false);
				optionsMap.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION, false);
				
				ApplifierImpact.instance.showImpact(optionsMap);
				
				// Open without options (defaults)
				//ApplifierImpact.instance.showImpact();
			}
		});
        
        ApplifierImpact.instance.setImpactListener(this);
        
        */
    
    
    /*
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
	
	public void onVideoCompleted (String rewardItemKey) {
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
    */
}