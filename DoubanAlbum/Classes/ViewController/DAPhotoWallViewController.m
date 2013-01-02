//
//  DAPhotoWallViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-11.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAPhotoWallViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "DAHttpClient.h"
#import "DAWaterfallLayout.h"
#import "DAUserAblumsViewController.h"
#import "DAScanePhotoViewController.h"
#import "DADoubanActivity.h"
#import "DAWeixinActivity.h"
#import "DAHtmlRobot.h"
#import "WXApi.h"
#import "DAMarksHelper.h"
#import "DAWaterfallLayout.h"
#import "UIImage+Resize.h"

@interface DAPhotoWallViewController ()

@end

@implementation DAPhotoWallViewController{
    UIColor     *_albumNameColor;
    UIColor     *_albumDesColor;
    
    UILabel                     *_loadMoreTipsLbl;
    UIActivityIndicatorView     *_indicatorView;
    
    BOOL        _isLoadingMore;
    BOOL        _canotLoadMore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _albumNameColor = [DADataEnvironment colorForTitleAndDescribe];;
    _albumDesColor = [DADataEnvironment colorForTitleAndDescribe];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithFileName:@"tb_bg_album-568h" type:@"jpg"]];
    
    [self setBarButtonItems];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterViewIdentifier"];
    
    UIView *paperIndicator0 = [self.view viewWithTag:1];
    
    if (!_canNotGotoUserAlbum) {
        paperIndicator0.top = self.paperIndicatorOffset+10.0;
    }else{
        UIView *paperIndicator1 = [self.view subviewWithTag:2];
        
        paperIndicator0.hidden = YES;
        paperIndicator1.hidden = YES;
    }
    
    if (!_dataSource) {
        [self retrieveMoreData];
    }
    
    _interfaceWhenDisappear = self.interfaceOrientation;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_interfaceWhenDisappear != self.interfaceOrientation) {
        [self adjustToInterface:self.interfaceOrientation];
    }
}

- (void)setBarButtonItems{
    [self setBackLeftBarButtonItem];
    
    ///////
    
    if (!_canNotGotoUserAlbum) {
        UIImage *backImg1 = [UIImage imageNamed:@"btn_peo.png"];
        UIImage *backImgTapped1 = [UIImage imageNamed:@"btn_peo_tapped.png"];
        
        UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        profileBtn.frame = CGRectMake(0, 0, 44, 44);
        [profileBtn addTarget:self action:@selector(doRight:) forControlEvents:UIControlEventTouchUpInside];
        //    profileBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 10);
        
        [profileBtn setImage:backImg1 forState:UIControlStateNormal];
        [profileBtn setImage:backImgTapped1 forState:UIControlStateHighlighted];
        
        UIBarButtonItem *profileItem = [[UIBarButtonItem alloc] initWithCustomView:profileBtn];
        
        self.navigationItem.rightBarButtonItem = profileItem;
    }
    
    //////
    CGFloat width = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?(_canNotGotoUserAlbum?258:206):(_canNotGotoUserAlbum?APP_SCREEN_HEIGHT-20-62:APP_SCREEN_HEIGHT-20-114));
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?44:32)];//206 is max width //258
//    titleView.backgroundColor = [UIColor grayColor];
    titleView.backgroundColor = [UIColor clearColor];
    
    NSArray *albumIds = [[DADataEnvironment sharedDADataEnvironment].collectedAlbums valueForKeyPath:Key_Album_Id];
    
    UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(width-99, 0, 44, titleView.height);
    collectBtn.tag = 1;
    
    [collectBtn addTarget:self action:@selector(doCollect:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([albumIds containsObject:_albumDic[Key_Album_Id]]) {
        [collectBtn setImage:[UIImage imageNamed:@"btn_loved.png"] forState:UIControlStateNormal];
        [collectBtn setImage:[UIImage imageNamed:@"btn_loved_tapped.png"] forState:UIControlStateHighlighted];
    }else{
        [collectBtn setImage:[UIImage imageNamed:@"btn_collect.png"] forState:UIControlStateNormal];
        [collectBtn setImage:[UIImage imageNamed:@"btn_collect_tapped.png"] forState:UIControlStateHighlighted];
    }
    
    [titleView addSubview:collectBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.tag = 2;
    shareBtn.frame = CGRectMake(width-44, 0, 44, titleView.height);
    [shareBtn addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareBtn setImage:[UIImage imageNamed:@"btn_share.png"] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageNamed:@"btn_share_tapped.png"] forState:UIControlStateHighlighted];
    
    [titleView addSubview:shareBtn];
    
    self.navigationItem.titleView = titleView;
}

- (void)doRight:(UIButton *)button{
    DAUserAblumsViewController *vc = (DAUserAblumsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DAUserAblumsViewController"];
    
    vc.userIdForAlbum = _albumDic[@"user_id"];
    vc.userAvatar = _albumDic[@"user_picurl"];
    vc.title = [NSString stringWithFormat:@"%@ %@", _albumDic[@"user_name"], NSLocalizedString(@"的相册集", nil)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSUInteger count = [self countOfAlbumTitleAndDescribe]+[_dataSource count];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSUInteger item = indexPath.item;
    
    UICollectionViewCell *cell = nil;
    NSUInteger albumAndDesCount = [self countOfAlbumTitleAndDescribe];
    if (item < albumAndDesCount) {
        static NSString *CellIdentifier0 = @"TextCellIdentifier";
        cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier0 forIndexPath:indexPath];
        
        UILabel *label = (UILabel *)[cell.contentView subviewWithTag:1];
        
        if (item == 0) {
            cell.backgroundColor = _albumNameColor;
            
            label.text = _albumDic[Key_Album_Name];
            label.numberOfLines = 2;
            label.font = [UIFont boldSystemFontOfSize:15];
        }else{
            cell.backgroundColor = _albumDesColor;
            label.text = _albumDic[Key_Album_Describe];
            label.font = [UIFont boldSystemFontOfSize:12];
            label.numberOfLines = 3;
        }
    }else{
        static NSString *CellIdentifier = @"ImageCellIdentifier";
        cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
        
        static NSString * const kPhotoInAlbumThumbUrlFormater = @"http://img5.douban.com/view/photo/photo/public/%@.jpg";
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:kPhotoInAlbumThumbUrlFormater, _dataSource[item-albumAndDesCount]]];
        
        imgView.image = nil;
        [imgView setImageWithURL:URL];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
        
        _loadMoreTipsLbl = (UILabel *)[headerView subviewWithTag:1];
        _indicatorView = (UIActivityIndicatorView *)[headerView subviewWithTag:2];
        return headerView;
    }
    
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!_canotLoadMore && scrollView.contentOffset.y+scrollView.height >= scrollView.contentSize.height-25.0) {
        [self retrieveMoreData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.width >= APP_SCREEN_HEIGHT*0.2) {
        [DAMarksHelper showPhotoWallMarksInViewController:self.navigationController];
    }
}

