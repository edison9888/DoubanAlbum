//
//  DAWebViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-13.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAWebViewController.h"
#import "UIView+Indicator.h"
//#import "GCDHelper.h"

@interface DAWebViewController ()

@end

@implementation DAWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackLeftBarButtonItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView.scrollView.delegate = self;
    
    [_webView loadRequest:[self URLRequest]];
}

- (NSURLRequest *)URLRequest{
    if(_userIdForAlbum){
        static NSString * const kUserUrlFomater = @"http://www.douban.com/people/%@";
        
        return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kUserUrlFomater, _userIdForAlbum]]];
    }
    
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.douban.com"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (IBAction)forward:(id)sender {
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (IBAction)update:(UIBarButtonItem *)item {
    [_webView reload];
}

//static BOOL NeedAutoZoom = NO;

//#pragma mark - UIWebViewDelegate

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    if (navigationType != UIWebViewNavigationTypeBackForward) {
//        if ([self isLoadPepleProfile:request]) {
//            NeedAutoZoom = YES;
//            
//            _webView.hidden = YES;
//        }else{
//            _webView.hidden = YES;
//        }
//    }
//    
//    SLog(@"加载 url %@", request.URL);
//    return YES;
//}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _backBtn.enabled = [_webView canGoBack];
    _forwardBtn.enabled = [_webView canGoForward];
    
    _updateBtn.enabled = YES;
    
//    SLLog(@"%@", NeedAutoZoom?@"YES":@"NO");
//    if (NeedAutoZoom) {
//        _webView.scrollView.zoomScale = 0;
//        [_webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 100, 100) animated:NO];
//        [self performSelector:@selector(zoomToProfile) withObject:nil afterDelay:0.3];
//    }else{
//        _webView.hidden = NO;
//        
//        _webView.scrollView.zoomScale = 0;
//        [_webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 100, 100) animated:NO];
//    }
}
//
//- (BOOL)isLoadPepleProfile:(NSURLRequest *)request{
//    NSString *url = [request.URL absoluteString];
//    NSString *pre = @"http://www.douban.com/people";
//    if ([url hasPrefix:pre] && url.length > pre.length) {
//        NSString *para = [url substringFromIndex:pre.length+1];
//        NSArray *paras = [para componentsSeparatedByString:@"/"];
//        
//        if (paras.count == 1) {
//            return YES;
//        }else{
//            return ([[paras objectAtIndex:1] length] == 0);
//        }
//    }
//    
//    return NO;
//}
//
//- (void)zoomToProfile{
//    _webView.scrollView.zoomScale = 2.95;
//}
//
//#pragma mark - UIScrollViewDelegate
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
//    if (NeedAutoZoom) {
//        NeedAutoZoom = NO;
//        
//        [scrollView scrollRectToVisible:CGRectMake(840, 142, 100, 100) animated:NO];
//        _webView.hidden = NO;
//    }
//}

@end
