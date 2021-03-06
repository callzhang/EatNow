//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import <objc/message.h>
#import "TMPModelStringValidator.h"

typedef NS_OPTIONS(NSUInteger, FXFormStringValidatorComporatorID) {
	FXFormStringValidatorComparatorType,
	FXFormStringValidatorComparatorMin,
	FXFormStringValidatorComparatorMax,
	FXFormStringValidatorComparatorEqual,
};

@implementation TMPModelStringValidator

-(instancetype)init {
	if((self = [super init])) {
	   _min = -1;
		_max = -1;
	}

	return self;
}

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} must be a string.");
}

-(NSString *)tooShort {
	return (_tooShort ? _tooShort : @"{attribute} must be at least {min} characters long.");
}

-(NSString *)tooLong {
	return (_tooLong ? _tooLong : @"{attribute} must be at most {max} characters long.");
}

-(NSString *)notEqual {
	return (_notEqual ? _notEqual : @"{attribute} must be {length} characters long.");
}

-(void)setLengthLimitation:(id)length {
	if([length isKindOfClass:[NSArray class]] && [(NSArray *)length count]) {
        if([length[0] isKindOfClass:[NSNumber class]]) {
			_min = [length[0] integerValue];
        }

        if(([(NSArray *)length count] > 1) && [length[1] isKindOfClass:[NSNumber class]]) {
			_max = [length[1] integerValue];
        }

		_length = nil;
	} else if([length isKindOfClass:[NSNumber class]]) {
		_length = length;
		_min = -1;
		_max = -1;
	}
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	NSError *error;
	id value = [model valueForKey:attribute];

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorType]))
		[self addError:model attribute:attribute error:error];

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorMin]))
		[self addError:model attribute:attribute error:error];

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorMax]))
		[self addError:model attribute:attribute error:error];

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorEqual]))
		[self addError:model attribute:attribute error:error];
}

-(NSError *)validateValue:(id)value {
	NSError *error;

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorType]))
		return error;

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorMin]))
		return error;

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorMax]))
		return error;

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorEqual]))
		return error;

	return nil;
}

-(NSError *)compareValue:(id)value comporator:(FXFormStringValidatorComporatorID)comparatorID {
	NSUInteger (*callback)(id, SEL) = (NSUInteger (*)(id, SEL))objc_msgSend;

	switch(comparatorID) {
		case FXFormStringValidatorComparatorType:
			if (!([value isKindOfClass:[NSString class]])) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.message,
									   }];
			}
			break;
		case FXFormStringValidatorComparatorMin:
			if (_min >= 0 && (callback(value, @selector(length)) < _min)) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.tooShort,
											   @"{min}": @(_min),
									   }];
			}
			break;
		case FXFormStringValidatorComparatorMax:
			if(_max >= 0 && (callback(value, @selector(length)) > _max)) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.tooLong,
											   @"{max}": @(_max),
									   }];
			}
			break;
		case FXFormStringValidatorComparatorEqual:
			if(_length && (callback(value, @selector(length)) != [_length integerValue])) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.notEqual,
											   @"{length}": _length,
									   }];
			}
			break;
	}

	return nil;
}
@end
