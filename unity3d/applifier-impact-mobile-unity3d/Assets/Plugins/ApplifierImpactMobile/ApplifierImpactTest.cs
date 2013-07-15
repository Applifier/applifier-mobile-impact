using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ApplifierImpactTest : MonoBehaviour {
	
	private bool _campaignsAvailable = false;

	void Awake() {
		ApplifierImpactMobile.setCampaignsAvailableDelegate(ApplifierImpactCampaignsAvailable);
		ApplifierImpactMobile.setCloseDelegate(ApplifierImpactClose);
		ApplifierImpactMobile.setOpenDelegate(ApplifierImpactOpen);
		ApplifierImpactMobile.setCampaignsFetchFailedDelegate(ApplifierImpactCampaignsFetchFailed);
		ApplifierImpactMobile.setVideoCompletedDelegate(ApplifierImpactVideoCompleted);
		ApplifierImpactMobile.setVideoStartedDelegate(ApplifierImpactVideoStarted);
	}
	
	public void ApplifierImpactCampaignsAvailable() {
		Debug.Log ("IMPACT: CAMPAIGNS READY!");
		_campaignsAvailable = true;
	}

	public void ApplifierImpactCampaignsFetchFailed() {
		Debug.Log ("IMPACT: CAMPAIGNS FETCH FAILED!");
	}

	public void ApplifierImpactOpen() {
		Debug.Log ("IMPACT: OPEN!");
	}
	
	public void ApplifierImpactClose() {
		Debug.Log ("IMPACT: CLOSE!");
	}

	public void ApplifierImpactVideoCompleted(string rewardItemKey, bool skipped) {
		Debug.Log ("IMPACT: VIDEO COMPLETE : " + rewardItemKey + " - " + skipped);
	}

	public void ApplifierImpactVideoStarted() {
		Debug.Log ("IMPACT: VIDEO STARTED!");
	}

	void OnGUI () {
		if (GUI.Button (new Rect (10,10,170,50), _campaignsAvailable ? "Open Impact" : "Waiting...")) {
			if (_campaignsAvailable) {
				ApplifierImpactMobileExternal.Log("Open Impact -button clicked");
				ApplifierImpactMobile.showImpact();
			}	
		}
	}
}
