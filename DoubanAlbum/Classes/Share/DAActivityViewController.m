//
//  DAActivityViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-17.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DAActivityViewController.h"
#import "DAHttpClient.h"
#import "NSStringAddition.h"
#import "UIView+Indicator.h"
#import "WXApi.h"
#import "DADoubanActivity.h"

@interface DAActivityViewController ()

@end

@implementation DAActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [_textView becomeFirstResponder];
    
    if (_shareInfo.count > 0) {
        NSString *text = _shareInfo[0];
        _textView.text = text;
        
        NSUInteger length = text.length;
        _numLbl.text = [@(length) description];
        _sendBtn.enabled = (length>0);
        
        id image = [_shareInfo lastObject];
        if ([image isMemberOfClass:[UIImage class]]) {
            _imgView.image = image;
            _imgView.clipsToBounds = YES;
            _imgView.layer.cornerRadius = 4;
        }
    }
    
    if (self.isRecommendApp) {
        _urlLbl.text = APP_STORE_LINK_http;
    }else{
        _urlLbl.text = _shareInfo[1];
    }
    
    _containerView.layer.cornerRadius = 10;
    _containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _containerView.layer.shadowOpacity = 0.9;
    _containerView.layer.shadowRadius = 20;
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sendImageContent
{
    WXMediaMessage *message = [WXMediaMessage message];
    UIImage *image = [UIImage imageNamed:@"Icon.png"];
    [message setThumbImage:image];
    WXImageObject *ext = [WXImageObject object];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Icon@2x" ofType:@"png"];
    ext.imageData = [NSData dataWithContentsOfFile:filePath] ;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;  //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    [WXApi sendReq:req];
}

- (void)textViewDidChange:(UITextView *)textView{
    NSUInteger length = textView.text.length;
    _numLbl.text = [@(length) description];
    _sendBtn.enabled = (length>0);
}

- (IBAction)send:(id)sender {
    NSString *text = [_textView.text trimmedWhitespaceAndNewlineString];
    
    NSMutableDictionary *para = [@{@"text":[NSString stringWithFormat:@"%@ %@", text, APP_STORE_LINK_http]} mutableCopy];
    if (_shareInfo.count > 1) {
        para[@"image"] = [_shareInfo lastObject];
    }
    
//    if (self.isRecommendApp) {
//        para[@"rec_title"] = @"iOS应用 ";
//        para[@"rec_url"] = APP_STORE_LINK_http;
//        para[@"rec_desc"] = @"查看豆友推荐最多的相册,同时你也可以收藏感兴趣的相册";
//    }
    
    [self showIndicatioView];
    [DAHttpClient doubanShuoWithParameters:para
                                   success:^{
                                       [self cancel:nil];
                                       
                                       UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                                       if ([vc isMemberOfClass:[UINavigationController class]]){
                                           [((UINavigationController *)vc).topViewController showSuccessTips:NSLocalizedString(@"分享成功", nil)];
                                       }
                                   } error:^(NSInteger index) {
                                       [self hideIndicatorView];
                                       
                                       if (index != 100) {
                                           [self showFailTips:NSLocalizedString(@"分享出错", nil)];
                                       }
                                   } failure:^(NSError *error) {
                                       [self hideIndicatorView];
                                       
                                       [self showFailTips:NSLocalizedString(@"分享失败", nil)];
                                   }viewController:self];
}

- (void)showIndicatioView{
    [_sendBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_sendBtn setTitle:nil forState:UIControlStateNormal];
    
    [_sendBtn showIndicatorView];
}

- (void)hideIndicatorView{
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_share_send.png"] forState:UIControlStateNormal];
    [_sendBtn setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    
    [_sendBtn hideIndicatorView];
}

- (IBAction)cancel:(id)sender {
    [self.doubanActivity activityDidFinish:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _containerView.top = 25;
        _containerView.height = 190;
        
        _cancelBtn.top = 7;
        _sendBtn.top = 7;
        _cancelBtn.height = 30;
        _sendBtn.height = 30;
    }else{
        _containerView.top = 0;
        _containerView.height = 145;
        
        _cancelBtn.top = 5;
        _sendBtn.top = 5;
        _cancelBtn.height = 25;
        _sendBtn.height = 25;
    }
}

#pragma mark - NSNotificationCenter

- (void) keyboardWillShow:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    NSNumber *value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect keyboardBounds;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
	CGFloat height = keyboardBounds.size.height;
    
    [UIView animateWithDuration:[value floatValue]
                     animations:^{
                         if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                             _containerView.top = (self.view.height-height-190)*0.5;
                         }else{
                             _containerView.top = MAX((self.view.width-height-145)*0.5, 0);
                         }
                     }completion:^(BOOL finished) {
                     }];
}

- (void) keyboardWillHidden:(NSNotification *) notif{
    [UIView animateWithDuration:0.3f
                     animations:^{
                     }];
}


@end
