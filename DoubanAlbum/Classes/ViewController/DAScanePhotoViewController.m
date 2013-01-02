//
//  DAScanePhotoViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-12.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAScanePhotoViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DAScanePhotoViewController ()

@end

@implementation DAScanePhotoViewController{
    UIScrollView        *_zoomScrollView;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 44, 44);
        [button addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    _collectionView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    [self performSelector:@selector(showCollectionView) withObject:nil afterDelay:0.05];
    
    _downloadBtn.enabled = (_selectedItem != 0);
}

- (void)showCollectionView{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _collectionView.alpha = 1;
                     }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
//    self.photoWallVC = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    
//    [self.photoWallVC willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSUInteger count = [_dataSource count];
    
    return count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSUInteger row = indexPath.row;
    
    UICollectionViewCell *cell = nil;
    if (row == 0) {
        static NSString *CellIdentifier0 = @"TextCellIdentifier";
        cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier0 forIndexPath:indexPath];
        
        UILabel *titleLbl = (UILabel *)[cell.contentView viewWithTag:1];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        NSString *name = _albumTitleAndDescribe[Key_Album_Name];
        NSString *des = _albumTitleAndDescribe[Key_Album_Describe];
        
        NSMutableAttributedString *nameAttString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", name] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        if (des) {
            NSAttributedString *desAttString = [[NSAttributedString alloc] initWithString:des attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[UIColor whiteColor]}];
            
            [nameAttString appendAttributedString:desAttString];
        }
        
        titleLbl.attributedText = nameAttString;
    }else{
        static NSString *CellIdentifier = @"CellIdentifier";
        cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
        
        static NSString * const kPhotoInAlbumThumbUrlFormater = @"http://img5.douban.com/view/photo/photo/public/%@.jpg";
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:kPhotoInAlbumThumbUrlFormater, _dataSource[row-1]]];
        
        [imgView setImageWithURL:URL];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DAUserAblumsViewController"])
    {
        
    }
}

- (IBAction)cancel:(UITapGestureRecognizer *)gesture {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[gesture locationInView:_collectionView]];
    
    if (indexPath.item > 0) {
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        UIScrollView *scrolView = [[cell.contentView subviews] lastObject];
        
        if ([scrolView isMemberOfClass:[UIScrollView class]] && scrolView.zoomScale != 1) {
            scrolView.zoomScale = 1;
        }else{
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        }
    }else{
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

- (void)doCancel:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    _zoomScrollView = scrollView;
    return [scrollView subviewWithTag:1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == _collectionView) {
        _zoomScrollView.zoomScale = 1;
    }
    
    CGFloat width = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?self.view.width:self.view.height);
    int page = floor((_collectionView.contentOffset.x - width / 2) / width) + 1;

    _downloadBtn.enabled = (page != 0);
}

- (IBAction)downloadImage:(id)sender {
    CGFloat width = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?self.view.width:self.view.height);
    int page = floor((_collectionView.contentOffset.x - width / 2) / width) + 1;
    
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];

    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    
    UIImage *image = imgView.image;
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(id)context{
    UIView *view = [self.view subviewWithTag:100];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         view.alpha = 1;
                     }completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
    
    [self showCheckMarkTips];
}


@end
