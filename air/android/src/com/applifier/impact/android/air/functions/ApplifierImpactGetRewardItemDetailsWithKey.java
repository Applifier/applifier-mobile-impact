package com.applifier.impact.android.air.functions;

import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactGetRewardItemDetailsWithKey implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		ApplifierImpactUtils.Log("call", this);
		
		FREObject ret = null;
		String rewardItemKey = "";
		String details = "";
		
		try {
			ret = FREObject.newObject(details);
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
			
			Map<String, String> itemDetails = ApplifierImpact.instance.getRewardItemDetailsWithKey(rewardItemKey);
			
			if (itemDetails != null) {
				details = itemDetails.get(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_NAME_KEY);
				details += ";" + itemDetails.get(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_PICTURE_KEY);
				
				try {
					ret = FREObject.newObject(details);
				}
				catch (Exception e) {
					ApplifierImpactUtils.Log("Could not create return value", this);
				}
			}
		}
		
		return ret;
	}
}
