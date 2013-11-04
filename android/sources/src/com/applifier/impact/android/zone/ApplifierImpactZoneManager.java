package com.applifier.impact.android.zone;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactZoneManager {

	private Map<String, ApplifierImpactZone> _zones = null; 
	private ApplifierImpactZone _currentZone = null;
	
	public ApplifierImpactZoneManager(JSONArray zoneArray) {
		_zones = new HashMap<String, ApplifierImpactZone>();
		
		for(int i = 0; i < zoneArray.length(); ++i) {
			try {
				JSONObject jsonZone = zoneArray.getJSONObject(i);
				ApplifierImpactZone zone = null;
				if(jsonZone.getBoolean(ApplifierImpactConstants.IMPACT_ZONE_INCENTIVIZED_KEY)) {
					zone = new ApplifierImpactIncentivizedZone(jsonZone);
				} else {
					zone = new ApplifierImpactZone(jsonZone);
				}
				
				if(_currentZone == null && zone.isDefault()) {
					_currentZone = zone;
				}
				
				_zones.put(zone.getZoneId(), zone);
			} catch(JSONException e) {
				ApplifierImpactUtils.Log("Failed to parse zone", this);
			}
		} 
	}
	
	public ApplifierImpactZone getZone(String zoneId) {
		if(_zones.containsKey(zoneId)) {
			return _zones.get(zoneId);
		}
		return null;
	}
	
	public ApplifierImpactZone getCurrentZone() {
		return _currentZone;
	}
	
	public boolean setCurrentZone(String zoneId) {
		if(_zones.containsKey(zoneId)) {
			_currentZone = _zones.get(zoneId);
			return true;
		} else {
			_currentZone = null;
		}
		return false;
	}
	
	public int zoneCount() {
		return _zones != null ? _zones.size() : 0;
	}
	
	public JSONArray getZonesJson() {
		JSONArray zonesArray = new JSONArray();
		for(ApplifierImpactZone zone : _zones.values()) {
			zonesArray.put(zone.getZoneOptions());
		}
		return zonesArray;
	}
	
	public void clear() {
		_currentZone = null;
		_zones.clear();
		_zones = null;
	}
	
}
