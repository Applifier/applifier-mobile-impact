package com.applifier.impact.android.webapp;

import java.lang.reflect.Method;

import org.json.JSONObject;

import com.applifier.impact.android.ApplifierImpactProperties;
import com.applifier.impact.android.ApplifierImpactUtils;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Build;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class ApplifierImpactWebView extends WebView {

	private String _url = "http://quake.everyplay.fi/~bluesun/impact/newproto/index.html";	
	private IApplifierImpactWebViewListener _listener = null;
	private boolean _webAppLoaded = false;
	private ApplifierImpactWebBridge _webBridge = null;
	
	public ApplifierImpactWebView(Activity activity, IApplifierImpactWebViewListener listener, ApplifierImpactWebBridge webBridge) {
		super(activity);
		init(activity, _url, listener, webBridge);
	}

	public ApplifierImpactWebView(Activity activity, String url, IApplifierImpactWebViewListener listener, ApplifierImpactWebBridge webBridge) {
		super(activity);
		init(activity, url, listener, webBridge);
	}
	
	public boolean isWebAppLoaded () {
		return _webAppLoaded;
	}
	
	public void setView (String view) {
		setView(view, null);
	}
	
	public void setView (String view, JSONObject data) {		
		if (isWebAppLoaded()) {
			String dataStr = "";
			if (data != null) {
				dataStr = data.toString();
				dataStr = dataStr.replace("\"", "\\\"");
			}
							
			String jsCommand = ApplifierImpactProperties.IMPACT_JS_PREFIX + "setView(\"" + view + "\", \"" + dataStr + "\")";
			loadUrl(jsCommand);
		}
	}
	
	public void setAvailableCampaigns (String videoPlan) {
		if (isWebAppLoaded()) {
			videoPlan = videoPlan.replace("\"", "\\\"");
			JSONObject params = new JSONObject();
			try {
				params.put("deviceId", ApplifierImpactUtils.getDeviceId(getContext()));
				params.put("softwareVersion", Build.VERSION.SDK_INT);
				params.put("hardwareVersion", "unknown");
				params.put("deviceType", "phone");
				params.put("apiVersion", "1");
				params.put("platform", "android");
			}
			catch (Exception e) {
				Log.d(ApplifierImpactProperties.LOG_NAME, "JSON Error");
			}
			String paramStr = "";
			paramStr = params.toString();
			paramStr = paramStr.replace("\"", "\\\"");
			loadUrl(ApplifierImpactProperties.IMPACT_JS_PREFIX + "init(\"" + videoPlan + "\", \"" + paramStr + "\");");
		}
	}
	
	
	public void setDeviceId (String deviceId) {
		if (isWebAppLoaded())
			loadUrl("javascript:setDeviceId('" + deviceId +"');");
	}
	
	/* INTENRAL METHODS */
	
	private void init (Activity activity, String url, IApplifierImpactWebViewListener listener, ApplifierImpactWebBridge webBridge) {
		_listener = listener;
		_url = url;
		_webBridge = webBridge;
		setupApplifierView();
		loadUrl(_url);
	}
	
	private void setupApplifierView ()  {
		getSettings().setJavaScriptEnabled(true);
		
		if (_url != null && _url.indexOf("_raw.html") != -1) {
			getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
			Log.d(ApplifierImpactProperties.LOG_NAME, "startup() -> LOAD_NO_CACHE");
		}
		else {
			getSettings().setCacheMode(WebSettings.LOAD_NORMAL);
		}
		
		String appCachePath = getContext().getCacheDir().toString();
		
		getSettings().setSupportZoom(false);
		getSettings().setBuiltInZoomControls(false);
		getSettings().setLightTouchEnabled(false);
		getSettings().setRenderPriority(WebSettings.RenderPriority.HIGH);
		getSettings().setSupportMultipleWindows(false);
		
		setHorizontalScrollBarEnabled(false);
		setVerticalScrollBarEnabled(false);		

		setClickable(true);
		setFocusable(true);
		setFocusableInTouchMode(true);
		setInitialScale(0);
		
		setBackgroundColor(Color.TRANSPARENT);
		setBackgroundDrawable(null);
		setBackgroundResource(0);
		
		setWebViewClient(new ApplifierViewClient());
		setWebChromeClient(new ApplifierViewChromeClient());
			
		if (appCachePath != null) {
			boolean appCache = true;
  
			if (Integer.parseInt(android.os.Build.VERSION.SDK) <= 7) {
				appCache = false;
			}
  
			getSettings().setAppCacheEnabled(appCache);
			getSettings().setDomStorageEnabled(true);
			getSettings().setAppCacheMaxSize(1024*1024*10);
			getSettings().setAppCachePath(appCachePath);
			getSettings().setAllowFileAccess(true);
		}
		
		// WebView background will go white in SDK >= 11 if you don't set webview's
		// layer-type to software.
		try
		{
			Method layertype = View.class.getMethod("setLayerType", Integer.TYPE, Paint.class);
			layertype.invoke(this, 1, null);
		}
		catch (Exception e) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "Could not invoke setLayerType");
		}
		
		addJavascriptInterface(_webBridge, "ApplifierWebBridge");
	}
	
	
	/* OVERRIDE METHODS */
	
	@Override
    public boolean onKeyDown(int keyCode, KeyEvent event)  {
		switch (keyCode) {
			case KeyEvent.KEYCODE_BACK:
		    	if (_listener != null)
		    		_listener.onBackButtonClicked(this);
		    	return true;
		}
    	
    	return false;
    } 
	
	
	/* SUBCLASSES */
	
	private class ApplifierViewChromeClient extends WebChromeClient {
		public void onConsoleMessage(String message, int lineNumber, String sourceID) {
			Log.d(ApplifierImpactProperties.LOG_NAME, "JAVASCRIPT(" + lineNumber + "): " + message);
		}
		
		public void onReachedMaxAppCacheSize(long spaceNeeded, long totalUsedQuota, WebStorage.QuotaUpdater quotaUpdater) {
			quotaUpdater.updateQuota(spaceNeeded * 2);
		}
	}
	
	private class ApplifierViewClient extends WebViewClient {
		@Override
		public void onPageFinished (WebView webview, String url) {
			super.onPageFinished(webview, url);
			Log.d(ApplifierImpactProperties.LOG_NAME, "Finished url: "  + url);
			if (_listener != null && !_webAppLoaded) {
				_webAppLoaded = true;
				_listener.onWebAppLoaded();
			}
		}
		
		@Override
		public boolean shouldOverrideUrlLoading (WebView view, String url) {
			return false;
		}
		
		@Override
		public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {		
			Log.e(ApplifierImpactProperties.LOG_NAME, "ApplifierViewClient.onReceivedError() -> " + errorCode + " (" + failingUrl + ") " + description);
			super.onReceivedError(view, errorCode, description, failingUrl);
		}

		@Override
		public void onLoadResource(WebView view, String url) {
			super.onLoadResource(view, url);
		}	
	}
}
