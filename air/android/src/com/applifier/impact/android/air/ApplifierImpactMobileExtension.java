package com.applifier.impact.android.air;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.applifier.impact.android.air.functions.ApplifierImpactInitFunction;

public class ApplifierImpactMobileExtension extends FREContext {

	private Map<String, FREFunction> _functions = null;
	
	@Override
	public void dispose() {
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		if (_functions == null) {
			_functions = new HashMap<String, FREFunction>();
			_functions.put("init", new ApplifierImpactInitFunction());
		}
		
		return _functions;
	}

}
