package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.properties.ApplifierImpactProperties;

public class ApplifierImpactIsDebugMode implements FREFunction {

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
		
		Boolean isDebugMode = ApplifierImpactProperties.IMPACT_DEBUG_MODE;
		try {
			ret = FREObject.newObject(isDebugMode);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create return value", this);
		}
		
		return ret;
	}
}
