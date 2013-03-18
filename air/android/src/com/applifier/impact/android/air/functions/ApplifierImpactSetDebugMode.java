package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactSetDebugMode implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		Boolean debugMode = false;
		
		try {
			debugMode = arg1[0].getAsBool();
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not get debugMode", this);
		}
		
		ApplifierImpact.setDebugMode(debugMode);
		ApplifierImpactUtils.Log("call", this);
		
		return null;
	}
}
