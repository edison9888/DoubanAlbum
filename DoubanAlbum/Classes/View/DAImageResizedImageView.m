//
//  DAImageResizedImageView.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-21.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DAImageResizedImageView.h"
#import "UIImage+Resize.h"
#import "GCDHelper.h"

@implementation DAImageResizedImageView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
        self.layer.borderWidth = 0.5;
    }
    
    return self;
}

- (void)setImage:(UIImage *)image{
    self.alpha = 0;
    
    __block UIImage *result = nil;
    [GCDHelper resizeImageInBackground:^{
        CGSize size = CGSizeMake(self.size.width*2, self.size.height*2);
        
        result = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                      bounds:size
                                        interpolationQuality:kCGInterpolationHigh];
    } completion:^{
        [super setImage:result];
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.alpha = 1;
                         } completion:^(BOOL finished) {
                             
                         }];
    }];
}

@end
