//
//  DADoubanActivity.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-14.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DADoubanActivity.h"
#import "DAActivityViewController.h"

@implementation DADoubanActivity

- (NSString *)activityType {
    return @"Douban";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"豆瓣广播", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"share_douban.png"];
}

- (UIViewController *)activityViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    DAActivityViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DAActivityViewController"];
    vc.shareInfo = self.activityItem;
    vc.isRecommendApp = self.isRecommendApp;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    vc.doubanActivity = self;
    
    return vc;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.activityItem = activityItems;
}

@end
