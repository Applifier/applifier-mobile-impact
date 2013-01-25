package com.applifier.impact.android;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.lang.reflect.Method;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;

import com.applifier.impact.android.campaign.ApplifierImpactCampaign;
import com.applifier.impact.android.properties.ApplifierImpactConstants;

import android.os.Environment;
import android.util.Log;

public class ApplifierImpactUtils {

	public static void Log (String message, Class cls) {
		Log.d(ApplifierImpactConstants.LOG_NAME, cls.getName() + " :: " +  message);
	}
	
	public static void Log (String message, Object obj) {
		Log.d(ApplifierImpactConstants.LOG_NAME, obj.getClass().getName() + " :: " +  message);
	}
	
	public static String Md5 (String input) {
		MessageDigest m = null;
		try {
			m = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		m.update(input.getBytes(),0,input.length());
		byte p_md5Data[] = m.digest();
		
		String mOutput = new String();
		for (int i=0;i < p_md5Data.length;i++) {
			int b =  (0xFF & p_md5Data[i]);
			// if it is a single digit, make sure it have 0 in front (proper padding)
			if (b <= 0xF) mOutput+="0";
			// add number to string
			mOutput+=Integer.toHexString(b);
		}
		// hex string to uppercase
		return mOutput.toUpperCase();
	}
	
	public static String readFile (File fileToRead, boolean addLineBreaks) {
		String fileContent = "";
		BufferedReader br = null;
		
		if (fileToRead.exists() && fileToRead.canRead()) {
			try {
				br = new BufferedReader(new FileReader(fileToRead));
				String line = null;
				
				while ((line = br.readLine()) != null) {
					fileContent = fileContent.concat(line);
					if (addLineBreaks)
						fileContent = fileContent.concat("\n");
				}
			}
			catch (Exception e) {
				Log("Problem reading file: " + e.getMessage(), ApplifierImpactUtils.class);
				return null;
			}
			
			try {
				br.close();
			}
			catch (Exception e) {
				Log("Problem closing reader: " + e.getMessage(), ApplifierImpactUtils.class);
			}
						
			return fileContent;
		}
		else {
			Log("File did not exist or couldn't be read", ApplifierImpactUtils.class);
		}
		
		return null;
	}
	
	public static boolean writeFile (File fileToWrite, String content) {
		FileOutputStream fos = null;
		
		try {
			fos = new FileOutputStream(fileToWrite);
			fos.write(content.getBytes());
			fos.flush();
			fos.close();
		}
		catch (Exception e) {
			Log("Could not write file: " + e.getMessage(), ApplifierImpactUtils.class);
			return false;
		}
		
		Log("Wrote file: " + fileToWrite.getAbsolutePath(), ApplifierImpactUtils.class);
		
		return true;
	}
	
	public static void removeFile (String fileName) {
		File removeFile = new File (fileName);
		File cachedVideoFile = new File (ApplifierImpactUtils.getCacheDirectory() + "/" + removeFile.getName());
		
		if (cachedVideoFile.exists()) {
			if (!cachedVideoFile.delete())
				Log("Could not delete: " + cachedVideoFile.getAbsolutePath(), ApplifierImpactUtils.class);
			else
				Log("Deleted: " + cachedVideoFile.getAbsolutePath(), ApplifierImpactUtils.class);
		}
		else {
			Log("File: " + cachedVideoFile.getAbsolutePath() + " doesn't exist.", ApplifierImpactUtils.class);
		}
	}
	
	public static String getCacheDirectory () {
		return Environment.getExternalStorageDirectory().toString() + "/" + ApplifierImpactConstants.CACHE_DIR_NAME;
	}
	
	public static File createCacheDir () {
		File tdir = new File (getCacheDirectory());
		tdir.mkdirs();
		return tdir;
	}
	
	public static boolean isFileRequiredByCampaigns (String fileName, ArrayList<ApplifierImpactCampaign> campaigns) {
		if (fileName == null || campaigns == null) return false;
		
		File seekFile = new File(fileName);
		
		for (ApplifierImpactCampaign campaign : campaigns) {
			File matchFile = new File(campaign.getVideoFilename());
			if (seekFile.getName().equals(matchFile.getName()))
				return true;
		}
		
		return false;
	}

	public static boolean isFileInCache (String fileName) {
		File targetFile = new File (fileName);
		File testFile = new File(getCacheDirectory() + "/" + targetFile.getName());
		return testFile.exists();
	}
}
