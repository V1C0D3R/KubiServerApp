//
//  RRDeviceCommand.h
//  KubiDeviceSDK
//
//  Created by Oliver on 19/11/2015.
//  Copyright © 2015 Revolve Robotics Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRJSONSerializableObject.h"

NS_ASSUME_NONNULL_BEGIN

@class RRDeviceCommandOperation;

@interface RRDeviceCommand : RRJSONSerializableObject

-(BOOL)	hasValueForProperty:(NSString *)property;
-(nullable id) objectForProperty:(NSString *)property;

-(nullable id) objectForKeyedSubscript:(id)key;

@property (readonly, nonnull)	NSDictionary<NSString *, RRDeviceCommandOperation *> *operations;
@property (readonly, nonnull)	NSDictionary<NSString *, RRDeviceCommand *> *commands;

@end

@interface RRDeviceCommandOperation : NSObject
+(instancetype) setOperationWithValue:(id)value;
+(instancetype) addOperationWithValue:(id)value;
+(instancetype) subtractOperationWithValue:(id)value;
+(instancetype) operationFromString:(NSString *)string;

-(NSString *) stringValue;

@property (readonly, nonnull)	NSString *	operationName;
@property (readonly, nonnull)	id			operand;

@end

@interface RRMutableDeviceCommand : RRDeviceCommand

-(void) setOperation:(RRDeviceCommandOperation *)operation	forProperty:(NSString *)property;
-(void) setCommand:(RRDeviceCommand *)command				forProperty:(NSString *)property;

@end

NS_ASSUME_NONNULL_END
