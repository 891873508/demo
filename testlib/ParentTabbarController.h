//
//  ParentTabbarController.h
//  TestNavgation
//
//  Created by 魏俊阳 on 2017/12/25.
//  Copyright © 2017年 魏俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentTabbarController : UITabBarController
+(instancetype)shareInstance;
@property(nonatomic,strong)NSArray *titleArray;
@property(nonatomic,strong)NSArray *colorArray;
@property(nonatomic,strong)NSArray *imgArray;
- (void)setBottomBar;
@end

