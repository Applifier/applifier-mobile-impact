//
//  ApplifierImpactDevice.h
//  ApplifierImpact
//
//  Created by bluesun on 10/19/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactDevice : NSObject

+ (NSString *)advertisingIdentifier;
+ (BOOL)canUseTracking;
+ (NSString *)machineName;
+ (NSString *)analyticsMachineName;
+ (NSString *)macAddress;
+ (NSString *)currentConnectionType;
+ (NSString *)softwareVersion;

+ (NSString *)md5DeviceId;
+ (NSString *)md5OpenUDIDString;
+ (NSString *)md5MACAddressString;
+ (NSString *)md5AdvertisingIdentifierString;

+ (int)getIOSMajorVersion;
+ (NSNumber *)getIOSExactVersion;

@end
