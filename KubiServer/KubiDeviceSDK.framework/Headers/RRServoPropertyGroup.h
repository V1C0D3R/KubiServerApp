//
//  RRServoPropertyGroup.h
//  KubiDeviceSDK
//
//  Created by Oliver on 19/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import "RRPropertyGroup.h"

@interface RRServoPropertyGroup : RRPropertyGroup

@property (nonatomic, nonnull, readonly)	NSDecimalNumber *angle;
@property (nonatomic, nonnull, readonly)	NSDecimalNumber *speed;
@property (nonatomic, readonly)				BOOL			disabled;

@end


