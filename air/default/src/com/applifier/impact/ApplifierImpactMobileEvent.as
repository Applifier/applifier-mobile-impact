package com.applifier.impact
{
	import flash.events.Event;

	public class ApplifierImpactMobileEvent extends Event
	{
		public static const IMPACT_INIT_COMPLETE:String = "impactInitComplete";
		public static const IMPACT_VIDEO_COMPLETED_WITH_REWARD:String = "impactVideoCompletedWithReward";
		public static const IMPACT_WILL_CLOSE:String = "impactWillClose";
		public static const IMPACT_VIDEO_STARTED:String = "impactVideoStarted";
		
		public var data:* = null;
		
		public function ApplifierImpactMobileEvent (eventType:String)
		{
			super(eventType);
		}
	}
}