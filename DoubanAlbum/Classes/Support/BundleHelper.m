//
//  BundleHelper.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "BundleHelper.h"
#import "NSStringAddition.h"

@implementation BundleHelper

+ (NSString *)bundleApplicationId{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
}

//豆瓣相册
+ (NSString *)bundleNameString{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
}

//豆瓣相册
+ (NSString *)bundleDisplayNameString{
    static NSString *key = @"CFBundleDisplayName";
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

//1.0.0
+ (NSString *)bundleShortVersionString{
    static NSString *key = @"CFBundleShortVersionString";
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

//2938
+ (NSString *)bundleBuildVersionString{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

//com.slowslab.doubanalbum
+ (NSString *)bundleIdentifierString{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
}

//{CFBundleTypeRole:,CFBundleURLIconFile:,CFBundleURLName:,CFBundleURLSchemes:}
+ (NSArray *)bundleURLTypes{
    static NSString *key = @"CFBundleURLTypes";
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

////////////////////

//3_0_0
+ (NSString *)bundleUnderlineVersionString{

    NSString *version = [BundleHelper bundleShortVersionString];
    NSString *underlineVersion = [version replaceDotWithUnderline];
    return underlineVersion;
}

//3.0.0.2938
+ (NSString *)bundleFullVersionString{
    NSString *version = [BundleHelper bundleShortVersionString];
    NSString *build = [BundleHelper  bundleBuildVersionString];
    
    return [NSString stringWithFormat:@"%@.%@", version, build];
}

@end
