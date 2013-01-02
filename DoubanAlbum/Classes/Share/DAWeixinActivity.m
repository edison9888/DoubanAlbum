//
//  DAWeixinActivity.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-14.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAWeixinActivity.h"
#import "WXApi.h"

@implementation DAWeixinActivity

- (NSString *)activityType {
    return @"Weixin";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"微信", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"share_weixin.png"];
}

- (UIViewController *)activityViewController {
    return nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    if (_isRecommendApp) { //推荐豆瓣相册
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"推荐应用 豆瓣相册 精选集", nil) delegate:self.sheetDelegate cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"分享给好友", nil), NSLocalizedString(@"分享到朋友圈", nil), nil];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [sheet showInView:window];
    }else{ //推荐豆瓣相册
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"分享到微信", nil) delegate:self.sheetDelegate cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"分享给好友", nil), NSLocalizedString(@"分享到朋友圈", nil), nil];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [sheet showInView:window];
    }
    
    [self activityDidFinish:YES];
}

@end
