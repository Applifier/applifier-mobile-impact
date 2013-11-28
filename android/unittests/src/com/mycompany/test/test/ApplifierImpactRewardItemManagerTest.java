package com.mycompany.test.test;

import java.util.Arrays;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONObject;

import com.applifier.impact.android.item.ApplifierImpactRewardItem;
import com.applifier.impact.android.item.ApplifierImpactRewardItemManager;
import com.mycompany.test.ApplifierImpactTestStartActivity;

import android.test.ActivityInstrumentationTestCase2;

public class ApplifierImpactRewardItemManagerTest extends ActivityInstrumentationTestCase2<ApplifierImpactTestStartActivity> {

	private JSONObject rewardItem1, rewardItem2;
	private ApplifierImpactRewardItemManager itemManager;
	
	public ApplifierImpactRewardItemManagerTest() {
		super(ApplifierImpactTestStartActivity.class);
	}
	
	@Override
	@SuppressWarnings("serial")
	public void setUp() throws Exception {
		super.setUp();
		
		rewardItem1 = new JSONObject(new HashMap<String, Object>(){{
			put("key", "testItemKey1");
			put("name", "testItemName1");
			put("picture", "http://www.google.fi");
		}});
		
		rewardItem2 = new JSONObject(new HashMap<String, Object>(){{
			put("key", "testItemKey2");
			put("name", "testItemName2");
			put("picture", "http://www.google.fi");
		}});
		
		itemManager = null;
	}
	
	public void testEmptyItems() {
		itemManager = new ApplifierImpactRewardItemManager(new JSONArray(), "defaultItem");
		assertTrue(itemManager.itemCount() == 0);
	}
	
	public void testSingleItem() {
		itemManager = new ApplifierImpactRewardItemManager(new JSONArray(Arrays.asList(rewardItem1)), "testItemKey1");
		assertTrue(itemManager.itemCount() == 1);
		
		ApplifierImpactRewardItem defaultItem = itemManager.getDefaultItem();
		ApplifierImpactRewardItem currentItem = itemManager.getCurrentItem();
		
		assertNotNull(defaultItem);
		assertNotNull(currentItem);
		
		assertTrue(defaultItem.getKey().equals("testItemKey1"));
		assertTrue(currentItem.getKey().equals("testItemKey1"));
	}
	
	public void testMultipleItems() {
		itemManager = new ApplifierImpactRewardItemManager(new JSONArray(Arrays.asList(
			rewardItem1,
			rewardItem2
		)), "testItemKey2");
		
		assertTrue(itemManager.itemCount() == 2);
		
		ApplifierImpactRewardItem defaultItem = itemManager.getDefaultItem();
		ApplifierImpactRewardItem currentItem = itemManager.getCurrentItem();
		
		assertNotNull(defaultItem);
		assertNotNull(currentItem);
		
		assertTrue(defaultItem.getKey().equals("testItemKey2"));
		assertTrue(currentItem.getKey().equals("testItemKey2"));
	}
	
	public void testMultipleItemSwitching() {
		itemManager = new ApplifierImpactRewardItemManager(new JSONArray(Arrays.asList(
			rewardItem1,
			rewardItem2
		)), "testItemKey2");
		
		assertTrue(itemManager.itemCount() == 2);
		
		itemManager.setCurrentItem("testItemKey1");
		
		ApplifierImpactRewardItem defaultItem = itemManager.getDefaultItem();
		ApplifierImpactRewardItem currentItem = itemManager.getCurrentItem();
		
		assertNotNull(defaultItem);
		assertNotNull(currentItem);
		
		assertTrue(defaultItem.getKey().equals("testItemKey2"));
		assertTrue(currentItem.getKey().equals("testItemKey1"));
	}
	
	public void testMissingDefaultItem() {
		itemManager = new ApplifierImpactRewardItemManager(new JSONArray(Arrays.asList(
			rewardItem1,
			rewardItem2
		)), "testItemKey3");
		
		assertTrue(itemManager.itemCount() == 2);
		assertNull(itemManager.getDefaultItem());
		assertNull(itemManager.getCurrentItem());
	}
	
}
