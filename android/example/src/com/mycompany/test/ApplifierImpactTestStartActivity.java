package com.mycompany.test;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.campaign.IApplifierImpactCampaignListener;
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

public class ApplifierImpactTestStartActivity extends Activity implements IApplifierImpactCampaignListener {
	private ApplifierImpact ai = null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        ((ImageView)findViewById(R.id.playbtn)).setAlpha(80);
		Log.d(ApplifierImpactConstants.LOG_NAME, "Init impact");
		ai = new ApplifierImpact(this, "11006");
		ai.setCampaignListener(this);
		ai.init();
    }
    
    @Override
    public void onResume () {
    	super.onResume();
		ApplifierImpact.instance.changeActivity(this);
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
				finish();
				break;
		}
		
		return true;
	}
	
    @Override
	protected void onDestroy() {
    	ai.stopAll();
    	System.runFinalizersOnExit(true);		
		android.os.Process.killProcess(android.os.Process.myPid());
    	super.onDestroy();		
	}
	
    @Override
	public void onCampaignsAvailable () {
    	((ImageView)findViewById(R.id.playbtn)).setAlpha(255);
    	((ImageView)findViewById(R.id.playbtn)).setOnClickListener(new View.OnClickListener() {			
			@Override
			public void onClick(View v) {
				Intent newIntent = new Intent(getBaseContext(), ApplifierImpactGameActivity.class);
				newIntent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION | Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(newIntent);
			}
		});  
	}
}