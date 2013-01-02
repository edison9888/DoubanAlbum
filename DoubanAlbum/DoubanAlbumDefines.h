//
//  DoubanAlbumDefines.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-9.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#ifndef DoubanAlbum_DoubanAlbumDefines_h
#define DoubanAlbum_DoubanAlbumDefines_h

#warning
#define NEED_OUTPUT_LOG                     0

#define USER_DEFAULT                [NSUserDefaults standardUserDefaults]

#define APP_CACHES_PATH             [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define APP_SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define APP_SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

#define APP_SCREEN_CONTENT_HEIGHT   ([UIScreen mainScreen].bounds.size.height-20.0)

#define IS_4_INCH                   (APP_SCREEN_HEIGHT > 480.0)

#define RGBCOLOR(r,g,b)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define APP_STORE_LINK_http                 @"https://itunes.apple.com/cn/app/dou-ban-xiang-ce-jing-xuan-ji/id588070942?ls=1&mt=8"
#define APP_STORE_LINK_iTunes               @"itms-apps://itunes.apple.com/cn/app/id588070942?mt=8"

#define APP_COMMENT_LINK_iTunes             @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=588070942"

#define IMAGE_CACHE     [SDImageCache sharedImageCache]
#define NOTIFICATION_CENTER         [NSNotificationCenter defaultCenter]

#if NEED_OUTPUT_LOG

    #define SLog(xx, ...)   NSLog(xx, ##__VA_ARGS__)
    #define SLLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

    #define SLLogRect(rect) \
    SLLog(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
    rect.size.width, rect.size.height)

    #define SLLogPoint(pt) \
    SLLog(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

    #define SLLogSize(size) \
    SLLog(@"%s w=%f, h=%f", #size, size.width, size.height)

    #define SLLogColor(_COLOR) \
    SLLog(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

    #define SLLogSuperViews(_VIEW) \
    { for (UIView* view = _VIEW; view; view = view.superview) { SLLog(@"%@", view); } }

    #define SLLogSubViews(_VIEW) \
    { for (UIView* view in [_VIEW subviews]) { SLLog(@"%@", view); } }

#else

    #define SLog(xx, ...)  ((void)0)
    #define SLLog(xx, ...)  ((void)0)

#endif

#endif
