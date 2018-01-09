//
//  APIManager.h
//  baobozhineng
//
//  Created by 魏俊阳 on 2017/12/24.
//  Copyright © 2017年 魏俊阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNHttpTool.h"

#define  API_HOST  @"http://47.94.6.236:81" //正式环境
//#define  API_HOST  @"" //测试环境

@interface APIManager : NSObject
///单例对象
+ (APIManager *)sharedManager;
//发送验证码
- (void)sendCodeWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure;
//注册用户
- (void)registerWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure;
//用户登录
- (void)loginWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure;
//忘记密码
- (void)forgetpwdWithParameters:(NSDictionary *)dic success:(void(^)(id data))success failure:(void(^)(NSError *error))failure;
@end

