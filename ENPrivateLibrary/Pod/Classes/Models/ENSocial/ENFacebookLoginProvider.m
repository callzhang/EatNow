//
//  ENFacebookLoginProvider.m
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENFacebookLoginProvider.h"
#import "extobjc.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ENFacebookLoginProvider ()

@property (nonatomic,copy) ENSocialLoginHandler handler;
@property (nonatomic,strong) FBSDKLoginManager *loginManager;

@property (nonatomic,strong) ENToken *token;

@end

@implementation ENFacebookLoginProvider

#pragma mark - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        self.loginManager = [FBSDKLoginManager new];
    }
    
    return self;
}

#pragma mark - Properties

- (NSString *)name
{
    return @"facebook";
}

- (NSString *)displayName
{
    return NSLocalizedString(@"FacebookLogin", nil);
}

#pragma mark - Public

- (void)loginWithHandler:(ENSocialLoginHandler)handler
{
    self.handler = handler;
    @weakify(self);
    [self.loginManager logInWithReadPermissions: @[@"public_profile",@"email", @"user_friends"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         @strongify(self);
         
         if (error) {
             [self reportCompletionWithResult:result error:error];
             return;
         }
         
         _token = [[ENToken alloc] init];
         _token.token = result.token.tokenString;
         _token.refreshDate = result.token.refreshDate;
         _token.expirationDate = result.token.expirationDate;
         
         [self requestUserInfo];
         
     }];
}

- (void)logout
{
    [self.loginManager logOut];
}

#pragma mark - Private

- (void)requestUserInfo
{
    NSDictionary *params = @{ @"fields" : @"id,name,email,gender,location,picture,birthday,age_range"};
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
         if (error) {
//             DDLogError(@"Fetch facebook user error = %@", error);
             [self reportCompletionWithResult:result error:error];
             return;
         }
         
//         DDLogDebug(@"Fetch fb user : %@", result);
         ENUser *user = [ENFacebookLoginProvider FBUserToENUser:result];
         
         ENSocialLoginResponse *resp = [[ENSocialLoginResponse alloc] initWithProviderName:self.name token:_token user:user];
         [self reportCompletionWithResult:resp error:nil];
    }]; 
    
}

- (void)reportCompletionWithResult:(id)result error:(NSError *)error
{
    if (_handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _handler(result, error);
            _handler = nil;
        });
    }
}

+ (ENUser *)FBUserToENUser:(id)fbUser
{
    ENUser *user = [ENUser new];
    user.userId = [fbUser objectForKey:@"id"];
    user.name = [fbUser objectForKey:@"name"];
    user.email = [fbUser objectForKey:@"email"];
    user.gender = [fbUser objectForKey:@"gender"];
    user.avatarUrl = [fbUser valueForKeyPath:@"picture.data.url"];
    user.age = [NSString stringWithFormat:@"%@", [fbUser valueForKeyPath:@"age_range.min"]];
    user.location = [fbUser objectForKey:@"locale"];
    
    return user;
}

@end