#pragma mark - Data Reqeust

- (void)retrieveMoreData{
    if (_isLoadingMore) return;
    _isLoadingMore = YES;
    
    [_indicatorView startAnimating];
        
    NSUInteger start = _dataSource.count;
    [DAHttpClient photosInAlbumWithId:[self.albumDic[Key_Album_Id] integerValue]
                                start:start
                              success:^(id dic) {
                                  SLLog(@"dic %@", dic);
                                  
                                  if (dic) {
                                      NSString *des = [dic objectForKey:Key_Album_Describe];
                                      if (des) {
                                          NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:_albumDic];
                                          muDic[Key_Album_Describe] = des;
                                          
                                          self.albumDic = muDic;
                                      }
                                      
                                      NSArray *photoIds = dic[@"photoIds"];
                                      if (start == 0) {
                                          _dataSource = [photoIds mutableCopy];
                                          [_collectionView reloadData];
                                      }else{
                                          if (photoIds.count > 0) {
                                              NSMutableArray *muIndexPath = [NSMutableArray arrayWithCapacity:photoIds.count];
                                              [photoIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                  [muIndexPath addObject:[NSIndexPath indexPathForItem:idx+[_collectionView numberOfItemsInSection:0] inSection:0]];
                                              }];
                                              
                                              [_dataSource addObjectsFromArray:photoIds];
                                              [_collectionView insertItemsAtIndexPaths:muIndexPath];
                                          }else{
                                              _canotLoadMore = YES;
                                          }
                                      }
                                  }else{
                                      [self showFailTips:NSLocalizedString(@"哎哟,出错了", nil)];
                                  }
                                  
                                  [self doneLoadMore];
                              } error:^(NSInteger index) {
                                  [self doneLoadMore];
                                  
                                  [self showFailTips:NSLocalizedString(@"哎哟,出错了", nil)];
                              } failure:^(NSError *error) {
                                  [self doneLoadMore];
                                  
                                  [self showFailTips:NSLocalizedString(@"哎哟,出错了", nil)];
                              }];
}

