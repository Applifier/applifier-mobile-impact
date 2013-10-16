package com.applifier.impact.android.item;

import java.util.ArrayList;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpactUtils;

public class ApplifierImpactRewardItemManager {

	private Map<String, ApplifierImpactRewardItem> _rewardItems = null;
	private ApplifierImpactRewardItem _currentItem = null;
	private ApplifierImpactRewardItem _defaultItem = null;
	
	public ApplifierImpactRewardItemManager(JSONArray rewardItemArray, String defaultItem) {
		for(int i = 0; i < rewardItemArray.length(); ++i) {
			try {
				JSONObject rewardItemObject = rewardItemArray.getJSONObject(i);
				ApplifierImpactRewardItem rewardItem = new ApplifierImpactRewardItem(rewardItemObject);
				
				if(rewardItem.getKey().equals(defaultItem)) {
					_currentItem = rewardItem;
					_defaultItem = rewardItem;
				}
				
				_rewardItems.put(rewardItem.getKey(), rewardItem);
			} catch(JSONException e) {
				ApplifierImpactUtils.Log("Failed to parse reward item", this);
			}
		}
	}
	
	public ApplifierImpactRewardItem getItem(String rewardItemKey) {
		if(_rewardItems.containsKey(rewardItemKey)) {
			return _rewardItems.get(rewardItemKey);
		}
		return null;
	}
	
	public ApplifierImpactRewardItem getCurrentItem() {
		return _currentItem;
	}
	
	public ApplifierImpactRewardItem getDefaultItem() {
		return _defaultItem;
	}
	
	public boolean setCurrentItem(String rewardItemKey) {
		if(_rewardItems.containsKey(rewardItemKey)) {
			_currentItem = _rewardItems.get(rewardItemKey);
			return true;
		}
		return false;
	}
	
	public ArrayList<ApplifierImpactRewardItem> allItems() {
		ArrayList<ApplifierImpactRewardItem> itemArray = new ArrayList<ApplifierImpactRewardItem>();
		for(ApplifierImpactRewardItem rewardItem : _rewardItems.values()) {
			itemArray.add(rewardItem);
		}
		return itemArray;
	}
	
	public int itemCount() {
		return _rewardItems.size();
	}
	
}
