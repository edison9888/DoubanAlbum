//
//  DASettingViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DASettingViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>{
    
    __weak IBOutlet UIButton *_authSwitchBtn;
    
        NSDictionary        *_selectedAppDic;
}

@property (nonatomic, strong) NSArray *recommendApps;

@end
