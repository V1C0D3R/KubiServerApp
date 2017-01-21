//
//  RRDeviceSDK.h
//  KubiDeviceSDK
//
//  Created by Oliver on 26/10/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRDevice.h"

@class RRDeviceSDK;

FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDevicesDetectedNotification;
FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDeviceListUserKey;

FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDeviceConnectionStateChangedNotification;
FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDeviceUserKey;
FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDeviceConnectionStateUserKey;

FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDeviceConnectionFailedNotification;
FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKDeviceConnectionErrorKey;
FOUNDATION_EXPORT NSString * _Nonnull const RRDeviceSDKErrorDomain;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, RRDeviceConnectionState)
{
	RRDeviceConnectionStateDisconnected,
	RRDeviceConnectionStateConnecting,
	RRDeviceConnectionStateConnected,
	RRDeviceConnectionStateConnectionLost
};


@protocol RRDeviceSDKDelegate <NSObject>

- (void)    deviceSDK: (RRDeviceSDK *)deviceSDK
  didUpdateDeviceList: (NSArray *)deviceList;

- (void)         deviceSDK: (RRDeviceSDK *)deviceSDK
  didChangeConnectionState: (RRDeviceConnectionState)connectionState;

@end


@interface RRDeviceSDK : NSObject

+(instancetype _Nonnull) deviceSdk;
//+(instancetype _Nonnull) deviceSdkWithApiKey:(NSString * _Nonnull )key andSecret:(NSString * _Nonnull)secret;

@property (nullable, nonatomic, weak) id <RRDeviceSDKDelegate> delegate;

/* Connect using the best available peripheral device */
-(BOOL) connectClosestDevice;

/* Connect using a specific peripheral device */
-(BOOL) connectDevice:(nonnull RRDevice *)device;

/* Disconnect the currently connected peripheral device */
-(BOOL) disconnectDevice;


/*** Device Scanning ***/

-(BOOL) startScan;
/*
 Begin scanning continuously for devices in the background.
 */

-(void) endScan;
/*
 Stop background scan for devices.
 */


@property (nonnull, nonatomic, readonly)	NSArray *				deviceList;
@property (nullable, nonatomic, readonly)	RRDevice *				connectedDevice;
@property (nonatomic, readonly)				RRDeviceConnectionState	deviceConnectionState;

-(BOOL) shareControlWithAppData:(nullable NSString *)data success:(nullable void(^)())success fail:(nullable void(^)(NSError * _Nullable error))fail;
-(void)	stopSharingControl;

@property (nullable, nonatomic, readonly)	NSString *				appData;
@property (nullable, nonatomic, readonly)	NSString *				shareToken;
@property (nullable, nonatomic, readonly)	NSURL *					shareURL;

@end

NS_ASSUME_NONNULL_END
