package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.air.ApplifierImpactMobileAIRWrapper;

public class ApplifierImpactInit implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		String gameId = null;
		
		try {
			gameId = arg1[0].getAsString();
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Error while getting gameId", this);
		}
		
		new ApplifierImpact(arg0.getActivity(), gameId, ApplifierImpactMobileAIRWrapper.instance);
		ApplifierImpactUtils.Log("call", this);
		return null;
	}
}
