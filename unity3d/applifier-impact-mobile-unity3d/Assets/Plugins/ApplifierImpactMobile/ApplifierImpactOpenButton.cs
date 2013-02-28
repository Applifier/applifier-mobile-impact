using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ApplifierImpactOpenButton : MonoBehaviour {
	private bool _canOpenImpact = false;
	
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
		}
	}
}
