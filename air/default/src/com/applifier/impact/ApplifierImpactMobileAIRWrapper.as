package com.applifier.impact
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
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
		
		public function showImpact (noOfferscreen:Boolean = false, openAnimated:Boolean = false, gamerSID:String = null, muteVideoSounds:Boolean = false, useDeviceOrientationForVideo:Boolean = false) : Boolean {
			return false;
		}
		
		public function hideImpact () : Boolean {
			return false;
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

		
		/* MULTIPLE REWARDS */
		
		public function getRewardItemKeys () : Array {
			return new Array();
		}
		
		public function getDefaultRewardItemKey () : String {
			return "";	
		}
		
		public function getCurrentRewardItemKey () : String {
			return "";
		}
		
		public function setRewardItemKey (rewardItemKey:String) : Boolean {
			return false;
		}
		
		public function setDefaultRewardItemAsRewardItem () : void {
		}
		
		public function getRewardItemDetailsWithKey (rewardItemKey:String) : Dictionary {
			return new Dictionary();
		}
		
		public function getRewardItemNameKey () : String {
			return "name";
		}
		
		public function getRewardItemPictureKey () : String {
			return "picture";
		}
	}
}