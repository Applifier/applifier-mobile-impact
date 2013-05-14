package com.applifier.impact.android.data;

import java.lang.reflect.Method;

import com.applifier.impact.android.ApplifierImpactUtils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

public class ApplifierImpactGraphicsBundle {
	public static String ICON_AUDIO_UNMUTED_32x23 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNSBNYWNpbnRvc2giIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NEFDNDRCRTRBRkUwMTFFMkFGQUU4NzY0Nzk1MUZGRDkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NEFDNDRCRTVBRkUwMTFFMkFGQUU4NzY0Nzk1MUZGRDkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo0QUM0NEJFMkFGRTAxMUUyQUZBRTg3NjQ3OTUxRkZEOSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo0QUM0NEJFM0FGRTAxMUUyQUZBRTg3NjQ3OTUxRkZEOSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pkm4H1EAAAIYSURBVHja7NdNSBRhHMdxZ7VILVPCd/HtpNElRURBwUo9CHmSUgykw15K8NBNO5aHTgqeO3UUfNebeCjw0CEIxEMRGBmISlSg6+r0feAnTNvMuLOrSbQPfJh55nmZ/zzPzPMwlm3baeeZQmnnnFIB/PMB5OAFJlGSSAcZSQZQjx7koQBf/uYIPMYMKpCJwhPqvkLpaYxApob9keOaWUwOfdqYsj78RPi3ErMQBVCEOfvPtI87Pu1CWFLdJmdZkCm4gVl0eZTHLqmX8QQdOMK4rof9psAU1iDfMaS2OriFygABX8IQDnATy3inByjDZ7cpWEHUDp7MFLSpj1ZU6PyZynuVf678fa8pODzhZfJL5kmLMY0JXVvUsVPHVR3rvD5D22Uu403p2MJHNKIIH7CtaTXpE37g2lksxRai+IoryMV3MefZOjcjdfUsArAdL19UN8qQiCNvaS059QCONLTXsYkNTcPxEh3ReRYuen2G6UkEFdKTv8aKbtigm71RnVrlt7wC2FPDCy4voxXHxvYN9/QlmXy/yuZ1bMc+FrwCeKpNJSfmczSNujEQx0gctzP9lOMl3qJKAbzHVCJ7gVnPhxHxWIhuu9QvRpbyI6o76KwXdDMyHmA34GZUgx2sIS/ZAIwWrMcE0O5Tf0z17saWJRqAUY1FdRyJYwSa3cqsJH9MqjGqF+6hluFgy2fqzygVwH8fwC8BBgCfIMq53HvyNAAAAABJRU5ErkJggg==";
	
	@SuppressWarnings("unchecked")
	public static Bitmap getBitmapFromString (String bitmapString) {
		Method base64decode = null;
		@SuppressWarnings("rawtypes")
		Class b64 = null;
		
		if (bitmapString != null) {
			try {
				b64 = Class.forName("android.util.Base64");
				
				if (b64 != null) {
					base64decode = b64.getMethod("decode", String.class, Integer.TYPE);
				}
				else {
					ApplifierImpactUtils.Log("Could not find base64 decode class", ApplifierImpactGraphicsBundle.class);
				}
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Proper decode method could not be found, disabling mute-button feature", ApplifierImpactGraphicsBundle.class);
			}
						
			ApplifierImpactUtils.Log("METHOD: " + base64decode + ", " + b64, ApplifierImpactGraphicsBundle.class);
			byte[] decodedString = null;
			
			try {
				decodedString = (byte[])base64decode.invoke(null, bitmapString, 0);
			}
			catch (Exception e) {
				ApplifierImpactUtils.Log("Problems invoking decode method", ApplifierImpactGraphicsBundle.class);
			}
			
			ApplifierImpactUtils.Log("BITMAPDATA: " + decodedString, ApplifierImpactGraphicsBundle.class);
			
			Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
			return decodedByte;
		}
		
		return null;
	}
}
