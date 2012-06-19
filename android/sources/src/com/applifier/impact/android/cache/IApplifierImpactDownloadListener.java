package com.applifier.impact.android.cache;

public interface IApplifierImpactDownloadListener {
	public void onFileDownloadCompleted (String downloadUrl);
	public void onFileDownloadCancelled (String downloadUrl);
}
