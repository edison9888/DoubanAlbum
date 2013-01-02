//
//  DAUserAblumsViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DAUserAblumsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DAHttpClient.h"
#import "DAPhotoWallViewController.h"
#import "DAWebViewController.h"
#import "NSStringAddition.h"

@interface DAUserAblumsViewController ()

@end

@implementation DAUserAblumsViewController{
    UILabel                     *_loadMoreTipsLbl;
    UIActivityIndicatorView     *_indicatorView;
    
    BOOL        _isLoadingMore;
    BOOL        _canotLoadMore;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:_collectionView.bounds];
    bgImgView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
    bgImgView.image = [UIImage imageWithFileName:@"tb_bg_album-568h" type:@"jpg"];
    _collectionView.backgroundView = bgImgView;
    
    ///////////
    
    [self setBackLeftBarButtonItem];
    
    UIView *avatarView = [self.view subviewWithTag:10];
    UIImageView *imgView = (UIImageView *)[avatarView subviewWithTag:1];
    imgView.layer.cornerRadius = 30;
    imgView.clipsToBounds = YES;
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", self.userAvatar]];
    [imgView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"default_user.png"]];

    if (!_dataSource) {
        [self retrieveMoreData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSUInteger row = indexPath.row;
    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *nameLbl = (UILabel *)[cell.contentView viewWithTag:2];
    
    NSDictionary *dic = _dataSource[row];

    NSString *cover = dic[Key_Album_Cover];
    NSString *url = nil;
    if (![cover hasPrefix:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@", cover];
    }else{
        url = cover;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    [imgView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"default_album.png"]];
    
    nameLbl.text = dic[Key_Album_Name];
    
    SLLog(@"dic %@", dic);
    return cell;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                              withReuseIdentifier:kind
                                                                                     forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        _loadMoreTipsLbl = (UILabel *)[headerView subviewWithTag:1];
        _indicatorView = (UIActivityIndicatorView *)[headerView subviewWithTag:2];
        return headerView;
    }
    
    return headerView;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    UIView *avatarView = [self.view subviewWithTag:10];
    [UIView animateWithDuration:0.3
                     animations:^{
                         avatarView.right = 0;
                     }];
    
    if (!_canotLoadMore && scrollView.contentOffset.y+scrollView.height >= scrollView.contentSize.height-25.0) {
        [self retrieveMoreData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y == 0) {
        UIView *avatarView = [self.view subviewWithTag:10];
        [UIView animateWithDuration:0.3
                         animations:^{
                             avatarView.left = 0;
                         }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DAPhotoWallViewController"])
    {
        DAPhotoWallViewController *vc = (DAPhotoWallViewController *)[segue destinationViewController];
        
        NSIndexPath *selectedIndexPath = [[_collectionView indexPathsForSelectedItems] lastObject];
        
        NSDictionary *dic = _dataSource[selectedIndexPath.row];
        
        vc.albumDic = dic;
        vc.canNotGotoUserAlbum = YES;
    }else if ([[segue identifier] isEqualToString:@"DAWebViewController"]){
        DAWebViewController *vc = (DAWebViewController *)[segue destinationViewController];
        NSString *title = self.title;
        
        NSRange range = [title rangeOfString:NSLocalizedString(@"的相册集", nil)];
        if (range.location != NSNotFound) {
            vc.title = [title substringToIndex:range.location];
        }else{
            vc.title = NSLocalizedString(@"豆瓣", nil);
        }
        
        vc.userIdForAlbum = _userIdForAlbum;
    }
}

#pragma mark - Data Reqeust

- (void)retrieveMoreData{
    if (_isLoadingMore) return;
    _isLoadingMore = YES;
    
    [_indicatorView startAnimating];
    
    NSUInteger start = _dataSource.count;
    [DAHttpClient userAlbumsWithUserName:_userIdForAlbum
                                   start:start
                                 success:^(NSArray *array) {
                                     if (array) {
                                         if (start == 0) {
                                             _dataSource = [array mutableCopy];
                                             [_collectionView reloadData];
                                         }else{
                                             if (array.count > 0) {
                                                 NSMutableArray *muIndexPath = [NSMutableArray arrayWithCapacity:array.count];
                                                 [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                     [muIndexPath addObject:[NSIndexPath indexPathForItem:idx+[_collectionView numberOfItemsInSection:0] inSection:0]];
                                                 }];
                                                 
                                                 [_dataSource addObjectsFromArray:array];
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
                                     [self showFailTips:NSLocalizedString(@"哎哟,出错了", nil)];
                                     [self doneLoadMore];
                                 } failure:^(NSError *error) {
                                     [self showFailTips:NSLocalizedString(@"哎哟,出错了", nil)];
                                     [self doneLoadMore];
                                 }];
}

- (void)doneLoadMore{
    [_indicatorView stopAnimating];
    _isLoadingMore = NO;
    
    if (_canotLoadMore) {
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"共 %d 个", nil), _dataSource.count];
        _loadMoreTipsLbl.text = text;
        _loadMoreTipsLbl.hidden = NO;
    }
}

- (IBAction)swipeBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
