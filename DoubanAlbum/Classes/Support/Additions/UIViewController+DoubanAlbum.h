//
//  UIViewController+DoubanAlbum.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DoubanAlbum)

- (void)setBackLeftBarButtonItem;

- (void)doBack:(UIButton *)button;

- (void)showSuccessTips:(NSString *)text;

- (void)showFailTips:(NSString *)text;

- (void)showFailTips:(NSString *)text hidden:(BOOL)hidden;

- (void)showCheckMarkTips;
@end
