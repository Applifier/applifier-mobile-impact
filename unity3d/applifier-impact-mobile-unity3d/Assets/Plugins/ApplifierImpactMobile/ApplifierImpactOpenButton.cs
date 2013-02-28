using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ApplifierImpactOpenButton : MonoBehaviour {
	private bool _canOpenImpact = false;
	
	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
	}
	
	void OnGUI () {
		if (ApplifierImpactMobile.getTestButtonVisibility()) {
			string buttonText = "Waiting...";
			
			if (!_canOpenImpact && ApplifierImpactMobile.canShowCampaigns() && ApplifierImpactMobile.canShowImpact())
				_canOpenImpact = true;
			
			if (_canOpenImpact)
				buttonText = "Open Impact";
			
			if (GUI.Button (new Rect (10,10,170,50), buttonText)) {
				if (_canOpenImpact) {
					ApplifierImpactMobileExternal.Log("Open Impact -button clicked");
					ApplifierImpactMobile.showImpact();
				}	
			}
			
			if (GUI.Button (new Rect (10,70,170,50), "Show rewardItemKeys")) {
				if (_canOpenImpact) {
					List<string> keys = ApplifierImpactMobile.getRewardItemKeys();
					foreach (string key in keys) {
						ApplifierImpactMobileExternal.Log("Reward key: " + key);
					}
				}	
			}
			
			if (GUI.Button (new Rect (10,130,170,50), "Reward item details")) {
				if (_canOpenImpact) {
					ApplifierImpactMobileExternal.Log("Trying to fetch details with key: " + ApplifierImpactMobile.getCurrentRewardItemKey());
					ApplifierImpactMobile.getRewardItemDetailsWithKey(ApplifierImpactMobile.getCurrentRewardItemKey());
				}	
			}
		}
	}
}
