package com.applifier.impact.android.data;

import java.lang.reflect.Method;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.List;

import com.applifier.impact.android.ApplifierImpactUtils;
import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;

public class ApplifierImpactDevice {
	
	public static String getSoftwareVersion () {
		return "" + Build.VERSION.SDK_INT;
	}
	
	public static String getHardwareVersion () {
		return Build.MANUFACTURER + " " + Build.MODEL;
	}
	
	public static int getDeviceType () {
		return ApplifierImpactProperties.getCurrentActivity().getResources().getConfiguration().screenLayout;
	}
	
	public static String getOdin1Id () {
		String odin1ID = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		
		try {
			odin1ID = ApplifierImpactUtils.SHA1(Secure.getString(ApplifierImpactProperties.getCurrentActivity().getContentResolver(), Secure.ANDROID_ID));
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not resolve ODIN1 Id: " + e.getMessage(), ApplifierImpactDevice.class);
		}
		
		return odin1ID;
	}

	@SuppressLint("DefaultLocale")
	public static String getAndroidId () {
		String androidID = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		
		try {
			androidID = ApplifierImpactUtils.Md5(Secure.getString(ApplifierImpactProperties.getCurrentActivity().getContentResolver(), Secure.ANDROID_ID));
			androidID = androidID.toLowerCase();
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Problems fetching androidId: " + e.getMessage(), ApplifierImpactDevice.class);
		}
		
		return androidID;
	}
	
	public static String getTelephonyId () {
		String telephonyID = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		
		try {
			TelephonyManager tmanager = (TelephonyManager)ApplifierImpactProperties.getCurrentActivity().getSystemService(Context.TELEPHONY_SERVICE);
			telephonyID = ApplifierImpactUtils.Md5(tmanager.getDeviceId());
			telephonyID = telephonyID.toLowerCase();
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Problems fetching telephonyId: " + e.getMessage(), ApplifierImpactDevice.class);
		}
		
		return telephonyID;
	}
	
	public static String getAndroidSerial () {
		String androidSerial = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		
		try {
	        Class<?> c = Class.forName("android.os.SystemProperties");
	        Method get = c.getMethod("get", String.class);
	        androidSerial = (String) get.invoke(c, "ro.serialno");
	        androidSerial = ApplifierImpactUtils.Md5(androidSerial);
	        androidSerial = androidSerial.toLowerCase();
	    } 
		catch (Exception e) {
	    }
		
		return androidSerial;
	}
	
    public static String getMacAddress() {
		NetworkInterface intf = null;
		intf = getInterfaceFor("eth0");		
		if (intf == null) {
			intf = getInterfaceFor("wlan0");
		}
		
		return buildMacAddressFromInterface(intf);
    }
	
    @SuppressLint("DefaultLocale")
	public static String buildMacAddressFromInterface (NetworkInterface intf) {
		byte[] mac = null;
		
		if (intf == null) {
			return ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		}
		
		try
		{
			Method layertype = NetworkInterface.class.getMethod("getHardwareAddress");
			mac = (byte[])layertype.invoke(intf);
		}
		catch (Exception e) {
			ApplifierImpactUtils.Log("Could not getHardwareAddress", ApplifierImpactDevice.class);
		}
		
		if (mac == null) {
			return ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		}
		
		StringBuilder buf = new StringBuilder();
        for (int idx=0; idx<mac.length; idx++)
            buf.append(String.format("%02X:", mac[idx]));       
        if (buf.length()>0) buf.deleteCharAt(buf.length()-1);
        
        String retMacAddress = ApplifierImpactUtils.Md5(buf.toString());
        return retMacAddress.toLowerCase();    	
    }
    
    public static NetworkInterface getInterfaceFor (String interfaceName) {
    	List<NetworkInterface> interfaces = null;
    	
        try {
        	interfaces = Collections.list(NetworkInterface.getNetworkInterfaces());
        }
        catch (Exception e) {
        	return null;
        }
        
    	for (NetworkInterface intf : interfaces) {
    		if (interfaceName != null) {
    			if (intf.getName().equalsIgnoreCase(interfaceName)) {
    				ApplifierImpactUtils.Log("Returning interface: " + intf.getName(), ApplifierImpactDevice.class);
    				return intf;
    			}
    				
            }
    	}
        
    	return null;
    }
    
	public static String getOpenUdid () {
		String deviceId = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		ApplifierImpactOpenUDID.syncContext(ApplifierImpactProperties.getCurrentActivity());
		deviceId = ApplifierImpactUtils.Md5(ApplifierImpactOpenUDID.getOpenUDIDInContext());
		return deviceId.toLowerCase();
	}
	
	public static String getConnectionType () {
		if (isUsingWifi()) {
			return "wifi";
		}
		
		return "cellular";
	}
	
	@SuppressWarnings("deprecation")
	public static boolean isUsingWifi () {
		ConnectivityManager mConnectivity = null;
		mConnectivity = (ConnectivityManager)ApplifierImpactProperties.getCurrentActivity().getSystemService(Context.CONNECTIVITY_SERVICE);

		if (mConnectivity == null)
			return false;

		TelephonyManager mTelephony = (TelephonyManager)ApplifierImpactProperties.getCurrentActivity().getSystemService(Context.TELEPHONY_SERVICE);
		// Skip if no connection, or background data disabled
		NetworkInfo info = mConnectivity.getActiveNetworkInfo();
		if (info == null || !mConnectivity.getBackgroundDataSetting() || !mConnectivity.getActiveNetworkInfo().isConnected() || mTelephony == null) {
		    return false;
		}

		int netType = info.getType();
		if (netType == ConnectivityManager.TYPE_WIFI) {
		    return info.isConnected();
		}
		else {
			return false;
		}
	}
	
	public static int getScreenDensity () {
		return ApplifierImpactProperties.getCurrentActivity().getResources().getDisplayMetrics().densityDpi;
	}
	
	public static int getScreenSize () {
		return getDeviceType();
	}
}
