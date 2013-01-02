//
//  DAWebViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-13.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAWebViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>{
    
    __weak IBOutlet UIWebView *_webView;
    
    
    __weak IBOutlet UIBarButtonItem *_backBtn;
    
    __weak IBOutlet UIBarButtonItem *_forwardBtn;
    __weak IBOutlet UIBarButtonItem *_updateBtn;
}

@property (nonatomic, strong) NSString *userIdForAlbum;
@end
