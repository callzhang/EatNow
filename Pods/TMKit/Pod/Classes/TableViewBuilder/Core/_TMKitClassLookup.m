//
//  TMKitClassLookup.m
//  Pods
//
//  Created by Zitao Xiong on 8/7/15.
//
//

#import "_TMKitClassLookup.h"
@interface _TMKitClassLookup()
@property (nonatomic, strong) NSMutableDictionary *classLookup;
@end

@implementation _TMKitClassLookup
+ (instancetype)defaultLookup {
    static dispatch_once_t onceToken;
    static _TMKitClassLookup *defaultLookup;
    dispatch_once(&onceToken, ^{
        defaultLookup = [[_TMKitClassLookup alloc] init];
    });
    
    return defaultLookup;
}

- (void)registerClass:(Class)klass forType:(TMTableViewBuilderClassType)type {
    self.classLookup[@(type)] = klass;
}

- (Class)classForType:(TMTableViewBuilderClassType)type {
    Class klass = self.classLookup[@(type)];
    return klass;
}

- (NSMutableDictionary *)classLookup {
    if (!_classLookup) {
        _classLookup = [NSMutableDictionary new];
    }
    return _classLookup;
}

@end