- (void)doneLoadMore{
    [_indicatorView stopAnimating];
    _isLoadingMore = NO;
    
    if (_canotLoadMore) {
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"共 %d 张", nil), _dataSource.count];
        _loadMoreTipsLbl.text = text;
        _loadMoreTipsLbl.hidden = NO;
    }
}

//
//- (void)configAlbumNameAndDescribeItem:(NSUInteger)item forLabel:(UILabel*)label{
//    if (item == 0) {
//        label.backgroundColor = RGBCOLOR(203, 152, 140);
//        label.font = [UIFont boldSystemFontOfSize:15];
//    }else{
//        label.backgroundColor = RGBCOLOR(203, 152, 140);
//        label.text = _albumDic[@"describe"];
//        label.font = [UIFont boldSystemFontOfSize:12];
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(400, 120), NO, 0.0);
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        
//        CGContextSetFillColorWithColor(ctx, RGBCOLOR(203, 152, 140).CGColor);
//        UIRectFill(CGContextGetClipBoundingBox(ctx));
//        
//        CGContextSetFillColorWithColor(ctx, RGBCOLOR(250, 250, 250).CGColor);
//
//        NSString *text = _albumDic[@"describe"];
//        [text drawInRect:CGRectMake(0, 0, 400, 120)
//                withFont:[UIFont boldSystemFontOfSize:30]
//           lineBreakMode:NSLineBreakByTruncatingTail
//               alignment:NSTextAlignmentCenter];
//        
//        UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
//        NSData *data = UIImagePNGRepresentation(result);
//        imgView.image = [UIImage imageWithData:data];
//        
//        UIGraphicsEndImageContext();
//    }
//}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:NSStringFromClass([DAUserAblumsViewController class])]) {
        return !_canNotGotoUserAlbum;
//    }else if ([identifier isEqualToString:NSStringFromClass([DAScanePhotoViewController class])]) {
//        NSIndexPath *selectedIndexPath = [[_collectionView indexPathsForSelectedItems] lastObject];
//        NSUInteger item = selectedIndexPath.item;
//        
//        return item >= [self countOfAlbumTitleAndDescribe];
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *iden = [segue identifier];
    if ([iden isEqualToString:NSStringFromClass([DAUserAblumsViewController class])])
    {
        DAUserAblumsViewController *vc = (DAUserAblumsViewController *)[segue destinationViewController];
        
        vc.userIdForAlbum = _albumDic[@"user_id"];
        vc.userAvatar = _albumDic[@"user_picurl"];
        vc.title = [NSString stringWithFormat:@"%@ %@", _albumDic[@"user_name"], NSLocalizedString(@"的相册集", nil)];
    }else if ([iden hasPrefix:NSStringFromClass([DAScanePhotoViewController class])]){
        
        NSIndexPath *selectedIndexPath = [[_collectionView indexPathsForSelectedItems] lastObject];
        NSUInteger item = selectedIndexPath.item;
        
        DAScanePhotoViewController *vc = (DAScanePhotoViewController *)[segue destinationViewController];
//        vc.photoWallVC = self;
        
        NSInteger i = item-[self countOfAlbumTitleAndDescribe]+1;
        vc.selectedItem = (i<0?0:i);
        
//        SLLog(@"item %d vc.selectedItem %d", item, vc.selectedItem);
        vc.albumTitleAndDescribe = _albumDic;
        vc.dataSource = _dataSource;
    }
}

- (IBAction)swipeBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swipeUserAlbums:(id)sender {
    
}

- (NSUInteger)countOfAlbumTitleAndDescribe{
    NSString *describe = _albumDic[Key_Album_Describe];
    
    return 1+(describe.length>0?1:0);
}

