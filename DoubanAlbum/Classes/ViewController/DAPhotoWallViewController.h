//
//  DAPhotoWallViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-11.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAPhotoWallViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>{
    
    __weak IBOutlet UICollectionView *_collectionView;
    NSMutableArray              *_dataSource;
    
    UIInterfaceOrientation       _interfaceWhenDisappear;
}

@property (nonatomic, strong) NSDictionary *albumDic;
@property (nonatomic) BOOL canNotGotoUserAlbum;

@property (nonatomic) CGFloat paperIndicatorOffset;

- (NSUInteger)countOfAlbumTitleAndDescribe;

@end
