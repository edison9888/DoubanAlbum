//
//  DAMarksHelper.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAMarksHelper.h"
#import "SINGLETONGCD.h"

@implementation DAMarksHelper

SINGLETON_GCD(DAMarksHelper);

+ (void)showHomeMarksInViewController:(UIViewController *)viewController {
    NSString *key = [NSString stringWithFormat:@"Key_Show_Home_Marks_v%@", [BundleHelper bundleShortVersionString]];
    if ([USER_DEFAULT boolForKey:key]) return;
    [USER_DEFAULT setBool:YES forKey:key];
    [USER_DEFAULT synchronize];
    
    UIView *view = viewController.view;
    
    UIView *marksView = [[UIView alloc] initWithFrame:view.bounds];
    marksView.alpha = 0;
    marksView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    marksView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [view addSubview:marksView];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMarks:)];
    [marksView addGestureRecognizer:gesture];
    
    UIImage *image = [UIImage imageNamed:@"marks_home.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    
    imgView.center = UIInterfaceOrientationIsPortrait(viewController.interfaceOrientation)?view.center:CGPointMake(view.center.y, view.center.x);
    
    imgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [marksView addSubview:imgView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         marksView.alpha = 1.0;
                     }];
}

+ (void)showPhotoWallMarksInViewController:(UIViewController *)viewController{
    NSString *key = [NSString stringWithFormat:@"Key_Show_PhotoWall_Marks_v%@", [BundleHelper bundleShortVersionString]];
    if ([USER_DEFAULT boolForKey:key]) return;
    [USER_DEFAULT setBool:YES forKey:key];
    [USER_DEFAULT synchronize];
    
    UIView *view = viewController.view;
    
    UIView *marksView = [[UIView alloc] initWithFrame:view.bounds];
    marksView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    marksView.alpha = 0;
    marksView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [view addSubview:marksView];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMarks:)];
    [marksView addGestureRecognizer:gesture];
    
    UIImageView *imgView0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marks_back.png"]];
    imgView0.center = CGPointMake(67.5, 68);
    [marksView addSubview:imgView0];
    
    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marks_peo.png"]];
    imgView1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    imgView1.center = CGPointMake((UIInterfaceOrientationIsPortrait(viewController.interfaceOrientation)?APP_SCREEN_WIDTH:APP_SCREEN_HEIGHT)-61, 80.5);
    [marksView addSubview:imgView1];
    
    UIImageView *imgVie2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marks_tips.png"]];
    imgVie2.center = UIInterfaceOrientationIsPortrait(viewController.interfaceOrientation)?view.center:CGPointMake(view.center.y, view.center.x);
    
    imgVie2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [marksView addSubview:imgVie2];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         marksView.alpha = 1.0;
                     }];
}

+ (void)hideMarks:(UITapGestureRecognizer *)gesture{
    UIView *view = gesture.view;
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 0.0;
                     }completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

@end
