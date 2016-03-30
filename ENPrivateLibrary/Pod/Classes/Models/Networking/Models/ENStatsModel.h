//
//  ENStatsModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENStatsModel : JSONModel

@property (nonatomic, strong) NSString *tipCount;
@property (nonatomic, strong) NSString *checkinsCount;
@property (nonatomic, strong) NSString *usersCount;

@end
