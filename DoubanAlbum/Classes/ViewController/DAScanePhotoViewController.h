//
//  DAScanePhotoViewController.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAScanePhotoViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>{
    
    __weak IBOutlet UICollectionView *_collectionView;
    
    
    __weak IBOutlet UIButton *_downloadBtn;
}

@property (nonatomic, assign) NSMutableArray    *dataSource;
@property (nonatomic) NSUInteger selectedItem;

@property (nonatomic, strong) NSDictionary *albumTitleAndDescribe;

//@property (nonatomic, assign) UIViewController *photoWallVC;
@end
