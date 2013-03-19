package com.applifier.impact.android.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactSetDefaultRewardItemAsRewardItem implements
		FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		
		if (ApplifierImpact.instance != null) {
			ApplifierImpact.instance.setDefaultRewardItemAsRewardItem();
		}
		
		return null;
	}
}
