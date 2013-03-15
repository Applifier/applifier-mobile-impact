package com.applifier.impact
{
	import flash.events.EventDispatcher;
	
	public class ApplifierImpactMobileAIRWrapper extends EventDispatcher
	{
		public function ApplifierImpactMobileAIRWrapper ()
		{
		}
		
		/* Interface */
		
		public function init (gameId:String) : void {
		}
		
		public function isSupported () : Boolean {
			return false;
		}
		
		public function getSDKVersion () : String {
			return "0";
		}
		
		public function setDebugMode (debugMode:Boolean) : void {
		}
		
		public function isDebugMode () : Boolean {
			return true;
		}
		
		public function setTestMode (testMode:Boolean) : void {
		}
		
		public function canShowCampaigns () : Boolean {
			return false;
		}
		
		public function canShowImpact () : Boolean {
			return false;
		}
		
		public function stopAll () : void {
		}
		
		public function hasMultipleRewardItems () : Boolean {
			return false;
		}
		
		/*
		- (BOOL)hasMultipleRewardItems;
		- (NSArray *)getRewardItemKeys;
		- (NSString *)getDefaultRewardItemKey;
		- (NSString *)getCurrentRewardItemKey;
		- (BOOL)setRewardItemKey:(NSString *)rewardItemKey;
		- (void)setDefaultRewardItemAsRewardItem;
		- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey;
		*/
		
		public function showImpact () : Boolean {
			return false;
		}
		
		public function hideImpact () : Boolean {
			return false;
		}
	}
}