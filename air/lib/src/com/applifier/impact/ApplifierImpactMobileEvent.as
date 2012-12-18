package com.applifier.impact
{
	import flash.events.Event;

	public class ApplifierImpactMobileEvent extends Event
	{
		public static const IMPACT_INIT_COMPLETE:String = "impactInitComplete";
		public static const IMPACT_INIT_FAILED:String = "impactInitFailed";

		public static const IMPACT_WILL_OPEN:String = "impactWillOpen";
		public static const IMPACT_DID_OPEN:String = "impactDidOpen";
		
		public static const IMPACT_WILL_CLOSE:String = "impactWillClose";
		public static const IMPACT_DID_CLOSE:String = "impactDidClose";

		public static const IMPACT_VIDEO_STARTED:String = "impactVideoStarted";
		public static const IMPACT_VIDEO_COMPLETED_WITH_REWARD:String = "impactVideoCompletedWithReward";
		
		public var data:* = null;
		
		public function ApplifierImpactMobileEvent (eventType:String)
		{
			super(eventType);
		}
	}
}