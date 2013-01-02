//
//  UIViewController+DoubanAlbum.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "UIViewController+DoubanAlbum.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (DoubanAlbum)

- (void)setBackLeftBarButtonItem{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"btn_back_tapped.png"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)doBack:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSuccessTips:(NSString *)text{
    [self showTipsWithImage:[UIImage imageNamed:@"tips_ok.png"] text:text hidden:YES];
}

- (void)showFailTips:(NSString *)text{
    [self showTipsWithImage:[UIImage imageNamed:@"tips_wrong.png"] text:text hidden:YES];
}

- (void)showFailTips:(NSString *)text hidden:(BOOL)hidden{
    [self showTipsWithImage:[UIImage imageNamed:@"tips_wrong.png"] text:text hidden:hidden];
}

- (void)showTipsWithImage:(UIImage *)image text:(NSString *)text hidden:(BOOL)hidden{
    UIView *view = [self.view subviewWithTag:1009];
    if (view) return;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 115, 115)];
    view.tag = 1009;
    CGPoint center = self.view.center;
    center.y = center.y-(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?100:50);
    view.center = center;
    view.alpha = 0;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
    imgView.image = [[UIImage imageNamed:@"tips_bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [view addSubview:imgView];
    
    UIImageView *logView = [[UIImageView alloc] initWithImage:image];
    logView.center = CGPointMake(view.height*0.5, 45);
    [view addSubview:logView];
    
    UILabel *textLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, logView.bottom+5, view.width-10, 21)];
    textLbl.textAlignment = NSTextAlignmentCenter;
    textLbl.backgroundColor = RGBCOLOR(246, 241, 226);
    textLbl.text = text;
    textLbl.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview:textLbl];
    
    [self.view addSubview:view];
    
    CATransform3D transform0 = CATransform3DMakeScale(0.001, 0.001, 1.0);
	view.layer.transform = transform0;
	CATransform3D transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    
    view.layer.opacity = 0.0;
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         view.layer.transform = transform;
                         view.layer.opacity = 1;
                     } completion:^(BOOL finished) {
                         if (hidden) {
                             [UIView animateWithDuration:0.3
                                                   delay:0.7
                                                 options:UIViewAnimationCurveEaseOut
                                              animations:^{
                                                  view.layer.transform = transform0;
                                                  view.layer.opacity = 0;
                                              } completion:^(BOOL finished) {
                                                  [view removeFromSuperview];
                                              }];
                         }
                     }];
}

- (void)showCheckMarkTips{
    UIView *view = [self.view subviewWithTag:1009];
    if (view) return;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    view.tag = 1009;
    view.center = self.view.center;
    view.alpha = 0;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(25, 25)];
    maskLayer.path = path.CGPath;
    view.layer.mask = maskLayer;
    
    view.backgroundColor = [UIColor blackColor];
    view.clipsToBounds = YES;
    
    UIImage *image = [UIImage imageNamed:@"checkmark.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.center = CGPointMake(view.width*0.5, view.height*0.5);
    imgView.backgroundColor = [UIColor clearColor];
    [view addSubview:imgView];
    
    [self.view addSubview:view];
    
    CATransform3D transform0 = CATransform3DMakeScale(0.001, 0.001, 1.0);
	view.layer.transform = transform0;
	CATransform3D transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    
    view.layer.opacity = 0.0;
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         view.layer.transform = transform;
                         view.layer.opacity = 1;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0.7
                                             options:UIViewAnimationCurveEaseOut
                                          animations:^{
                                              view.layer.transform = transform0;
                                              view.layer.opacity = 0;
                                          } completion:^(BOOL finished) {
                                              [view removeFromSuperview];
                                          }];
                     }];
}

@end
