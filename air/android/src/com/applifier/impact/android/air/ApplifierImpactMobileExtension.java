package com.applifier.impact.android.air;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.applifier.impact.android.air.functions.ApplifierImpactCanShowCampaigns;
import com.applifier.impact.android.air.functions.ApplifierImpactCanShowImpact;
import com.applifier.impact.android.air.functions.ApplifierImpactGetSDKVersion;
import com.applifier.impact.android.air.functions.ApplifierImpactHasMultipleRewards;
import com.applifier.impact.android.air.functions.ApplifierImpactHideImpact;
import com.applifier.impact.android.air.functions.ApplifierImpactInit;
import com.applifier.impact.android.air.functions.ApplifierImpactIsDebugMode;
import com.applifier.impact.android.air.functions.ApplifierImpactIsSupported;
import com.applifier.impact.android.air.functions.ApplifierImpactSetDebugMode;
import com.applifier.impact.android.air.functions.ApplifierImpactSetTestMode;
import com.applifier.impact.android.air.functions.ApplifierImpactShowImpact;
import com.applifier.impact.android.air.functions.ApplifierImpactStopAll;

public class ApplifierImpactMobileExtension extends FREContext {

	private Map<String, FREFunction> _functions = null;
	
	@Override
	public void dispose() {
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		if (_functions == null) {
			_functions = new HashMap<String, FREFunction>();
			
			_functions.put("init", new ApplifierImpactInit());
			_functions.put("isSupported", new ApplifierImpactIsSupported());
			_functions.put("getSDKVersion", new ApplifierImpactGetSDKVersion());
			_functions.put("setDebugMode", new ApplifierImpactSetDebugMode());
			_functions.put("isDebugMode", new ApplifierImpactIsDebugMode());
			_functions.put("setTestMode", new ApplifierImpactSetTestMode());
			_functions.put("canShowCampaigns", new ApplifierImpactCanShowCampaigns());
			_functions.put("canShowImpact", new ApplifierImpactCanShowImpact());
			_functions.put("stopAll", new ApplifierImpactStopAll());
			_functions.put("hasMultipleRewardItems", new ApplifierImpactHasMultipleRewards());
			_functions.put("showImpact", new ApplifierImpactShowImpact());
			_functions.put("hideImpact", new ApplifierImpactHideImpact());
			
			/*

			public function init (gameId:String) : void {
			public function isSupported () : Boolean {
			public function getSDKVersion () : String {
			public function setDebugMode (debugMode:Boolean) : void {
			public function isDebugMode () : Boolean {
			public function setTestMode (testMode:Boolean) : void {
			public function canShowCampaigns () : Boolean {
			public function canShowImpact () : Boolean {
			public function stopAll () : void {
			public function hasMultipleRewardItems () : Boolean {
			public function showImpact () : Boolean {
			public function hideImpact () : Boolean {
			
			- (BOOL)hasMultipleRewardItems;
			- (NSArray *)getRewardItemKeys;
			- (NSString *)getDefaultRewardItemKey;
			- (NSString *)getCurrentRewardItemKey;
			- (BOOL)setRewardItemKey:(NSString *)rewardItemKey;
			- (void)setDefaultRewardItemAsRewardItem;
			- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey;

			 */
			
		}
		
		return _functions;
	}
}
