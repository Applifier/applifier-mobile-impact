package com.applifier.impact.android.data;

import java.lang.reflect.Method;

import com.applifier.impact.android.properties.ApplifierImpactConstants;
import com.applifier.impact.android.properties.ApplifierImpactProperties;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
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
	
	public static String getDeviceType () {
		String deviceType = "" + ApplifierImpactProperties.CURRENT_ACTIVITY.getResources().getConfiguration().screenLayout;
		return deviceType;
	}

	public static String getDeviceId () {
		if (ApplifierImpactProperties.CURRENT_ACTIVITY == null) return ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		
		Context context = ApplifierImpactProperties.CURRENT_ACTIVITY;
		String prefix = "";
		String deviceId = null;
		//get android id
		
		if  (deviceId == null || deviceId.length() < 3) {
			//get telephony id
			prefix = "aTUDID";
			try {
				TelephonyManager tmanager = (TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE);
				deviceId = tmanager.getDeviceId();
			}
			catch (Exception e) {
				//maybe no permissions
			}
		}
		
		if  (deviceId == null || deviceId.length() < 3) {
			//get device serial no using private api
			prefix = "aSNO";
			try {
		        Class<?> c = Class.forName("android.os.SystemProperties");
		        Method get = c.getMethod("get", String.class);
		        deviceId = (String) get.invoke(c, "ro.serialno");
		    } 
			catch (Exception e) {
		    }
		}

		if  (deviceId == null || deviceId.length() < 3) {
			deviceId = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);
			prefix = "aID";
		}
		
		if  (deviceId == null || deviceId.length() < 3) {
			//get mac address
			prefix = "aWMAC";
			try {
				WifiManager wm = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
				deviceId = wm.getConnectionInfo().getMacAddress();
			} catch (Exception e) {
				//maybe no permissons or wifi off
			}
		}
		
		if  (deviceId == null || deviceId.length() < 3) {
			prefix = "aUnknown";
			deviceId = Build.MANUFACTURER + "-" + Build.MODEL + "-"+Build.FINGERPRINT; 
		}

		//Log.d(_logName, "DeviceID : " + prefix + "_" + deviceId);
		return prefix + "_" + deviceId;
	}
	
	public static String getMacAddress () {
		String deviceId = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		
		if (ApplifierImpactProperties.CURRENT_ACTIVITY == null) return deviceId;
		
		Context context = ApplifierImpactProperties.CURRENT_ACTIVITY;

		try {
			WifiManager wm = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
			deviceId = wm.getConnectionInfo().getMacAddress();
		} 
		catch (Exception e) {
			//maybe no permissons or wifi off
		}
		
		return deviceId;
	}
	
	public static String getOpenUdid () {
		String deviceId = ApplifierImpactConstants.IMPACT_DEVICEID_UNKNOWN;
		return deviceId;
	}
	
	public static String getConnectionType () {
		if (isUsingWifi()) {
			return "wifi";
		}
		
		return "cellular";
	}
	
	public static boolean isUsingWifi () {
		ConnectivityManager mConnectivity = null;
		mConnectivity = (ConnectivityManager)ApplifierImpactProperties.CURRENT_ACTIVITY.getSystemService(Context.CONNECTIVITY_SERVICE);

		if (mConnectivity == null)
			return false;

		TelephonyManager mTelephony = (TelephonyManager)ApplifierImpactProperties.CURRENT_ACTIVITY.getSystemService(Context.TELEPHONY_SERVICE);
		// Skip if no connection, or background data disabled
		NetworkInfo info = mConnectivity.getActiveNetworkInfo();
		if (info == null || !mConnectivity.getBackgroundDataSetting() || mTelephony == null) {
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
}
