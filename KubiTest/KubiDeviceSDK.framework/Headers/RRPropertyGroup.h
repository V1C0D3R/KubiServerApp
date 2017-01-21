//
//  RRPropertyGroup.h
//  KubiDeviceSDK
//
//  Created by Oliver on 19/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRJSONSerializableObject.h"
#import "RRDeviceCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface RRPropertyGroup : RRJSONSerializableObject

-(nullable instancetype) propertyGroupAfterApplyingCommand:(RRDeviceCommand *)command error:(NSError * _Nullable * _Nullable)error;
-(nullable id) valueForProperty:(NSString *)property afterApplyingOperation:(RRDeviceCommandOperation *)operation error:(NSError * _Nullable * _Nullable)error;

-(nullable id) objectForKeyedSubscript:(id)key;

@end

NS_ASSUME_NONNULL_END

