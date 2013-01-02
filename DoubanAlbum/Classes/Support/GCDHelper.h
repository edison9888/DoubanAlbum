//
//  GCDHelper.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDHelper : NSObject

+ (void)resizeImageInBackground:(SLBlock)block completion:(SLBlock)completion;

+ (void)loadCachedImage:(SLBlock)block completion:(SLBlock)completion;

+ (void)repeatBlock:(SLBlock)block withCount:(NSUInteger)count;

+ (void)dispatchBlock:(SLBlock)block completion:(SLBlock)completion;
@end
