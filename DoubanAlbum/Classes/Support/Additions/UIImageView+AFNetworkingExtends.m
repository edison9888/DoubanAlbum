//
//  UIImageView+AFNetworkingExtends.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-22.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "UIImageView+AFNetworkingExtends.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Indicator.h"

@implementation UIImageView (AFNetworkingExtends)

- (void)setImageWithURL:(NSURL *)url showIndicator:(BOOL)indicator
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self showIndicatorView];

    [self setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        self.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

@end
