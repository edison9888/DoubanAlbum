//
//  DAUserAblumsViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAUserAblumsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>{
    
    __weak IBOutlet UICollectionView *_collectionView;
    NSMutableArray      *_dataSource;
}

@property (nonatomic, strong) NSString *userIdForAlbum;
@property (nonatomic, strong) NSString *userAvatar;
@end
