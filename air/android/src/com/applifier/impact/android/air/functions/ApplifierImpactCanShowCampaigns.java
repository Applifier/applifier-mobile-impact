package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactCanShowCampaigns implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		FREObject ret = null;
		
		try {
			ret = FREObject.newObject(false);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create return value", this);
		}
		
		if (ApplifierImpact.instance != null) {
			Boolean canShowCampaigns = ApplifierImpact.instance.canShowCampaigns();
			try {
				ret = FREObject.newObject(canShowCampaigns);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not create return value", this);
			}
		}
		
		return ret;
	}
}
