//
//  APIManager.m
//  baobozhineng
//
//  Created by 魏俊阳 on 2017/12/24.
//  Copyright © 2017年 魏俊阳. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager
+ (APIManager *)sharedManager
{
    static APIManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (NSString*)getPathWithInterface:(NSString*)str
{
    NSString *path = [NSString stringWithFormat:@"%@%@",API_HOST,str];
    return path;
}
//发送验证码
- (void)sendCodeWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure {
    
    NSString *path = [self getPathWithInterface:@"/user/index/sendCode"];
    [AFNHttpTool postRequestWithUrl:path params:dic success:success failure:failure];
    //    [AFNHttpTool getRequestWithUrl:path params:dic success:success failure:failure];
}
//注册用户
- (void)registerWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure {
    
    NSString *path = [self getPathWithInterface:@"/user/index/register"];
    [AFNHttpTool postRequestWithUrl:path params:dic success:success failure:failure];
}
//用户登录
- (void)loginWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure {
    
    NSString *path = [self getPathWithInterface:@"/user/index/login"];
    [AFNHttpTool postRequestWithUrl:path params:dic success:success failure:failure];
}
//忘记密码
- (void)forgetpwdWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure {
    
    NSString *path = [self getPathWithInterface:@"/user/index/forgetpwd"];
    [AFNHttpTool postRequestWithUrl:path params:dic success:success failure:failure];
}
@end

