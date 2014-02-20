package com.mycompany.test.test;

import java.util.HashMap;

import org.json.JSONObject;

import com.applifier.impact.android.item.ApplifierImpactRewardItem;
import com.mycompany.test.ApplifierImpactTestStartActivity;

import android.test.ActivityInstrumentationTestCase2;

public class ApplifierImpactRewardItemTest extends ActivityInstrumentationTestCase2<ApplifierImpactTestStartActivity> {

	private JSONObject validItem, invalidItem;
	private ApplifierImpactRewardItem rewardItem;
	
	public ApplifierImpactRewardItemTest() {
		super(ApplifierImpactTestStartActivity.class);
	}
	
	@Override
	@SuppressWarnings("serial")
	public void setUp() throws Exception {
		super.setUp();
		
		validItem = new JSONObject(new HashMap<String, Object>(){{
			put("key", "testItemKey1");
			put("name", "testItemName1");
			put("picture", "http://www.google.fi");
		}});
		
		invalidItem = new JSONObject(new HashMap<String, Object>(){{
			put("key", "testItemKey2");
			put("picture", "http://www.google.fi");
		}});
		
		rewardItem = null;
	}
	
	public void testValidItem() {
		rewardItem = new ApplifierImpactRewardItem(validItem);
		assertTrue(rewardItem.getKey().equals("testItemKey1"));
		assertTrue(rewardItem.getName().equals("testItemName1"));
		assertTrue(rewardItem.getPictureUrl().equals("http://www.google.fi"));
	}
	
	public void testInvalidItem() {
		rewardItem = new ApplifierImpactRewardItem(invalidItem);
		assertTrue(!rewardItem.hasValidData());
	}
	
}
