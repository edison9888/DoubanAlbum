//
//  DAAboutViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAboutViewController : UIViewController{
    __weak IBOutlet UIScrollView *_scrollView;
    
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UITextView *_textView;
    
    __weak IBOutlet UITextView *_aboutLabTextView;
    __weak IBOutlet UIButton *_aboutBtn;
    
    BOOL    _isShowLab;
    
//    __weak IBOutlet UIView *_aboutDAView;
//    __weak IBOutlet UIView *_aboutLabView;
    
    __weak IBOutlet UIButton *_weixinBtn;
    __weak IBOutlet UIButton *_doubanBtn;
}

@property (weak, nonatomic) IBOutlet UIView *aboutDAView;
@property (weak, nonatomic) IBOutlet UIView *aboutLabView;


@end
