package com.applifier.impact.android.burstly;

import java.util.Map;

import android.content.Context;
import android.util.Log;

import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.burstly.lib.component.IBurstlyAdaptor;
import com.burstly.lib.feature.networks.IAdaptorFactory;

/**
 * Adaptor for Impact
 * 
 * @author tuomasrinta
 *
 */
public class ImpactAdaptorFactory implements IAdaptorFactory {
	
	static {
		Log.d("burstly_applifier", "Initializing class ImpactAdaptorFactory");
	}

    /**
     * A key for context object being passed in parameters.
     */
    private static final String CONTEXT = "context";
 
    /**
     * A key for current BurstlyView id object being passed in parameters.
     */
    private static final String VIEW_ID = "viewId";

    /**
     * A key for adaptor name being passed in parameters.
     */
    private static final String ADAPTOR_NAME = "adaptorName";
    

	@Override
	public IBurstlyAdaptor createAdaptor(Map<String, ?> params) {
		
		Log.d("burstly_applifier", "Creating adaptor w/ Context:" + params.get(ImpactAdaptorFactory.CONTEXT).getClass().getName());
		
		return new ImpactAdaptor(
				(Context)params.get(ImpactAdaptorFactory.CONTEXT)
			);
		
	}

	@Override
	public void destroy() {}

	@Override
	public void initialize(Map<String, ?> arg0) throws IllegalArgumentException {
		// Since we don't have the Game ID here, we can't init the adaptor yet
	}

	@Override
	public String getAdaptorVersion() {
		return ImpactAdaptor.IMPACT_ADAPTOR_VERSION;
	}

	@Override
	public String getSdkVersion() {
		return ApplifierImpactConstants.IMPACT_VERSION;
	}

}
