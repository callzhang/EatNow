//
//  WechatLoginProvider.m
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENWechatLoginProvider.h"
#import "WXApi.h"

static NSString* const kWXAppId = @"wx542360b55f95c47e";
static NSString* const kWXSecret = @"8803996156a3ebcd554dc735b7248ad6";

static

@interface ENWechatLoginProvider () <WXApiDelegate>

@property (nonatomic, copy) ENSocialLoginHandler handler;

@end

@implementation ENWechatLoginProvider

- (NSString *)name
{
    return @"com.tecent.xin";
}

- (NSString *)displayName
{
    return NSLocalizedString(@"WechatLogin", nil);
}

- (void)loginWithHandler:(ENSocialLoginHandler)handleFunction
{
    self.handler = handleFunction;
    
    [self sendAuthRequest];
}

- (void)handleResponse:(id)resp
{
    SendAuthResp *authResp = (SendAuthResp *)resp;
    if (authResp.errCode == 0) {
        [self getTokenByCode:authResp.code];
    }
    else{
    
        NSString *errorDesc = [NSString stringWithFormat:@"Wechat SendAuthResponse error with code = %d", authResp.errCode];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:@"com.eatnow.social.error.login" code:authResp.errCode userInfo:userInfo];
        [self callHandlerInMainThreadWithResponse:nil andError:error];
        DDLogError(@"Get wechat auth code error");
    }

}

#pragma mark - Private

- (void)sendAuthRequest
{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"eatnow123" ;
    
    [WXApi sendReq:req];

}

- (void)getTokenByCode:(NSString *)code
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWXAppId,kWXSecret,code];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            DDLogError(@"Get wechat token error:%@",error);
            [self callHandlerInMainThreadWithResponse:nil andError:error];
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *token = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        [self getUserInfoByToken:token];

    }];
    
    [task resume];
    
}

- (void)getUserInfoByToken:(NSDictionary *)token
{
    NSString *accessToken = [token[@"access_token"] copy];
    NSString *openId = [token[@"openid"] copy];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            DDLogError(@"Get wechat token error:%@",error);
            [self callHandlerInMainThreadWithResponse:nil andError:error];
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *userJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        ENToken *enToken = [ENWechatLoginProvider tokenFromJson:token];
        ENUser *user = [ENWechatLoginProvider userFromJson:userJson];
        
        ENSocialLoginResponse *resp = [[ENSocialLoginResponse alloc] initWithToken:enToken andUser:user];
        
        [self callHandlerInMainThreadWithResponse:resp andError:nil];
        
    }];
    
    [task resume];
}

- (void)callHandlerInMainThreadWithResponse:(ENSocialLoginResponse *)resp andError:(NSError *)error
{
    if (!self.handler) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.handler(resp,error);
        
    });
    
}

+ (ENToken *)tokenFromJson:(NSDictionary *)tokenJson
{
    ENToken *token = [ENToken new];
    
    token.token = [tokenJson[@"access_token"] copy];
    //token.expired = [tokenJson[@"expires_in"] integerValue];
    token.refreshToken = [tokenJson[@"refresh_token"] copy];
    
    return token;
}

+ (ENUser *)userFromJson:(NSDictionary *)userJson
{
    ENUser *user = [ENUser new];
    user.userId = userJson[@"openid"];
    user.name = userJson[@"nickname"];
    user.avatarUrl = userJson[@"headimgurl"];
    
    return user;
}

@end