- (void)doCollect:(UIButton *)button{
    NSArray *albumIds = [[DADataEnvironment sharedDADataEnvironment].collectedAlbums valueForKeyPath:Key_Album_Id];
    BOOL like = [albumIds containsObject:_albumDic[Key_Album_Id]];
    
    [DAHttpClient likeAlbumWithAlbumDic:_albumDic
                                   like:!like
                                success:^(NSInteger type){
                                    SLLog(@"note type %d", type);//1 create 2 update
                                    
                                    UIView *tittleViwe = self.navigationItem.titleView;
                                    UIButton *collectBtn = [tittleViwe subviewWithTag:1];
                                    
                                    if (!like) { //收藏
                                        if (type == 1) { //创建日记
                                            [self showCreateNoteTips];
                                        }else if(type == 2){ //
                                            collectBtn.alpha = 0;
                                            [collectBtn setImage:[UIImage imageNamed:@"btn_loved.png"] forState:UIControlStateNormal];
                                            [collectBtn setImage:[UIImage imageNamed:@"btn_loved_tapped.png"] forState:UIControlStateHighlighted];
                                            
                                            [UIView animateWithDuration:0.3
                                                             animations:^{
                                                                 collectBtn.alpha = 1;
                                                             }];
                                            
                                            [self showSuccessTips:NSLocalizedString(@"收藏成功", nil)];
                                        }
                                    }else{ //取消收藏
                                        collectBtn.alpha = 0;
                                        
                                        [collectBtn setImage:[UIImage imageNamed:@"btn_collect.png"] forState:UIControlStateNormal];
                                        [collectBtn setImage:[UIImage imageNamed:@"btn_collect_tapped.png"] forState:UIControlStateHighlighted];
                                        
                                        [UIView animateWithDuration:0.3
                                                         animations:^{
                                                             collectBtn.alpha = 1;
                                                         }];
                                        
                                        [self showSuccessTips:NSLocalizedString(@"取消收藏成功", nil)];
                                    }
                                } error:^(NSInteger index) {
                                    [self showFailTips:NSLocalizedString(@"请求出错", nil)];
                                } failure:^(NSError *error) {
                                    [self showFailTips:NSLocalizedString(@"请求错误", nil)];
                                } viewController:self];
}

- (void)showCreateNoteTips{
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    view.alpha = 0;
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_papper.png"]];
    bgView.center = CGPointMake(160, 250);
    [view addSubview:bgView];
    
    UIImage *img = [UIImage imageNamed:@"tips_collect.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.center = CGPointMake(160, 250);
    [view addSubview:imgView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(240, 120, 44, 44);
    [cancelBtn setImage:[UIImage imageNamed:@"tips_cancle.png"] forState:UIControlStateNormal];
    cancelBtn.adjustsImageWhenHighlighted = YES;
    [cancelBtn addTarget:self action:@selector(hideTips:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
    
    [self.navigationController.view addSubview:view];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1;
                     }];
}

- (void)hideTips:(UIButton *)button{
    UIView *superView = [button superview];
    [UIView animateWithDuration:0.3
                     animations:^{
                         superView.alpha = 0;
                     }completion:^(BOOL finished) {
                         [superView removeFromSuperview];
                     }];
}

- (void)doShare:(UIButton *)button{
    SLArrayBlock block = ^(NSArray *items){
        DADoubanActivity *doubanActivity = [[DADoubanActivity alloc] init];
        NSMutableArray *activities = [NSMutableArray arrayWithObject:doubanActivity];
        if ([WXApi isWXAppSupportApi]) {
            DAWeixinActivity *weixinActivity = [[DAWeixinActivity alloc] init]
            ;
            weixinActivity.sheetDelegate = self;
            [activities addObject:weixinActivity];
        }
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activities];
        
//        __block UIActivityViewController *temp = activityView;
//        UIActivityViewControllerCompletionHandler handler = ^(NSString *activityType, BOOL completed){
//            [self dismissViewControllerAnimated:NO completion:nil];
//        };
        
//        activityView.completionHandler = handler;
        
        //    UIActivity
        [activityView setExcludedActivityTypes:@[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToFacebook, UIActivityTypeAssignToContact]];
        
        [self presentViewController:activityView animated:YES completion:nil];
    };
    
    NSString *text = [self shareAlbumText];
    
    NSMutableString *url = [NSMutableString stringWithString:[NSString stringWithFormat:[DAHtmlRobot commandFor:kPhotosInAlbumUrlFomater], self.albumDic[@"album_id"], 0]];
    
    NSRange range = [url rangeOfString:@"?start=0"];
    if (range.location != NSNotFound) {
        [url replaceCharactersInRange:range withString:@""];
    }
    
    NSString *coverUrl = [NSString stringWithFormat:@"http://%@", _albumDic[Key_Album_Cover]];
    UIImage *image = [[UIImageView sharedImageCache] objectForKey:url];
    
    NSMutableArray *activityItems = [@[text, url] mutableCopy];
    if (image) {
        [activityItems addObject:image];
        block(activityItems);
    }else{
        NSURL *URL = [NSURL URLWithString:coverUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
                                               if (err== nil && data) {
                                                   UIImage *image = [UIImage imageWithData:data];
                                                   [activityItems addObject:image];
                                                   block(activityItems);
                                               }
                                           }];
    }
}

#pragma mark - UIViewControllerRotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustToInterface:toInterfaceOrientation];
}

