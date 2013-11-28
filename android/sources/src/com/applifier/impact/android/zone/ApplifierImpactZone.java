package com.applifier.impact.android.zone;

import java.util.ArrayList;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactZone {

	private JSONObject _initialOptions = null;
	private JSONObject _options = null;
	
	private String _zoneId = null;
	private String _zoneName = null;
	private boolean _default = false;
	private String _gamerSid = null;
	
	private ArrayList<String> _allowClientOverrides = new ArrayList<String>();
	
	public ApplifierImpactZone(JSONObject zoneObject) throws JSONException {
		_initialOptions = new JSONObject(zoneObject.toString());
		_options = zoneObject;
		_zoneId = zoneObject.getString(ApplifierImpactConstants.IMPACT_ZONE_ID_KEY);
		_zoneName = zoneObject.getString(ApplifierImpactConstants.IMPACT_ZONE_NAME_KEY);
		_default = zoneObject.optBoolean(ApplifierImpactConstants.IMPACT_ZONE_DEFAULT_KEY, true);
		
		JSONArray allowClientOverrides = zoneObject.optJSONArray(ApplifierImpactConstants.IMPACT_ZONE_ALLOW_CLIENT_OVERRIDES_KEY);
		if(allowClientOverrides != null) {
			for(int i = 0; i < allowClientOverrides.length(); ++i) {
				_allowClientOverrides.add(allowClientOverrides.getString(i));
			}
		}			
	}
	
	public String getZoneId() {
		return _zoneId;
	}
	
	public String getZoneName() {
		return _zoneName;
	}
	
	public JSONObject getZoneOptions() {
		return _options;
	}
	
	public boolean isDefault() {
		return _default;
	}
	
	public boolean isIncentivized() {
		return false;
	}
	
	public boolean muteVideoSounds() {
		return _options.optBoolean(ApplifierImpactConstants.IMPACT_ZONE_MUTE_VIDEO_SOUNDS_KEY, false);
	}
	
	public boolean noOfferScreen() {
		return _options.optBoolean(ApplifierImpactConstants.IMPACT_ZONE_NO_OFFER_SCREEN_KEY, true);
	}
	
	public boolean openAnimated() {
		return _options.optBoolean(ApplifierImpactConstants.IMPACT_ZONE_OPEN_ANIMATED_KEY, false);
	}
	
	public boolean useDeviceOrientationForVideo() {
		return _options.optBoolean(ApplifierImpactConstants.IMPACT_ZONE_USE_DEVICE_ORIENTATION_FOR_VIDEO_KEY, false);
	}
	
	public long allowVideoSkipInSeconds() {
		return _options.optLong(ApplifierImpactConstants.IMPACT_ZONE_ALLOW_VIDEO_SKIP_IN_SECONDS_KEY, 0);
	}
	
	public long disableBackButtonForSeconds() {
		return _options.optLong(ApplifierImpactConstants.IMPACT_ZONE_DISABLE_BACK_BUTTON_FOR_SECONDS, 0);
	}
	
	public String getGamerSid() {
		return _gamerSid;
	}
	
	public void setGamerSid(String gamerSid) {
		_gamerSid = gamerSid;
	}
	
	public void mergeOptions(Map<String, Object> options) {
		try {
			_options = new JSONObject(_initialOptions.toString());	
			_gamerSid = null;
		} catch(JSONException e) {}				
		for(Map.Entry<String, Object> option : options.entrySet()) {
			if(allowsOverride(option.getKey())) {
				try {
					_options.put(option.getKey(), option.getValue());
				} catch(JSONException e) {
					ApplifierImpactUtils.Log("Unable to set JSON value", this);
				}
			}
		}
		if(options.containsKey(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY)) {
			setGamerSid((String)options.get(ApplifierImpact.APPLIFIER_IMPACT_OPTION_GAMERSID_KEY));
		}
	}
	
	public boolean allowsOverride(String option) {
		return _allowClientOverrides.contains(option);
	}
}
