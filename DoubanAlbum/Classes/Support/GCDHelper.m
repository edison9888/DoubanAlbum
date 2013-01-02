//
//  GCDHelper.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "GCDHelper.h"

static dispatch_queue_t resize_image_queue;
dispatch_queue_t image_resize_processing_queue() {
    if (resize_image_queue == NULL) {
        resize_image_queue = dispatch_queue_create("com.slowslab.image.resize.processing", 0);
    }
    
    return resize_image_queue;
}

static dispatch_queue_t load_cached_image_queue;
dispatch_queue_t load_cached_image_processing_queue() {
    if (load_cached_image_queue == NULL) {
        load_cached_image_queue = dispatch_queue_create("com.slowslab.load.cached.image.processing", 0);
    }
    
    return load_cached_image_queue;
}

@implementation GCDHelper

+ (void)resizeImageInBackground:(SLBlock)block completion:(SLBlock)completion{
    dispatch_async(image_resize_processing_queue(), ^{
        @autoreleasepool {
            block();
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

+ (void)loadCachedImage:(SLBlock)block completion:(SLBlock)completion{
    dispatch_async(load_cached_image_processing_queue(), ^{
        @autoreleasepool {
            block();
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

+ (void)repeatBlock:(SLBlock)block withCount:(NSUInteger)count{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_apply(count, queue, ^(size_t index){
            block();
        });
    });
}

+ (void)dispatchBlock:(SLBlock)block completion:(SLBlock)completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            block();
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        }
    });
}

@end
