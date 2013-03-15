package com.applifier.impact
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class ApplifierImpactMobileAIRWrapper extends EventDispatcher
	{
		private var _extensionContext:ExtensionContext;
		
		public function ApplifierImpactMobileAIRWrapper ()
		{
			super();
			_extensionContext = ExtensionContext.createExtensionContext("com.applifier.impact", null);
			_extensionContext.addEventListener(StatusEvent.STATUS, onStatus);
			
			if (!_extensionContext) {
				throw new Error("ApplifierImpactMobile AIR not supported on this platform!");
			}			
		}
		
		
		/* Interface */
		
		
		public function init (gameId:String) : void {
			if (!canUseExtensionContext()) return;			
			_extensionContext.call("init", gameId);
		}
		
		public function isSupported () : Boolean {
			if (!canUseExtensionContext()) return false;
			return _extensionContext.call("isSupported") as Boolean;
		}
		
		public function getSDKVersion () : String {
			if (!canUseExtensionContext()) return "0";
			return _extensionContext.call("getSDKVersion") as String;
		}
		
		public function setDebugMode (debugMode:Boolean) : void {
			if (!canUseExtensionContext()) return;
			_extensionContext.call("setDebugMode", debugMode);
		}
		
		public function isDebugMode () : Boolean {
			if (!canUseExtensionContext()) return true;
			return _extensionContext.call("isDebugMode") as Boolean;
		}
		
		public function setTestMode (testMode:Boolean) : void {
			if (!canUseExtensionContext()) return;
			_extensionContext.call("setTestMode", testMode);
		}
		
		public function canShowCampaigns () : Boolean {
			if (!canUseExtensionContext()) return false;
			return _extensionContext.call("canShowCampaigns") as Boolean;
		}
		
		public function canShowImpact () : Boolean {
			if (!canUseExtensionContext()) return false;
			return _extensionContext.call("canShowImpact") as Boolean;
		}
		
		public function stopAll () : void {
			if (!canUseExtensionContext()) return;
			_extensionContext.call("stopAll");
		}
		
		public function hasMultipleRewardItems () : Boolean {
			if (!canUseExtensionContext()) return false;
			return _extensionContext.call("hasMultipleRewardItems") as Boolean;
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
			if (!canUseExtensionContext()) return false;
			return _extensionContext.call("showImpact") as Boolean;
		}
		
		public function hideImpact () : Boolean {
			if (!canUseExtensionContext()) return false;
			return _extensionContext.call("hideImpact") as Boolean;
		}
		
		/* Private funtions */
		private function canUseExtensionContext () : Boolean
		{
			return _extensionContext != null;
		}
		
		/* Event listener */
		private function onStatus (event:StatusEvent) : void
		{
			var newEvent:ApplifierImpactMobileEvent = null;
			
			if (event.code != null) 
			{
				switch (event.code) 
				{
					case ApplifierImpactMobileEvent.IMPACT_INIT_COMPLETE:
						dispatchEvent(new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_INIT_COMPLETE));
						break;
					case ApplifierImpactMobileEvent.IMPACT_INIT_FAILED:
						newEvent = new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_INIT_FAILED);
						newEvent.data = event.level;
						dispatchEvent(newEvent);
						break;
					case ApplifierImpactMobileEvent.IMPACT_VIDEO_STARTED:
						dispatchEvent(new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_VIDEO_STARTED));
						break;
					case ApplifierImpactMobileEvent.IMPACT_VIDEO_COMPLETED_WITH_REWARD:
						newEvent = new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_VIDEO_COMPLETED_WITH_REWARD);
						newEvent.data = event.level;
						dispatchEvent(newEvent);
						break;					
					case ApplifierImpactMobileEvent.IMPACT_WILL_CLOSE:
						dispatchEvent(new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_WILL_CLOSE));
						break;
					case ApplifierImpactMobileEvent.IMPACT_DID_CLOSE:
						dispatchEvent(new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_DID_CLOSE));
						break;					
					case ApplifierImpactMobileEvent.IMPACT_WILL_OPEN:
						dispatchEvent(new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_WILL_OPEN));
						break;
					case ApplifierImpactMobileEvent.IMPACT_DID_OPEN:
						dispatchEvent(new ApplifierImpactMobileEvent(ApplifierImpactMobileEvent.IMPACT_DID_OPEN));
						break;
				}
			}
		}
	}
}