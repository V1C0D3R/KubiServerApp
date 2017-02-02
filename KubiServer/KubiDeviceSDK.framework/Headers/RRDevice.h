//
//  RRDevice.h
//  KubiDeviceSDK
//
//  Created by Oliver on 5/10/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRDeviceCommand.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * _Nonnull const RRDevicePropertiesChangedNotification;

@class RRDevice;

@interface RRDevice : NSObject

-(BOOL) performCommand:(id)command
			   success:(void(^)(RRDevice * device, RRDeviceCommand * command))success
				  fail:(void(^)(RRDevice *device, RRDeviceCommand * command, NSError *error))fail;

@property (nonatomic, readonly, nonnull)	NSString *				identifier;
@property (nonatomic, readonly, nonnull)	NSString *				type;

@property (nonatomic, readonly)				BOOL					isConnected;
@property (nonatomic, readonly)				BOOL					isLocalDevice;

- (NSString *) name;

@end

NS_ASSUME_NONNULL_END