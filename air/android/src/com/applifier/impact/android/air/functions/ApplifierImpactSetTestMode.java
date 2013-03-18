package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactSetTestMode implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		Boolean testMode = false;
		
		try {
			testMode = arg1[0].getAsBool();
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not get testMode", this);
		}
		
		ApplifierImpact.setTestMode(testMode);
		ApplifierImpactUtils.Log("call", this);
		
		return null;
	}
}
