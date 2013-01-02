//
//  DACategoryViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-10.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DAHomeViewController;

@interface DACategoryViewController : UITableViewController

@property (nonatomic, assign) NSArray *dataSource;

@property (nonatomic, assign) DAHomeViewController *homeVC;

@end
