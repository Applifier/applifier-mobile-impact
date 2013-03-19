package com.applifier.impact.android.air.functions;

import java.util.ArrayList;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactGetRewardItemKeys implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		
		FREObject ret = null;
		String rewardItemKeys = "";
		
		if (ApplifierImpact.instance != null && ApplifierImpact.instance.hasMultipleRewardItems()) {
			ArrayList<String> keys = ApplifierImpact.instance.getRewardItemKeys();
			
			if (keys != null) {
				for (int i = 0; i < keys.size(); i++) {
					rewardItemKeys += keys.get(i);
					
					if (i + 1 < keys.size())
						rewardItemKeys += ";";
				}
			}
		}
		
		try {
			ret = FREObject.newObject(rewardItemKeys);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not create return value", this);
		}
		
		return ret;
	}
}
