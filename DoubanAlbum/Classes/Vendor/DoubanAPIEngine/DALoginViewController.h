//
//  DALoginViewController.h
//  DoubanAuthEngineDemo
//
//  Created by Lin GUO on 3/26/12.
//  Copyright (c) 2012 douban Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOUOAuthService.h"

@interface DALoginViewController : UIViewController<UIWebViewDelegate, DOUOAuthServiceDelegate>{
    
    __weak IBOutlet UIWebView *_webView;
}

@property (nonatomic, copy) SLFinishedBlock finishedBlock;

@end
