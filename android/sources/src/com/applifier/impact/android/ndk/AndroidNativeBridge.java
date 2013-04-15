// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AndroidNativeBridge.java

package com.applifier.impact.android.ndk;

import android.app.Activity;
import android.util.Log;
import com.applifier.impact.android.ApplifierImpact;
import com.applifier.impact.android.IApplifierImpactListener;
import java.util.*;

/**
 * The Impact Android JDK <-> NDK bridge
 * 
 * @author tuomasrinta
 *
 */
public class AndroidNativeBridge implements IApplifierImpactListener {
	
    private static final AndroidNativeBridge self = new AndroidNativeBridge();

    private Activity parentActivity;
    private ApplifierImpact impact;
    private boolean bridgeInitBroadcast;
    private static int EVENT_IMPACT_CLOSE = 1;
    private static int EVENT_IMPACT_OPEN = 2;
    private static int EVENT_IMPACT_VIDEO_START = 3;
    private static int EVENT_IMPACT_VIDEO_COMPLETE = 4;
    private static int EVENT_IMPACT_CAMPAIGNS_AVAILABLE = 5;
    private static int EVENT_IMPACT_CAMPAIGNS_FAILED = 6;	

    public static AndroidNativeBridge getInstance() {
        return self;
    }

    public static void __init(int id)
    {
        self.__initImpact(id);
    }

    private AndroidNativeBridge() {
        parentActivity = null;
        impact = null;
        bridgeInitBroadcast = false;
        if(self != null)
            throw new IllegalStateException("Cannot re-instantiate AndroidNativeBridge, something is wrong.");
    }

    public void setRootActivity(Activity activity) {
        parentActivity = activity;
        if(impact != null)
            impact.changeActivity(activity);
        if(!bridgeInitBroadcast) {
            bridgeReady();
            bridgeInitBroadcast = true;
        }
    }

    public void onImpactClose() {
        dispatchEvent(EVENT_IMPACT_CLOSE, null);
    }

    public void onImpactOpen() {
        dispatchEvent(EVENT_IMPACT_OPEN, null);
    }

    public void onVideoStarted() {
        dispatchEvent(EVENT_IMPACT_VIDEO_START, null);
    }

    public void onVideoCompleted(String key) {
        dispatchEvent(EVENT_IMPACT_VIDEO_COMPLETE, key);
    }

    public void onCampaignsAvailable() {
        setRewardItems((String[])impact.getRewardItemKeys().toArray(new String[0]));
        dispatchEvent(EVENT_IMPACT_CAMPAIGNS_AVAILABLE, null);
    }

    public void onCampaignsFetchFailed() {
        dispatchEvent(EVENT_IMPACT_CAMPAIGNS_FAILED, null);
    }

    public static void __showImpact(boolean offerScreen, boolean animated) {
        if(getInstance().impact == null) {
            throw new IllegalStateException("Impact has not yet been initialized");
        } else {
            HashMap<String, Object> properties = new HashMap<String, Object>();
            properties.put("noOfferScreen", Boolean.valueOf(offerScreen));
            properties.put("openAnimated", Boolean.valueOf(animated));
            getInstance().impact.showImpact(properties);
            return;
        }
    }

    public static String __getDefaultReward()
    {
        return getInstance().impact.getDefaultRewardItemKey();
    }

    public static String __getRewardUrl(String key)
    {
        return (String)getInstance().impact.getRewardItemDetailsWithKey(key)
        		.get(ApplifierImpact.APPLIFIER_IMPACT_REWARDITEM_PICTURE_KEY);
    }

    public void __initImpact(int appId)
    {
        if(impact != null)
            throw new IllegalStateException("Impact has already been initialized");
        if(parentActivity == null)
        {
            throw new IllegalStateException("You must call setRootActivity(Activity) in your Java code prior to initializing impact.");
        } else
        {
            ApplifierImpact.setDebugMode(true);
            impact = new ApplifierImpact(parentActivity, (new StringBuilder(String.valueOf(appId))).toString(), this);
            Log.d("applifier", "new ApplifierImpact done");
            return;
        }
    }

    public native void bridgeReady();

    public native void dispatchEvent(int i, String s);

    public native void setRewardItems(String as[]);



}
