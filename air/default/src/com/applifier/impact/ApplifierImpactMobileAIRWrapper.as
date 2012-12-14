package com.applifier.impact
{
	import flash.events.EventDispatcher;
	
	public class ApplifierImpactMobileAIRWrapper extends EventDispatcher
	{
		public function ApplifierImpactMobileAIRWrapper ()
		{
		}
		
		
		/* Interface */
		public function init (gameId:String) : void 
		{
		}
		
		public function showImpact () : Boolean 
		{
			return false;
		}
		
		public function hideImpact () : Boolean
		{
			return false;
		}
		
		public function isSupported () : Boolean
		{
			return false;
		}
		
		public function canShowImpact () : Boolean
		{
			return false;
		}
		
		public function trackInstall () : void
		{
		}
		
		public function stopAll () : void
		{
		}
		
		public function setTestMode (mode:Boolean) : void
		{
		}
	}
}