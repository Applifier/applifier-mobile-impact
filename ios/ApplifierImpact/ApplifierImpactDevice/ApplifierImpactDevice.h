//
//  ApplifierImpactDevice.h
//  ApplifierImpact
//
//  Created by bluesun on 10/19/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kApplifierImpactDeviceIphone;
extern NSString * const kApplifierImpactDeviceIphone3g;
extern NSString * const kApplifierImpactDeviceIphone3gs;
extern NSString * const kApplifierImpactDeviceIphone4;
extern NSString * const kApplifierImpactDeviceIphone4s;
extern NSString * const kApplifierImpactDeviceIphone5;
extern NSString * const kApplifierImpactDeviceIpodTouch1gen;
extern NSString * const kApplifierImpactDeviceIpodTouch2gen;
extern NSString * const kApplifierImpactDeviceIpodTouch3gen;
extern NSString * const kApplifierImpactDeviceIpodTouch4gen;
extern NSString * const kApplifierImpactDeviceIpad;
extern NSString * const kApplifierImpactDeviceIpad1;
extern NSString * const kApplifierImpactDeviceIpad2;
extern NSString * const kApplifierImpactDeviceIpad3;
extern NSString * const kApplifierImpactDeviceIosUnknown;
extern NSString * const kApplifierImpactSimulator;

@interface ApplifierImpactDevice : NSObject

+ (NSString *)advertisingIdentifier;
+ (BOOL)canUseTracking;
+ (NSString *)machineName;
+ (NSString *)analyticsMachineName;
+ (NSString *)currentConnectionType;
+ (NSString *)softwareVersion;

+ (NSString *)md5DeviceId;
+ (NSString *)md5OpenUDIDString;
+ (NSString *)md5AdvertisingIdentifierString;
+ (NSString *)md5MACAddressString;

+ (int)getIOSMajorVersion;
+ (NSNumber *)getIOSExactVersion;

+ (BOOL)isSimulator;

@end
