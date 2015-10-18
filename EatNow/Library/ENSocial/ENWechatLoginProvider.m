//
//  WechatLoginProvider.m
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENWechatLoginProvider.h"
#import "WXApi.h"

//TODO: Store information in plist.
static NSString* const kWXAppId = @"wxe9edec710a521a3f";
static NSString* const kWXSecret = @"6f3735c124d9e664b71eab538285e777";

//App ID:wx99ee7ef09c01de75
//AppKey:3bfefd8b9832d2bb315ea1e008283b26

//static NSString* const kWXAppId = @"wx99ee7ef09c01de75";
//static NSString* const kWXSecret = @"3bfefd8b9832d2bb315ea1e008283b26";

static

@interface ENWechatLoginProvider () <WXApiDelegate>

@end

@implementation ENWechatLoginProvider

- (NSString *)name
{
    return @"wechat";
}

- (void)loginWithHandler:(ENSocialLoginHandler)handler
{
    [self sendAuthRequest];
}

- (void)logout
{
}

#pragma mark - wechat api delegate

- (void)onReq:(BaseReq *)req
{
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.errCode == 0) {
            [self getToekenByCode:authResp.code];
        }
        else{
            DDLogError(@"Get wechat auth code error");
        }
        
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

- (void)getToekenByCode:(NSString *)code
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWXAppId,kWXSecret,code];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            DDLogError(@"Get wechat token error:%@",error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *token = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
//        {
//            "access_token":"ACCESS_TOKEN",
//            "expires_in":7200,
//            "refresh_token":"REFRESH_TOKEN",
//            "openid":"OPENID",
//            "scope":"SCOPE",
//            "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
//        }
        
//        {"errcode":40029,"errmsg":"invalid code"}
        
        [self getUserInfoByToken:token];
        

    }];
    
    [task resume];
    
}

- (void)getUserInfoByToken:(NSDictionary *)token
{
}

@end
