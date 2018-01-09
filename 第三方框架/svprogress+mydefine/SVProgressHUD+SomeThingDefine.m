//
//  SVProgressHUD+SomeThingDefine.m
//  baobozhineng
//
//  Created by 魏俊阳 on 2018/1/2.
//  Copyright © 2018年 魏俊阳. All rights reserved.
//

#import "SVProgressHUD+SomeThingDefine.h"

@implementation SVProgressHUD (SomeThingDefine)

+ (void)mydefineShowDismissTime:(NSTimeInterval)dismissTimes titile:(NSString *)title
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimes];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithDisplayP3Red:55 green:55 blue:55 alpha:0.4]];
//    [SVProgressHUD setBackgroundColor:RGBA(55, 55, 55, 0.4)];
}

+ (void)mydefineShowWithStatus:(NSString *)status
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithDisplayP3Red:55 green:55 blue:55 alpha:0.4]];
//    [SVProgressHUD setBackgroundColor:RGBA(55, 55, 55, 0.4)];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showWithStatus:status];
}

+ (void)mydefineErrorShowDismissTime:(NSTimeInterval)dismissTimes ErrorTitle:(NSString *)errorTitle
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setAnimationDelay:0.1];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimes];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithDisplayP3Red:55 green:55 blue:55 alpha:0.4]];
//    [SVProgressHUD setBackgroundColor:RGBA(55, 55, 55, 0.4)];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showErrorWithStatus:errorTitle];
}
+ (void)mydefineSuccessShowDismissTime:(NSTimeInterval)dismissTimes SuccessTitle:(NSString *)successTitle
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimes];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithDisplayP3Red:55 green:55 blue:55 alpha:0.4]];
//    [SVProgressHUD setBackgroundColor:RGBA(55, 55, 55, 0.4)];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showSuccessWithStatus:successTitle];
}
@end