- (void)adjustToInterface:(UIInterfaceOrientation)toInterfaceOrientation{
    _interfaceWhenDisappear = toInterfaceOrientation;
    
    [self setBarButtonItems];
    
//    CGFloat width = (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)?(_canNotGotoUserAlbum?258:206):(_canNotGotoUserAlbum?APP_SCREEN_HEIGHT-20-62:APP_SCREEN_HEIGHT-20-114));
//    
//    UIView *titleView = self.navigationItem.titleView;
//    titleView.width = width;
//    
//    titleView.backgroundColor = [UIColor grayColor];
//    
//    UIView *collectBtn = [titleView subviewWithTag:1];
//    UIView *shareBtn = [titleView subviewWithTag:2];
//    
//    CGFloat height = UIInterfaceOrientationIsPortrait(toInterfaceOrientation)?44:32;
//    titleView.height = height;
//    
//    collectBtn.left = width-99;
//    collectBtn.centerY = height*0.5;
//    
//    shareBtn.right = width;
//    shareBtn.centerY = height*0.5;
    
    DAWaterfallLayout *layout = (DAWaterfallLayout *)_collectionView.collectionViewLayout;
    [layout clearLayoutAttributes];
    
    [_collectionView reloadData];
}

#pragma mark - UIActionSheetDelegate

- (UIImage *)drewAlbumInfoWithImage:(UIImage *)image{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 720), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, RGBCOLOR(255, 255, 255).CGColor);
    UIRectFill(CGContextGetClipBoundingBox(ctx));

    [image drawInRect:CGRectMake(20, 20, 600, 600)];
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    NSString *text = [NSString stringWithFormat:@"豆瓣相册:%@", _albumDic[Key_Album_Name]];
    [text drawInRect:CGRectMake(20, 630, 600, 40)
            withFont:[UIFont boldSystemFontOfSize:36]
       lineBreakMode:NSLineBreakByTruncatingTail
           alignment:NSTextAlignmentLeft];
    
    CGContextSetFillColorWithColor(ctx, RGBCOLOR(120, 120, 120).CGColor);
    text = [NSString stringWithFormat:@"相册id: %@", _albumDic[Key_Album_Id]];
    [text drawInRect:CGRectMake(20, 680, 600, 40)
            withFont:[UIFont boldSystemFontOfSize:30]];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (void)shareToWeixinImage:(SLObjectBlock)complete{
    NSString *cover = [_albumDic objectForKey:Key_Album_Cover];

    NSString *key = cover;
    if (![cover hasPrefix:@"http://"]) {
        key = [NSString stringWithFormat:@"http://%@", cover];
    }
    
    UIImage *image = [[UIImageView sharedImageCache] objectForKey:key];
    if (image) {
        UIImage *result = [self drewAlbumInfoWithImage:image];
        complete(result);
    }else{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:key]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *res, NSData *data, NSError *er) {
                                   if (er == nil && data && [[res MIMEType] hasPrefix:@"image"]) {
                                       
                                       UIImage *result = [self drewAlbumInfoWithImage:[UIImage imageWithData:data]];
                                       complete(result);
                                   }
                               }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 || buttonIndex == 1) {
        [self shareToWeixinImage:^(UIImage *image){
            WXMediaMessage *message = [WXMediaMessage message];
            
            [message setThumbImage:[image thumbnailImage:200 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh]];
            
            WXImageObject *ext = [WXImageObject object];
            ext.imageData = UIImageJPEGRepresentation(image, 0.8);
            
            message.mediaObject = ext;
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = buttonIndex;
            
            [WXApi sendReq:req];
        }];
        
//        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//        req.bText = YES;
//        
//        NSMutableString *text = [self shareAlbumText];
//        
//        NSString *albumId = [self.albumDic objectForKey:Key_Album_Id];
//        
//        NSString *albumUrl = [NSString stringWithFormat:[DAHtmlRobot commandFor:kPhotosInAlbumUrlFomater], albumId, 0];
//        [text appendString:albumUrl];
//        
//        NSRange range = [text rangeOfString:@"?start=0"];
//        if (range.location != NSNotFound) {
//            [text replaceCharactersInRange:range withString:@""];
//        }
//        
//        req.text = text;
//        req.scene = buttonIndex;
//        
//        [WXApi sendReq:req];
    }
}

- (NSMutableString *)shareAlbumText{
    NSMutableString *text = [NSMutableString stringWithFormat:@"分享相册【%@】", [_albumDic objectForKey:Key_Album_Name]];
    
    NSString *des = [_albumDic objectForKey:Key_Album_Describe];
    if (des.length > 0) {
        NSUInteger length = MIN(20, des.length);
        [text appendString:[des substringToIndex:length-1]];
        [text appendString:@".."];
    }
    
    return text;
}

@end
