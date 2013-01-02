//
//  DASettingViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BundleHelper : NSObject

+ (NSString *)bundleApplicationId;

+ (NSString *)bundleNameString;

+ (NSString *)bundleDisplayNameString;

+ (NSString *)bundleShortVersionString;

+ (NSString *)bundleBuildVersionString;

+ (NSString *)bundleIdentifierString;

+ (NSArray *)bundleURLTypes;

/////
+ (NSString *)bundleUnderlineVersionString;

+ (NSString *)bundleFullVersionString;
@end
