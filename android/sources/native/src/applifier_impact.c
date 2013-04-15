#include "com_applifier_impact_android_ndk_AndroidNativeBridge.h"
#include "applifier_impact.h"
#include <stdio.h>
#include <android/log.h>
#include <stdarg.h>
#include <stdlib.h>

#define APPNAME "cocos"

/*
 * Applifier Impact Native SDK bridge
 *
 * (c) Applifier 2013
 */

#ifdef __cplusplus
extern "C" {
#endif

void (*impact_event_callback)(int, const char*);
static JavaVM *jvm;
impact_reward_item *reward_items;

const char* __a_impact_get_reward_image_url(const char* name) {

	JNIEnv *localEnv;
	jclass applifierNativeBridge;
	jmethodID methodID;
	jobject strReturn;

	(*jvm)->AttachCurrentThread(jvm, &localEnv, NULL);
	applifierNativeBridge = (*localEnv)->FindClass(localEnv, "com/applifier/impact/android/ndk/AndroidNativeBridge");
	methodID = (*localEnv)->GetStaticMethodID(localEnv, applifierNativeBridge, "__getDefaultReward", "()Ljava/lang/String;");
	strReturn = (*localEnv)->CallStaticObjectMethod(localEnv, applifierNativeBridge, methodID, (*localEnv)->NewStringUTF(localEnv,name));

	return (*localEnv)->GetStringUTFChars(localEnv, strReturn, 0);

}

void __a_impact_call_static_method(const char* name, const char* sig, ...) {

	JNIEnv *localEnv;
	jclass applifierNativeBridge;
	jmethodID methodID;
	va_list args;
	char buf[50];

	(*jvm)->AttachCurrentThread(jvm, &localEnv, NULL);
	applifierNativeBridge = (*localEnv)->FindClass(localEnv, "com/applifier/impact/android/ndk/AndroidNativeBridge");
	methodID = (*localEnv)->GetStaticMethodID(localEnv, applifierNativeBridge, name, sig);
	va_start(args, sig);
	(*localEnv)->CallStaticVoidMethodV(localEnv, applifierNativeBridge, methodID, args);
	va_end(args);

}

/**
 * Get the reward items configured
 */
impact_reward_item* applifier_impact_get_reward_items() {
	return reward_items;
}

/**
 * Set the reward item
 */
void applifier_impact_set_reward_item(const char* key) {
	JNIEnv *localEnv;
	(*jvm)->AttachCurrentThread(jvm, &localEnv, NULL);

	__a_impact_call_static_method("__setReward", "(Ljava/lang/String;)V", (*localEnv)->NewStringUTF(localEnv, key));
}

/*
 * Show Impact
 */
void applifier_impact_show(int show_offer_screen, int show_animated) {

	__a_impact_call_static_method("__showImpact", "(ZZ)V", show_offer_screen, show_animated);

}

/* 
 * Init Impact
 */
void applifier_impact_init(int game_id, void (*iec)(int, const char*)) {

	impact_event_callback = iec;
	__a_impact_call_static_method("__init", "(I)V", game_id);

}

/*
 * Class:     com_applifier_impact_android_ndk_AndroidNativeBridge
 * Method:    bridgeReady
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_applifier_impact_android_ndk_AndroidNativeBridge_bridgeReady
  (JNIEnv *env, jobject obj) {

  	applifier_impact_debug("Bridge ready");

    int status = (*env)->GetJavaVM(env, &jvm);
    if(status != 0) {
    	// Something went really wrong
    }
 }

/*
 * Dispatch an event from the IApplifierImpactListener to the native listener
 *
 * Class:     com_applifier_impact_android_ndk_AndroidNativeBridge
 * Method:    dispatchEvent
 * Signature: (ILjava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_applifier_impact_android_ndk_AndroidNativeBridge_dispatchEvent
  (JNIEnv *env, jobject obj, jint event_id, jstring data) {

  	const char* event_data;

  	if(data != NULL) {
		event_data = (*env)->GetStringUTFChars(env, data, 0);
  	}

  	(*impact_event_callback)(event_id, event_data);

}

/*
 * Dispatch information about reward items
 * 
 * Class:     com_applifier_impact_android_ndk_AndroidNativeBridge
 * Method:    setRewardItems
 * Signature: ([Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_applifier_impact_android_ndk_AndroidNativeBridge_setRewardItems
  (JNIEnv * env, jobject obj, jobjectArray items) {

	JNIEnv *localEnv;
	jclass applifierNativeBridge;
	jmethodID methodID;

	int i;

	(*jvm)->AttachCurrentThread(jvm, &localEnv, NULL);
	applifierNativeBridge = (*localEnv)->FindClass(localEnv, "com/applifier/impact/android/ndk/AndroidNativeBridge");

	reward_items = (impact_reward_item*)malloc(sizeof(impact_reward_item) * (*env)->GetArrayLength(env, items));

	for(i = 0; i < (*env)->GetArrayLength(env, items); i++) {
		impact_reward_item r;
		r.reward_name = (*env)->GetStringUTFChars(env, (*env)->GetObjectArrayElement(env, items, i), 0);
		r.reward_image_url = __a_impact_get_reward_image_url(r.reward_name);
		reward_items[i] = r;
	}

}


void applifier_impact_debug(const char* msg) {
	__android_log_print(ANDROID_LOG_INFO, APPNAME, msg);
}

#ifdef __cplusplus
}
#endif	