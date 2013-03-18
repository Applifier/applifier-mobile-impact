package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactGetSDKVersion implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		
		FREObject ret = null;
		
		String sdkVersion = ApplifierImpact.getSDKVersion();
		
		try {
			ret = FREObject.newObject(sdkVersion);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create return value", this);
		}
		
		return ret;
	}
}
