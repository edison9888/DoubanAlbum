//
//  DASettingViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "DASettingViewController.h"
#import "DADoubanActivity.h"
#import "DAWeixinActivity.h"
#import "AFImageRequestOperation.h"
#import "SDImageCache.h"
#import "UIButton+WebCache.h"
#import "DoubanAuthEngine.h"
#import "DOUOAuthStore.h"
#import "DALoginViewController.h"
#import "DAHtmlRobot.h"
#import "UIView+Indicator.h"
#import "UIImageView+AFNetworking.h"
#import "WXApi.h"

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 1;

@interface DASettingViewController ()

@end

@implementation DASettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIImage *backImg = [UIImage imageNamed:@"btn_cancel.png"];
        UIImage *backImgTapped = [UIImage imageNamed:@"btn_cancel_tapped.png"];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [backBtn setImage:backImg forState:UIControlStateNormal];
        [backBtn setImage:backImgTapped forState:UIControlStateHighlighted];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.rightBarButtonItem = backItem;
    }
    
    return self;
}

- (void)doCancel:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.tableView.bounds];
    bgImgView.image = [UIImage imageWithFileName:@"tb_bg_album-568h" type:@"jpg"];
    bgImgView.opaque = YES;
    self.tableView.backgroundView = bgImgView;
    
    UIScrollView *scrollView = (UIScrollView *)[self.tableView tableHeaderView];
    NSUInteger count = self.recommendApps.count+1;
    
    CGFloat offsetX = 10;
    scrollView.contentSize = CGSizeMake(count*60+2*offsetX, scrollView.height);
    
    NSArray *apps = @[@"app_doubanfm", @"app_gezbox", @"app_appflow", @"app_flava", @"app_ocarina", @"app_breadtrip"];
    
    int i = 0;
    for (; i<count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(offsetX+i*(44+16), 18, 44, 44);
        button.adjustsImageWhenHighlighted = NO;
        
        button.tag = i;
        if (i<count-1) {
            NSDictionary *appDic = [self.recommendApps objectAtIndex:i];
            NSString *picUrl = appDic[@"pic_url"];
            
            NSString *appPicName = [appDic objectForKey:@"name_s"];
            if ([apps containsObject:appPicName]) {
                [button setImage:[UIImage imageNamed:appPicName] forState:UIControlStateNormal];
            }else{
                button.layer.cornerRadius = 8;
                button.clipsToBounds = YES;
                
                NSString *url = [NSString stringWithFormat:@"http://%@", picUrl];
                
                NSURL *URL = [NSURL URLWithString:url];
                [button setImageWithURL:URL forState:UIControlStateNormal];
            }
            
            [button addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
        }else{
            [button setImage:[UIImage imageNamed:@"app_next.png"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(sendAppRecommend) forControlEvents:UIControlEventTouchUpInside];   
        }
        
        CALayer *layer = [CALayer layer];
        UIImage *image = [UIImage imageNamed:@"bg_app_shadow.png"];
        layer.contents = (id)image.CGImage;
        layer.frame = (CGRect){button.left, button.bottom-4, image.size};
        [scrollView.layer addSublayer:layer];
        
        [scrollView addSubview:button];
    }
    
    _authSwitchBtn.selected = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    
    for (int i=0; i<3; i++) {
        CGRect frame;
        if (i==0) {
            frame = CGRectMake(-1, 83, self.view.width+2, 50);
        }else if(i==1){
            frame = CGRectMake(-1, 147, self.view.width+2, 140);
        }else{
            frame = CGRectMake(-1, 302, self.view.width+2, 95);
        }
        
        UIImage *image = [UIImage imageNamed:@"bg_setting_cell.png"];
        image = [image stretchableImageWithLeftCapWidth:22.5 topCapHeight:15];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        imgView.frame = frame;
        
        [self.tableView addSubview:imgView];
    }
}

- (void)openApp:(UIButton *)button{
    [self touchUp:button];
    
    _selectedAppDic = [self.recommendApps objectAtIndex:button.tag];
    
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:_selectedAppDic[@"name"] message:NSLocalizedString(@"需要打开itunes查看吗?", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"去看看", nil), nil];
    [alert show];
}

- (void)touchDown:(UIButton *)button{
    button.top = 10;
}

- (void)touchUp:(UIButton *)button{
    button.top = 18;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == 1) {
        if (row == 0) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell showIndicatorViewAtpoint:CGPointMake(280, 12)];
            
            [self performSelector:@selector(cleanDoubanCacheData:) withObject:cell afterDelay:0.3];
            
        }else if(row == 1){
            [self recommendToFriends];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_COMMENT_LINK_iTunes]];
        }
    }else if(section == 2){
        if (row == 0) {
            [self sendFeedback];
        }else if(row == 1){
            
        }
    }
}

- (void)cleanDoubanCacheData:(UITableViewCell *)cell{
    [DAHtmlRobot emptyDisk];
    [DAHtmlRobot initialCacheFolder];
    [[UIImageView sharedImageCache] removeAllObjects];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [cell hideIndicatorView];
}

#pragma mark - Actions

