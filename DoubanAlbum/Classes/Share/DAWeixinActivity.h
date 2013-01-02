//
//  DAWeixinActivity.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-14.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAWeixinActivity : UIActivity <UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *activityItem;

@property (nonatomic) BOOL isRecommendApp;

@property (nonatomic, assign) id<UIActionSheetDelegate> sheetDelegate;
@end
