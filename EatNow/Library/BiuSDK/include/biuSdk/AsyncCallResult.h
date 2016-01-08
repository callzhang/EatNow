#import <Foundation/Foundation.h>

/**
 * 异步调用回调参数
 */
@interface AsyncCallResult : NSObject

// 返回码
@property(nonatomic, assign) int code;

// 描述
@property(nonatomic, strong) NSString *message;

// 数据类名称
@property(nonatomic, strong) NSString *dataClsName;

// 数据
@property(nonatomic, strong) id data;

- (BOOL) isOk;

+ (AsyncCallResult *) resultWithCode:(int)code;

+ (AsyncCallResult *) resultWithCode:(int)code
                             message:(NSString *)message;

+ (AsyncCallResult *) resultWithCode:(int)code
                             message:(NSString *)message
                                data:(id)data;

+ (AsyncCallResult *) resultWithData:(NSData *)data;

- (void) print;

@end

