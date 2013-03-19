package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactSetRewardItemKey implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		
		FREObject ret = null;
		Boolean retBool = false;
		String rewardItemKey = "";
		
		try {
			ret = FREObject.newObject(false);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create default return value", this);
		}
		
		if (arg1 != null && ApplifierImpact.instance != null) {
			try {
				rewardItemKey = arg1[0].getAsString();
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not get reward item to set", this);
			}
			
			retBool = ApplifierImpact.instance.setRewardItemKey(rewardItemKey);
			
			try {
				ret = FREObject.newObject(retBool);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not create return value", this);
			}
		}
		
		return ret;
	}
}
