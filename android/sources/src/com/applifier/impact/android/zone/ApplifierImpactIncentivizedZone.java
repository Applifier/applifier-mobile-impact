package com.applifier.impact.android.zone;

import org.json.JSONException;
import org.json.JSONObject;

import com.applifier.impact.android.item.ApplifierImpactRewardItem;
import com.applifier.impact.android.item.ApplifierImpactRewardItemManager;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

public class ApplifierImpactIncentivizedZone extends ApplifierImpactZone {

	private ApplifierImpactRewardItemManager _rewardItems = null;
	
	public ApplifierImpactIncentivizedZone(JSONObject zoneObject) throws JSONException {
		super(zoneObject);
		ApplifierImpactRewardItem defaultItem = new ApplifierImpactRewardItem(zoneObject.getJSONObject(ApplifierImpactConstants.IMPACT_ZONE_DEFAULT_REWARD_ITEM_KEY));
		_rewardItems = new ApplifierImpactRewardItemManager(zoneObject.getJSONArray(ApplifierImpactConstants.IMPACT_ZONE_REWARD_ITEMS_KEY), defaultItem.getKey());
	}
	
	@Override
	public boolean isIncentivized() {
		return true;
	}
	
	public ApplifierImpactRewardItemManager itemManager() {
		return _rewardItems;
	}

}
