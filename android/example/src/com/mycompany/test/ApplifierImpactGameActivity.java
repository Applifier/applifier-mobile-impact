package com.mycompany.test;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.IApplifierImpactListener;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import com.applifier.impact.android.video.IApplifierImpactVideoListener;

public class ApplifierImpactGameActivity extends Activity implements IApplifierImpactListener, IApplifierImpactVideoListener {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.game);
        
        ((ImageView)findViewById(R.id.plissken)).setAlpha(60);
        ((ImageView)findViewById(R.id.unlock)).setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				ApplifierImpact.instance.showImpact();
			}
		});
        
        ApplifierImpact.instance.setImpactListener(this);
    }
    
    @Override
    public void onResume () {
    	super.onResume();
		ApplifierImpact.instance.changeActivity(this);
		ApplifierImpact.instance.setImpactListener(this);
		ApplifierImpact.instance.setVideoListener(this);
		
		if (!ApplifierImpact.instance.hasCampaigns()) {
			((ImageView)findViewById(R.id.unlock)).setVisibility(View.INVISIBLE);
		}
    }
    
    public void onImpactClose () {
    	Log.d(ApplifierImpactProperties.LOG_NAME, "HOST: Impact close");
    }
    
    public void onImpactOpen () {   	
    	Log.d(ApplifierImpactProperties.LOG_NAME, "HOST: Impact open");
    }
    
	public void onVideoStarted () {
		Log.d(ApplifierImpactProperties.LOG_NAME, "HOST: Video started!");
	}
	
	public void onVideoCompleted () {
    	((ImageView)findViewById(R.id.plissken)).setAlpha(255);
    	((ImageView)findViewById(R.id.unlock)).setVisibility(View.INVISIBLE);
    	Log.d(ApplifierImpactProperties.LOG_NAME, "HOST: Video completed!");
	}
}
