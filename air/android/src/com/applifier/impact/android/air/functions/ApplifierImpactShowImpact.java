package com.applifier.impact.android.air.functions;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactShowImpact implements FREFunction {

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
		
		if (ApplifierImpact.instance != null) {
			Boolean noOfferscreen = false;
			Boolean openAnimated = false;
			Boolean muteVideoSounds = false;
			Boolean useDeviceOrientationForVideo = false;
			String gamerSID = null;
			
			try {
				noOfferscreen = arg1[0].getAsBool();
				openAnimated = arg1[1].getAsBool();
				gamerSID = arg1[2].getAsString();
				muteVideoSounds = arg1[3].getAsBool();
				useDeviceOrientationForVideo = arg1[4].getAsBool();
				
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Some option was not available: " + e.getStackTrace(), this);
			}
			
			Map<String, Object> openOptions = new HashMap<String, Object>();
			openOptions.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_NOOFFERSCREEN_KEY, noOfferscreen);
			openOptions.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_OPENANIMATED_KEY, openAnimated);
			openOptions.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_MUTE_VIDEO_SOUNDS, muteVideoSounds);
			openOptions.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_VIDEO_USES_DEVICE_ORIENTATION, useDeviceOrientationForVideo);
			
			if (gamerSID != null)
				openOptions.put(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY, gamerSID);
			
			Boolean didShow = ApplifierImpact.instance.showImpact(openOptions);
			
			try {
				ret = FREObject.newObject(didShow);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Could not create return value", this);
			}
		}
		
		return ret;
	}
}
