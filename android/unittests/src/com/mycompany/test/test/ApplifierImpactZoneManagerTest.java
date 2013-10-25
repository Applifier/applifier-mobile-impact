package com.mycompany.test.test;

import java.util.Arrays;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONObject;

import com.applifier.impact.android.zone.ApplifierImpactZone;
import com.applifier.impact.android.zone.ApplifierImpactZoneManager;
import com.mycompany.test.ApplifierImpactTestStartActivity;

import android.test.ActivityInstrumentationTestCase2;

public class ApplifierImpactZoneManagerTest extends ActivityInstrumentationTestCase2<ApplifierImpactTestStartActivity> {

	private JSONObject nonIncentivizedZone, incentivizedZone, rewardItem1;
	private ApplifierImpactZoneManager zoneManager;
	
	public ApplifierImpactZoneManagerTest() {
		super(ApplifierImpactTestStartActivity.class);
	}
	
	@Override
	public void setUp() throws Exception {
		super.setUp();
		
		nonIncentivizedZone = new JSONObject(new HashMap<String, Object>(){{
			put("id", "testZoneId1");
			put("name", "testZoneName1");
			put("incentivised", false);
		}});
		
		rewardItem1 = new JSONObject(new HashMap<String, Object>(){{
			put("key", "itemKey1");
			put("name", "itemName1");
			put("picture", "http://www.google.fi");
		}});
		
		incentivizedZone = new JSONObject(new HashMap<String, Object>(){{
			put("id", "testZoneId2");
			put("name", "testZoneName2");
			put("incentivised", true);
			put("defaultRewardItem", rewardItem1);
			put("rewardItems", new JSONArray(Arrays.asList(
				rewardItem1
			)));
		}});
		
		zoneManager = null;
	}
	
	public void testZoneManagerNonIncentivizedZone() {		
		zoneManager = new ApplifierImpactZoneManager(new JSONArray(Arrays.asList(
			nonIncentivizedZone
		)));
		
		assertTrue(zoneManager.zoneCount() == 1);
		
		ApplifierImpactZone currentZone = zoneManager.getCurrentZone();
		
		assertTrue(currentZone != null);
		assertTrue(currentZone.getZoneId().equals("testZoneId1"));
		assertTrue(currentZone.isDefault());
		assertTrue(!currentZone.isIncentivized());
	}
	
	public void testZoneManagerIncentivizedZone() {
		zoneManager = new ApplifierImpactZoneManager(new JSONArray(Arrays.asList(
			incentivizedZone
		)));
		
		assertTrue(zoneManager.zoneCount() == 1);
		
		ApplifierImpactZone currentZone = zoneManager.getCurrentZone();
		
		assertTrue(currentZone != null);
		assertTrue(currentZone.getZoneId().equals("testZoneId2"));
		assertTrue(currentZone.isDefault());
		assertTrue(currentZone.isIncentivized());
	}
	
	public void testZoneManagerMultipleZones() {
		zoneManager = new ApplifierImpactZoneManager(new JSONArray(Arrays.asList(
			nonIncentivizedZone,
			incentivizedZone
		)));
		
		assertTrue(zoneManager.zoneCount() == 2);
		
		ApplifierImpactZone currentZone = zoneManager.getCurrentZone();
		
		assertTrue(currentZone.getZoneId().equals("testZoneId1"));
		assertTrue(zoneManager.getZone("testZoneId2") != null);
	}
	
	public void testZoneManagerDuplicateZones() {
		zoneManager = new ApplifierImpactZoneManager(new JSONArray(Arrays.asList(
			nonIncentivizedZone,
			incentivizedZone,
			incentivizedZone
		)));
		
		assertTrue(zoneManager.zoneCount() == 2);
	}
	
	public void testZoneManagerClearZones() {
		zoneManager = new ApplifierImpactZoneManager(new JSONArray(Arrays.asList(
			nonIncentivizedZone,
			incentivizedZone
		)));
		
		assertTrue(zoneManager.zoneCount() == 2);
		zoneManager.clear();
		assertTrue(zoneManager.zoneCount() == 0);
	}
}
