//
//  DAMarksHelper.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAMarksHelper : NSObject

+ (DAMarksHelper *)sharedDAMarksHelper;

+ (void)showHomeMarksInViewController:(UIViewController *)viewController;

+ (void)showPhotoWallMarksInViewController:(UIViewController *)viewController;

@end
