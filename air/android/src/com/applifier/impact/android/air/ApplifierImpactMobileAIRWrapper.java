package com.applifier.impact.android.air;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class ApplifierImpactMobileAIRWrapper implements FREExtension {

	@Override
	public FREContext createContext(String arg0) {
		return new ApplifierImpactMobileExtension();
	}

	@Override
	public void dispose() {
	}

	@Override
	public void initialize() {
	}
}
