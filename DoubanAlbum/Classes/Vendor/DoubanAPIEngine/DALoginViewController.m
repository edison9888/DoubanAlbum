//
//  DALoginViewController.m
//  DoubanAuthEngineDemo
//
//  Created by Lin GUO on 3/26/12.
//  Copyright (c) 2012 douban Inc. All rights reserved.
//

#import "DALoginViewController.h"
#import "DoubanAlbumDefines.h"
#import "DoubanAuthEngine.h"
#import "DoubanAPIDefines.h"
#import "UIViewController+DoubanAlbum.h"

@interface NSString (ParseCategory)
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue 
                                           outterGlue:(NSString *)outterGlue;
@end

@implementation NSString (ParseCategory)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue 
                                           outterGlue:(NSString *)outterGlue {
  // Explode based on outter glue
  NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
  NSArray *secondExplode;
  
  // Explode based on inner glue
  NSInteger count = [firstExplode count];
  NSMutableDictionary* returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
  for (NSInteger i = 0; i < count; i++) {
    secondExplode = 
    [(NSString*)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
    if ([secondExplode count] == 2) {
      [returnDictionary setObject:[secondExplode objectAtIndex:1] 
                           forKey:[secondExplode objectAtIndex:0]];
    }
  }
  return returnDictionary;
}

@end


@interface DALoginViewController ()

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURL *requestURL;

@end


@implementation DALoginViewController

@synthesize webView = webView_;
@synthesize requestURL = requestURL_;
@synthesize finishedBlock;

#pragma mark - View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *str = [NSString stringWithFormat:@"https://www.douban.com/service/auth2/auth?client_id=%@&redirect_uri=%@&response_type=code&scope=douban_basic_common,douban_basic_user,douban_basic_note,community_basic_photo,shuo_basic_w", kDouban_API_Key, kRedirectUrl];
        
        NSString *urlStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *URL = [NSURL URLWithString:urlStr];
        
        self.requestURL = URL;
        
        UIImage *backImg1 = [UIImage imageNamed:@"btn_cancel.png"];
        UIImage *backImgTapped1 = [UIImage imageNamed:@"btn_cancel_tapped.png"];
        
        UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        profileBtn.frame = CGRectMake(0, 0, 44, 44);
        [profileBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [profileBtn setImage:backImg1 forState:UIControlStateNormal];
        [profileBtn setImage:backImgTapped1 forState:UIControlStateHighlighted];
        
        UIBarButtonItem *profileItem = [[UIBarButtonItem alloc] initWithCustomView:profileBtn];
        self.navigationItem.rightBarButtonItem = profileItem;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"豆瓣授权", nil);

    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL_];
    [_webView loadRequest:request];
}

- (void)viewDidUnload {
  self.webView = nil;
  self.requestURL = nil;
  [super viewDidUnload];
}

- (IBAction)cancel:(id)sender {
    if (finishedBlock) {
        finishedBlock(self, nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
  [webView_ release];
  [requestURL_ release];
  [super dealloc];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView 
    shouldStartLoadWithRequest:(NSURLRequest *)request 
    navigationType:(UIWebViewNavigationType)navigationType {
  
    NSURL *urlObj =  [request URL];
    NSString *url = [urlObj absoluteString];
  
    SLLog(@"url %@", url);
   
    if ([url hasPrefix:kRedirectUrl]) {
        NSString* query = [urlObj query];
        NSMutableDictionary *parsedQuery = [query explodeToDictionaryInnerGlue:@"="
                                                                    outterGlue:@"&"];
        NSString *code = [parsedQuery objectForKey:@"code"];
        if (code) {
            //TODO
            DOUOAuthService *service = [DOUOAuthService sharedInstance];
            service.authorizationURL = kTokenUrl;
            service.clientId = kDouban_API_Key;
            service.clientSecret = kDouban_API_Secret;
            service.callbackURL = kRedirectUrl;
            
            service.delegate = self;
            
            service.authorizationCode = code;
            
            [service validateAuthorizationCode];
            
            return NO;
        }else{
            NSMutableDictionary *parsedQuery = [query explodeToDictionaryInnerGlue:@"="
                                                                        outterGlue:@"&"];
            NSString *error = [parsedQuery objectForKey:@"error"];
            SLLog(@"error %@", error);
            if ([error isEqualToString:@"access_denied"]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
  }
  
  return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    SLLog(@"error %@:\n %@", [error localizedDescription], error);
    NSString *errorUrl = [error userInfo][@"NSErrorFailingURLStringKey"];
    NSRange urlRange = [errorUrl rangeOfString:@"https://www.douban.com/service/auth2/auth?"];
    if (urlRange.location != NSNotFound) {
        [self showFailTips:NSLocalizedString(@"豆瓣出错了", nil) hidden:NO];
        SLLog(@"服务器连接不上");
    }
}


- (void)OAuthClient:(DOUOAuthService *)client didAcquireSuccessDictionary:(NSDictionary *)dic {
    SLLog(@"success!");

    finishedBlock(self, @(1));
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)OAuthClient:(DOUOAuthService *)client didFailWithError:(NSError *)error {
    SLLog(@"Fail!");
}

@end
