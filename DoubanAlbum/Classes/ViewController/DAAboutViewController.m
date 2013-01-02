//
//  DAAboutViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAAboutViewController.h"
#import "DAWebViewController.h"

@interface DAAboutViewController ()

@end

@implementation DAAboutViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackLeftBarButtonItem];
        self.title = NSLocalizedString(@"关于", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithFileName:@"tb_bg_album-568h" type:@"jpg"]];
    imgView.frame = self.view.bounds;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:imgView atIndex:0];
    
    _textView.text = NSLocalizedString(@"    豆瓣上有非常多有意思的相册，但是浏览起来不太方便。漫实验室尝试着开发这款应用，让查看豆瓣相册变得简单而且有趣。\n\n    精选的相册均来自豆瓣网上的豆友推荐，如有侵犯用户权益的地方，请主动联系，我们会在第一时间内从本应用中撤销。\n\n    本应用 遵循《豆瓣开发者服务使用条款》。ps:建议在Wifi下使用", nil);
    
    _aboutLabTextView.text = NSLocalizedString(@"    关于漫 实验室\n\n    漫实验室成员曾梦想在一周只上4天班的公司工作，最后不得不辞职组建了漫实验室，放慢脚步，去关心那些细微的美好。", nil);
    
    [_weixinBtn setTitle:NSLocalizedString(@"关注我们的微信", nil) forState:UIControlStateNormal];
    [_doubanBtn setTitle:NSLocalizedString(@"去豆瓣看看", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAboutLab:(id)sender {
    
//    [UIView transitionFromView:(_isShowLab? _aboutLabView : _aboutDAView)
//                        toView:(_isShowLab ? _aboutDAView : _aboutLabView)
//                      duration:1.0
//                       options:(_isShowLab ? UIViewAnimationOptionTransitionFlipFromRight :
//                                UIViewAnimationOptionTransitionFlipFromLeft)|UIViewAnimationOptionShowHideTransitionViews
//                    completion:^(BOOL finished) {
//                        _isShowLab = !_isShowLab;
//                    }
//     ];
}

- (IBAction)showSlowslabInfo:(UITapGestureRecognizer *)gesture {
    UIView *view = [gesture view];
    
    static BOOL isShow = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (isShow) {
                             view.top = self.view.height-50;
                         }else{
                             view.bottom = self.view.height;
                         }
                     }completion:^(BOOL finished) {
                         isShow = !isShow;
                     }];
        
}

- (void)hideWeixinFollowView:(UITapGestureRecognizer *)gesture{
    UIView *view = [self.view subviewWithTag:100];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1;
                     }completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

- (IBAction)followInWeixin:(id)sender {
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    view.alpha = 0;
    view.tag = 100;
    [self.view addSubview:view];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideWeixinFollowView:)];
    [view addGestureRecognizer:gesture];
    
//    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 280)];
//    bgImgView.image = [UIImage imageNamed:@"tips_papper.png"];
//    [view addSubview:bgImgView];
    
    UIImageView *codeImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width-100)*0.5, 80, 100, 100)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weixin_code" ofType:@"jpg"];
    codeImgView.image = [UIImage imageWithContentsOfFile:path];
    codeImgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:codeImgView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.width-220)*0.5, 220, 220, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"btn_aboutlab.png"] forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button setTitle:NSLocalizedString(@"下载二维码去微信扫一扫", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(downloadCode:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1;
                     }];
}

- (void)downloadCode:(UIButton *)button{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weixin_code" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(id)context{
    UIView *view = [self.view subviewWithTag:100];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1;
                     }completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
    
    [self showSuccessTips:NSLocalizedString(@"保存成功", nil)];
}

- (IBAction)showDoubanInfo:(id)sender {
    DAWebViewController *vc = (DAWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DAWebViewController"];
    vc.title = NSLocalizedString(@"漫 实验室", nil);
    
    vc.userIdForAlbum = @"66977260";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _scrollView.contentSize = _scrollView.size;
    }else{
        _scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height+40);
    }
}

@end
