//
//  DAActivityViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-17.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DADoubanActivity;

@interface DAActivityViewController : UIViewController <UITextViewDelegate>{
    
    __weak IBOutlet UITextView *_textView;
    __weak IBOutlet UIView *_containerView;
    
    __weak IBOutlet UILabel *_numLbl;
    
    __weak IBOutlet UIButton *_cancelBtn;
    __weak IBOutlet UIButton *_sendBtn;
    
    __weak IBOutlet UIImageView *_imgView;
    
    __weak IBOutlet UILabel *_urlLbl;
}

@property (nonatomic) BOOL isRecommendApp;
@property (nonatomic, strong) NSArray *shareInfo;

@property (nonatomic, assign) DADoubanActivity *doubanActivity;

@end
