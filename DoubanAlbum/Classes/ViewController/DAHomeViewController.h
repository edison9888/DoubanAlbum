//
//  DAHomeViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-8.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>{
    NSDictionary            *_appData;
    
    NSDictionary            *_dataSource;
    NSUInteger              _seletedCategory;
    
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UICollectionView *_collectionView;
    
    UIButton                *_refreshBtn;
    
    NSUInteger              _lastSelectedRow;
}


- (void)checkCagetory:(UIButton *)button;

@end
