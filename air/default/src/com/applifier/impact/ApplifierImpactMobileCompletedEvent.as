package com.applifier.impact
{
	public class ApplifierImpactMobileCompletedEvent extends ApplifierImpactMobileEvent
	{
		public var rewardItemKey:String = null;
		public var skipped:Boolean = false;
		
		public function ApplifierImpactMobileCompletedEvent (rewardItemKey:String, skipped:Boolean) {
			super(ApplifierImpactMobileEvent.IMPACT_VIDEO_COMPLETED_WITH_REWARD);
			rewardItemKey = rewardItemKey;
			skipped = skipped;
		}
	}
}

