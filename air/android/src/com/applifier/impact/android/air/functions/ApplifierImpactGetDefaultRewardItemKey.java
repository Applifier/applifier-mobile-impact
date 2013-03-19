package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactGetDefaultRewardItemKey implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		
		FREObject ret = null;
		
		String defaultRewardItemKey = "";
		
		if (ApplifierImpact.instance != null) {
			defaultRewardItemKey = ApplifierImpact.instance.getDefaultRewardItemKey();
		}

		try {
			ret = FREObject.newObject(defaultRewardItemKey);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create return value", this);
		}

		return ret;
	}
}
