package com.applifier.impact.android.air;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.applifier.impact.android.air.functions.ApplifierImpactCanShowCampaigns;
import com.applifier.impact.android.air.functions.ApplifierImpactCanShowImpact;
import com.applifier.impact.android.air.functions.ApplifierImpactGetCurrentRewardItemKey;
import com.applifier.impact.android.air.functions.ApplifierImpactGetDefaultRewardItemKey;
import com.applifier.impact.android.air.functions.ApplifierImpactGetRewardItemDetailsWithKey;
import com.applifier.impact.android.air.functions.ApplifierImpactGetRewardItemKeys;
import com.applifier.impact.android.air.functions.ApplifierImpactGetRewardItemNameKey;
import com.applifier.impact.android.air.functions.ApplifierImpactGetRewardItemPictureKey;
import com.applifier.impact.android.air.functions.ApplifierImpactGetSDKVersion;
import com.applifier.impact.android.air.functions.ApplifierImpactHasMultipleRewards;
import com.applifier.impact.android.air.functions.ApplifierImpactHideImpact;
import com.applifier.impact.android.air.functions.ApplifierImpactInit;
import com.applifier.impact.android.air.functions.ApplifierImpactIsDebugMode;
import com.applifier.impact.android.air.functions.ApplifierImpactIsSupported;
import com.applifier.impact.android.air.functions.ApplifierImpactSetDebugMode;
import com.applifier.impact.android.air.functions.ApplifierImpactSetDefaultRewardItemAsRewardItem;
import com.applifier.impact.android.air.functions.ApplifierImpactSetRewardItemKey;
import com.applifier.impact.android.air.functions.ApplifierImpactSetTestMode;
import com.applifier.impact.android.air.functions.ApplifierImpactShowImpact;
import com.applifier.impact.android.air.functions.ApplifierImpactStopAll;

public class ApplifierImpactMobileExtension extends FREContext {

	private Map<String, FREFunction> _functions = null;
	
	@Override
	public void dispose() {
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		if (_functions == null) {
			_functions = new HashMap<String, FREFunction>();
			
			_functions.put("init", new ApplifierImpactInit());
			_functions.put("isSupported", new ApplifierImpactIsSupported());
			_functions.put("getSDKVersion", new ApplifierImpactGetSDKVersion());
			_functions.put("setDebugMode", new ApplifierImpactSetDebugMode());
			_functions.put("isDebugMode", new ApplifierImpactIsDebugMode());
			_functions.put("setTestMode", new ApplifierImpactSetTestMode());
			_functions.put("canShowCampaigns", new ApplifierImpactCanShowCampaigns());
			_functions.put("canShowImpact", new ApplifierImpactCanShowImpact());
			_functions.put("stopAll", new ApplifierImpactStopAll());
			_functions.put("showImpact", new ApplifierImpactShowImpact());
			_functions.put("hideImpact", new ApplifierImpactHideImpact());
			
			// Multiple rewards
			_functions.put("hasMultipleRewardItems", new ApplifierImpactHasMultipleRewards());
			_functions.put("getRewardItemKeys", new ApplifierImpactGetRewardItemKeys());
			_functions.put("getDefaultRewardItemKey", new ApplifierImpactGetDefaultRewardItemKey());
			_functions.put("getCurrentRewardItemKey", new ApplifierImpactGetCurrentRewardItemKey());
			_functions.put("setRewardItemKey", new ApplifierImpactSetRewardItemKey());
			_functions.put("setDefaultRewardItemAsRewardItem", new ApplifierImpactSetDefaultRewardItemAsRewardItem());
			_functions.put("getRewardItemDetailsWithKey", new ApplifierImpactGetRewardItemDetailsWithKey());
			_functions.put("getRewardItemNameKey", new ApplifierImpactGetRewardItemNameKey());
			_functions.put("getRewardItemPictureKey", new ApplifierImpactGetRewardItemPictureKey());
		}
		
		return _functions;
	}
}
