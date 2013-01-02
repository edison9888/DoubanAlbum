//
//  DAAppDelegate.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-8.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface DAAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