- (void)recommendToFriends{
    NSString *text = @"推荐iOS应用 【豆瓣相册 精选集】";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Icon@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];

    NSURL *url = [NSURL URLWithString:APP_STORE_LINK_http];
    NSArray *activityItems = @[text, url, image];
    
    DADoubanActivity *doubanActivity = [[DADoubanActivity alloc] init];
    NSMutableArray *activities = [NSMutableArray arrayWithObject:doubanActivity];
    doubanActivity.isRecommendApp = YES;
    if ([WXApi isWXAppSupportApi]) {
        DAWeixinActivity *weixinActivity = [[DAWeixinActivity alloc] init];
        weixinActivity.isRecommendApp = YES;
        weixinActivity.sheetDelegate = self;
        [activities addObject:weixinActivity];
    }

    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
    
//    UIActivity
    [activityView setExcludedActivityTypes:@[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToFacebook, UIActivityTypeAssignToContact]];
    
    [self presentViewController:activityView animated:YES completion:nil];

//    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//    
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
//    {
//        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
//            
//            [fbController dismissViewControllerAnimated:YES completion:nil];
//            
//            switch(result){
//                case SLComposeViewControllerResultCancelled:
//                default:
//                {
//                    NSLog(@"Cancelled.....");
//                    
//                }
//                    break;
//                case SLComposeViewControllerResultDone:
//                {
//                    NSLog(@"Posted....");
//                }
//                    break;
//            }};
//        
//        [fbController addImage:[UIImage imageNamed:@"1.jpg"]];
//        [fbController setInitialText:@"Check out this article."];
//        [fbController addURL:[NSURL URLWithString:@"http://soulwithmobiletechnology.blogspot.com/"]];
//        
//        [fbController setCompletionHandler:completionHandler];
//        [self presentViewController:fbController animated:YES completion:nil];
//    }
}

- (void)sendAppRecommend{
    [self sendEmailWithSubject:NSLocalizedString(@"推荐应用", nil) body:NSLocalizedString(@"\n\n发现有趣的应用？推荐给我们吧。", nil)];
}

- (void)sendFeedback{
    [self sendEmailWithSubject:NSLocalizedString(@"推荐相册/意见反馈", nil) body:nil];
}

- (void)sendEmailWithSubject:(NSString *)subject body:(NSString *)body {
    if (NSClassFromString(@"MFMailComposeViewController")){
        if (![MFMailComposeViewController canSendMail]) {
//            if([[UIApplication sharedApplication] canOpenURL:URL]){
//                [[UIApplication sharedApplication] openURL:URL];
//            }else{
//                [UserFriendlyCenter showHintViewWithText:NSLocalizedString(@"无法发送邮件", nil)];
//            }
        }else{
            MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
            mailVC.mailComposeDelegate = self;
            
            // Set up recipients
            NSArray *toRecipients = [NSArray arrayWithObject:@"slowslab@gmail.com"];
            
            [mailVC setToRecipients:toRecipients];
            
            [mailVC setSubject:subject];
            [mailVC setMessageBody:body isHTML:NO];
            
            [self presentViewController:mailVC animated:YES completion:nil];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)authDouban:(UIButton *)button {
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        
        [[DOUOAuthStore sharedInstance] clear];
        [DADataEnvironment clear];
        
        _authSwitchBtn.selected = NO;
    }else{
        DALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DALoginViewController"];
        loginVC.finishedBlock = ^(id vc, id obj){
            DoubanAuthEngine *engine = [DoubanAuthEngine sharedDoubanAuthEngine];
            
            _authSwitchBtn.selected = [engine isValid];
        };
        
        UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        UIImage *nvImg = [UIImage imageNamed:@"bg_nav.png"];
        [nVC.navigationBar setBackgroundImage:nvImg forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:nVC animated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

#define BUFFER_SIZE 1024 * 100

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 || buttonIndex == 1) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"豆瓣相册 精选集";
        message.description = @"查看豆友推荐最多的相册,同时你也可以收藏感兴趣的相册";
        
        if (buttonIndex == 0) {
            [message setThumbImage:[UIImage imageNamed:@"Icon.png"]];
        }else{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"share_weixin_timeline" ofType:@"jpg"];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
            [message setThumbImage:image];
        }
        
        WXAppExtendObject *ext = [WXAppExtendObject object];
        ext.extInfo = @"<xml>豆瓣相册 精选集</xml>";
        ext.url = APP_STORE_LINK_http;
        
        Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
        memset(pBuffer, 0, BUFFER_SIZE);
        NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
        free(pBuffer);
        
        ext.fileData = data;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = buttonIndex;
        
        [WXApi sendReq:req];

//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Icon@2x" ofType:@"png"];
//        
//        WXMediaMessage *message = [WXMediaMessage message];
//        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//        [message setThumbImage:image];
//        
//        WXImageObject *imageObj = [WXImageObject object];
//        imageObj.imageData = [NSData dataWithContentsOfFile:filePath];
//        message.mediaObject = imageObj;
//        
//        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//        
//        req.bText = NO;
//        req.scene = buttonIndex;
//        
//        req.message = message;
//        
//        [WXApi sendReq:req];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *url = _selectedAppDic[@"itunes_url"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
