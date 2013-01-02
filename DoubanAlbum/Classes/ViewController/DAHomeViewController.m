//
//  DAHomeViewController.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-8.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "DALoginViewController.h"
#import "DoubanAuthEngine.h"
#import "DAHttpClient.h"
#import "DACategoryViewController.h"
#import "DAPhotoWallViewController.h"
#import "DASettingViewController.h"
#import "DATagsLayout.h"
#import "DAHtmlRobot.h"
#import "JSONKit.h"
#import "DoubanAuthEngine.h"
#import "DOUOAuthStore.h"
#import "DAMarksHelper.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSStringAddition.h"
#import "UIView+Indicator.h"

typedef enum {
    kTagCategoryView = 100,
    kTagHeaderView,
    kTagTitleView,
    kTagTitleLbl,
    kTagTitleIndiImgView,
    kTagShadowView,
}kDATableViewControllerTags;

static BOOL IsShowingCategory = NO;

@interface DAHomeViewController ()

@end

@implementation DAHomeViewController

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.navigationController.navigationBarHidden = YES;
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:_tableView.bounds];
    bgImgView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
    bgImgView.image = [UIImage imageWithFileName:@"tb_bg_album-568h" type:@"jpg"];
    _tableView.backgroundView = bgImgView;
    
    _collectionView.layer.shadowColor = RGBCOLOR(0, 0, 0).CGColor;
    _collectionView.layer.shadowOffset = CGSizeMake(0, 1.5);
    _collectionView.layer.shadowRadius = 1;
    _collectionView.layer.shadowOpacity = 0.3;
    _collectionView.layer.borderWidth = 0.5;
    _collectionView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    
    UIImage *topBarImg = [UIImage imageNamed:@"bg_nav.png"];
    
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:TEXT_COLOR_2, UITextAttributeTextColor, RGBCOLOR(255, 215, 150), UITextAttributeTextShadowColor, [NSValue valueWithCGSize:CGSizeMake(1, 1)], UITextAttributeTextShadowOffset, [UIFont boldSystemFontOfSize:18], UITextAttributeFont, nil];
    [self.navigationController.navigationBar setBackgroundImage:topBarImg forBarMetrics:UIBarMetricsDefault];
    
    [self setBarButtonItems];
    
    [self initialData:YES];
    
    [[DADataEnvironment sharedDADataEnvironment] addObserver:self forKeyPath:@"collectedAlbums" options:NSKeyValueObservingOptionNew context:nil];
    
    [USER_DEFAULT addObserver:self forKeyPath:@"douban_userdefaults_user_id" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIView *shadowView = [self.view subviewWithTag:kTagShadowView];
    
    if (shadowView) {
        shadowView.frame = UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT):CGRectMake(0, 0, APP_SCREEN_HEIGHT, APP_SCREEN_WIDTH);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self hidePaperIndicator];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    UIView *shadowView = [self.view subviewWithTag:kTagShadowView];
//    shadowView.bounds = (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)?CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT):CGRectMake(0, 0, APP_SCREEN_HEIGHT*2, APP_SCREEN_WIDTH*2));
    
    if (shadowView) {
        //TODO
        CGRect frame = _collectionView.bounds;
        frame.size.width = frame.size.width+10;
        frame.size.height = self.view.height;
        
        shadowView.frame = frame;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource[@"albums"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSUInteger row = indexPath.row;
    
    NSDictionary *dic = _dataSource[@"albums"][row];
    
    NSString *cover = dic[Key_Album_Cover];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", cover]];
    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    [imgView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"default_album.png"]];
    
    UILabel *titleLbl = (UILabel *)[cell.contentView viewWithTag:2];
    titleLbl.text = dic[Key_Album_Name];
    
    UILabel *userNameLbl = (UILabel *)[cell.contentView viewWithTag:3];
    NSString *userName = dic[@"user_name"];
    if (userName) {
        userNameLbl.text = [NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"来自", nil), userName];
    }else{
        userNameLbl.text = nil;
    }
    
    return cell;
}

#pragma mark - Table view delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 25.0;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSDictionary *dic = _dataSource[section];
//    return dic[@"category"];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSUInteger row = indexPath.row;
//    [DAHttpClient photosInAlbumWithId:[dic[@"album_id"] integerValue]
//                                start:0
//                              success:^(NSArray *array) {
//                                  
//                              } error:^(NSInteger index) {
//
//                              } failure:^(NSError *error) {
//                                  
//                              }];
    
//    DAPhotosWallViewController *wallVC = [[DAPhotosWallViewController alloc] initWithCollectionViewLayout:layout];
//    [self.navigationController pushViewController:wallVC animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y >= APP_SCREEN_HEIGHT*0.2) {
        [DAMarksHelper showHomeMarksInViewController:self.navigationController];
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (IsShowingCategory) {
//        [self showOrHideCategory:nil];
//    }
//}

- (void)showOrHideCategory:(UITapGestureRecognizer *)gesture {
    self.navigationItem.titleView.userInteractionEnabled = NO;
    
//    CGFloat screenWidth = APP_SCREEN_WIDTH;
    
//    CGFloat x = 10;
//    CGFloat y = 10;
//    CGFloat width = 30;
//    CGFloat gap = 5;
    
//    UIView *categoryView = [self.view viewWithTag:kTagCategoryView];
//    if (!categoryView) {
////        CALayer *grayColorLayer = [CALayer layer];
////        grayColorLayer.frame = categoryView.frame;
////        grayColorLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
////        [categoryView.layer addSublayer:grayColorLayer];
//        
////        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0-height, screenWidth, height)];
////        headerView.tag = kTagHeaderView;
////        headerView.backgroundColor = [UIColor whiteColor];
////        [categoryView addSubview:headerView];
//        
////        CGFloat height = y*2+row*width+(row-1)*gap;
//        
//        categoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
//        categoryView.backgroundColor = RGBCOLOR(144, 144, 144);
//        categoryView.tag = kTagCategoryView;
//        
//        __block CGFloat offsetX = x;
//        __block CGFloat offsetY = y;
//        UIFont *font = [UIFont boldSystemFontOfSize:14];
//        [_data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            
//            NSString *title = obj[@"category"];
//            CGFloat titleW = [title sizeWithFont:font].width;
//            CGFloat bunW = titleW+15;
//            
//            if (offsetX+bunW < 300) {
//                button.frame = CGRectMake(offsetX, offsetY, bunW, width);
//                
//                offsetX += bunW+gap;
//            }else{
//                offsetX = x;
//                offsetY += width+gap;
//                
//                button.frame = CGRectMake(x, offsetY, bunW, width);
//                offsetX = button.right+gap;
//            }
//            
//            [button setTitle:title forState:UIControlStateNormal];
//            button.tag = idx;
//            
//            button.titleLabel.font = font;
//            [button setTitleColor:RGBCOLOR(144, 144, 144) forState:UIControlStateNormal];
//            [button addTarget:self action:@selector(checkCagetory:) forControlEvents:UIControlEventTouchUpInside];
//            button.backgroundColor = RGBCOLOR(196, 196, 196);
//            [categoryView addSubview:button];
//            
//            SLLog(@"title %@ (%f %f %f %f) ", title, button.left, button.top, button.width, button.height);
//        }];
//        
//        categoryView.height = offsetY+width+10;
//        
//        [self.view addSubview:categoryView];
//        
//        UILabel *logLbl = [[UILabel alloc] initWithFrame:CGRectMake(categoryView.width-110, categoryView.height-30, 100, 20)];
//        logLbl.backgroundColor = categoryView.backgroundColor;
//        logLbl.textColor = RGBCOLOR(124, 124, 124);
//        logLbl.font = [UIFont boldSystemFontOfSize:12];
//        logLbl.textAlignment = NSTextAlignmentRight;
//        logLbl.text = NSLocalizedString(@"漫 实验室", nil);
//        [categoryView addSubview:logLbl];
//    }
    
    if (!IsShowingCategory) {
        IsShowingCategory = YES;
        UIView *shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
//        shadowView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        shadowView.tag = kTagShadowView;
        shadowView.alpha = 0;
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCategory:)];
        [shadowView addGestureRecognizer:gesture];
        [self.view insertSubview:shadowView belowSubview:_collectionView];
        
        _collectionView.bottom = 0;
        _collectionView.alpha = 0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _collectionView.alpha = 1;
                             _collectionView.top = 0;
                             shadowView.alpha = 1;
                         }completion:^(BOOL finished) {
                             self.navigationItem.titleView.userInteractionEnabled = YES;
                         }];
    }else{
        UIView *shadowView = [self.view subviewWithTag:kTagShadowView];
        [UIView animateWithDuration:0.3
                         animations:^{
                             _collectionView.alpha = 0;
                             _collectionView.bottom = 0;
                             
                             shadowView.alpha = 0;
                         }completion:^(BOOL finished) {
                             IsShowingCategory = NO;
                             self.navigationItem.titleView.userInteractionEnabled = YES;
                             
                             [shadowView removeFromSuperview];
                         }];
    }
}

- (void)checkCagetory:(UIButton *)button{
    NSUInteger index = button.tag;
    
    if (_seletedCategory != index) {

        NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
        _dataSource = [doubanCategory objectAtIndex:index];
        self.title = _dataSource[@"category"];
        
        [_tableView reloadData];
    }
    
//    UIButton *categoryBtn = (UIButton *)[self.navigationController.navigationItem.leftBarButtonItem customView];
    [self showOrHideCategory:nil];
}

- (void)setBarButtonItems{
    _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _refreshBtn.frame = CGRectMake(0, 0, 44, 44);
    [_refreshBtn addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventTouchUpInside];
    
    [_refreshBtn setImage:[UIImage imageNamed:@"btn_update.png"] forState:UIControlStateNormal];
    [_refreshBtn setImage:[UIImage imageNamed:@"btn_update_tapped.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:_refreshBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    ///////

    UIImage *backImg1 = [UIImage imageNamed:@"btn_setting.png"];
    UIImage *backImgTapped1 = [UIImage imageNamed:@"btn_setting_tapped.png"];
    
    UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    profileBtn.frame = CGRectMake(0, 0, 44, 44);
    [profileBtn addTarget:self action:@selector(doSetting:) forControlEvents:UIControlEventTouchUpInside];
//    profileBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 10);
    
    [profileBtn setImage:backImg1 forState:UIControlStateNormal];
    [profileBtn setImage:backImgTapped1 forState:UIControlStateHighlighted];
    
    UIBarButtonItem *profileItem = [[UIBarButtonItem alloc] initWithCustomView:profileBtn];
    
    self.navigationItem.rightBarButtonItem = profileItem;
    
    ///////
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 206, 44)]; //258:
    titleView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:titleView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:titleView.bounds];
    titleLbl.tag = kTagTitleLbl;
    titleView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.text = self.title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    
//    NSDictionary *dic = self.navigationController.navigationBar.titleTextAttributes;
//    [dic objectForKey:UITextAttributeTextColor];
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
    titleLbl.shadowOffset = CGSizeMake(0., 0.5);
    titleLbl.font = font;
    [titleView addSubview:titleLbl];
    
    UIImageView *indiImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    indiImgView.tag = kTagTitleIndiImgView;
    
    CGPoint center = CGPointMake(103, 22);
    center.x += [self.title sizeWithFont:font].width*0.5+indiImgView.width;
    indiImgView.center = center;
    [titleView addSubview:indiImgView];
    
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideCategory:)];
    [titleView addGestureRecognizer:gesture];
    
    self.navigationItem.titleView = titleView;
}

- (void)initialData:(BOOL)inital{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    [DAHttpClient incrementActivityCount];
    
    if (inital) {
        [self startAnimation:_refreshBtn];
    }
    
    SLDictionaryBlock localBlock = (inital?^(NSDictionary *dic) {
        _appData = dic;
        
        [DAHtmlRobot setRobotCommands:dic[@"command"]];
        [_collectionView reloadData];
        
        NSArray *doubanCategory = [dic valueForKeyPath:@"cg_all"];
        DATagsLayout *layout = (DATagsLayout *)_collectionView.collectionViewLayout;
        layout.category = doubanCategory;
        
        NSUInteger count = [doubanCategory count];
        if (count > 0) {
            _seletedCategory = arc4random()%count;
        }
        
        _dataSource = [doubanCategory objectAtIndex:_seletedCategory];
        self.title = _dataSource[@"category"];
        
        [_tableView reloadData];
    }:nil);
    
    [DAHtmlRobot requestCategoryLocalData:localBlock completion:^(NSDictionary *dic) {
        BOOL needUpdateView = [dic[@"needUpdateView"] boolValue];
        if (needUpdateView) {
            _appData = dic;
            
            [DAHtmlRobot setRobotCommands:dic[@"command"]];
            NSArray *doubanCategory = [dic valueForKeyPath:@"cg_all"];
            
            [_collectionView reloadData];
//        static int i = 0;
//        NSArray *albumIds = [doubanCategory valueForKeyPath:@"albums.album_id"];
//        [albumIds enumerateObjectsUsingBlock:^(NSArray *objT, NSUInteger idx0, BOOL *stop) {
//            [objT enumerateObjectsUsingBlock:^(id obj, NSUInteger idx1, BOOL *stop) {
//
//                [albumIds enumerateObjectsUsingBlock:^(NSArray *innerA, NSUInteger idx2, BOOL *stop) {
//                    [innerA enumerateObjectsUsingBlock:^(id inner, NSUInteger idx3, BOOL *stop) {
//                        if ([inner isEqual:obj] && !(idx0 == idx2 && idx1 == idx3)) {
//                            SLLog(@"重复 %@ (%d %d) (%d %d)", inner, idx0, idx1, idx2, idx3);
//                        }
//                    }];
//                }];
//            }];
//        }];
            
            DATagsLayout *layout = (DATagsLayout *)_collectionView.collectionViewLayout;
            layout.category = doubanCategory;
            
            NSUInteger count = [doubanCategory count];
            if (inital && count > 0 && _seletedCategory >= count) {
                _seletedCategory = arc4random()%count;
            }
            
            if (!inital && _seletedCategory < count) {
                _dataSource = [doubanCategory objectAtIndex:_seletedCategory];
                self.title = _dataSource[@"category"];
                
                [_tableView reloadData];
            }
        }
        
        NSString *appInStoreVersion = dic[@"app_version"];
        NSString *appVersion = [BundleHelper bundleShortVersionString];
        
        BOOL needForceUpdate = [dic[@"force_update"] boolValue];
        if ([appInStoreVersion compare:appVersion]) {
            if (!needForceUpdate) {
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"升级提示", nil) message:NSLocalizedString(@"豆瓣相册有了新版本，赶紧去升级体验一下吧", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"去下载", nil), nil];
                [alert show];
            }else{
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"升级提示", nil) message:NSLocalizedString(@"豆瓣相册有了新版本，赶紧去升级体验一下吧", nil)  delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"去下载", nil), nil];
                [alert show];
            }
        }
        
        NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval delay = (end-start>2.0?0:(2.0-(end-start)));
        
        [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:delay];
    }];
    
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        [DoubanAuthEngine checkRefreshToken];
        
        [DAHttpClient userAlbumsWithUserName:[@([[DOUOAuthStore sharedInstance] userId]) description]
                                       start:0
                                     success:^(NSArray *array) {
                                         [DADataEnvironment sharedDADataEnvironment].myAlbums = [array mutableCopy];
                                     } error:^(NSInteger index) {
                                         
                                     } failure:^(NSError *error) {
                                         
                                     }];
        
        [DAHttpClient collectedAlbumsWithSuccess:^(NSArray *array) {
            [DADataEnvironment sharedDADataEnvironment].collectedAlbums = [array mutableCopy];
        } error:^(NSInteger index) {
        } failure:^(NSError *error) {
        }];
    }
}

- (void)doRefresh:(UIButton *)button{
    [self startAnimation:button];
    
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"albums" ofType:@"plist"];
//    SLLog(@"json %@", [[NSDictionary dictionaryWithContentsOfFile:file] JSONString]);

    [self initialData:NO];
}

- (void)startAnimation:(UIButton *)button{
    button.userInteractionEnabled = NO;
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: 0-M_PI * 2.0 ];///* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    
    [button.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation{
    [DAHttpClient decrementActivityCount];
    
    _refreshBtn.userInteractionEnabled = YES;
    [_refreshBtn.layer removeAllAnimations];
}

- (void)doSetting:(UIButton *)button{
    DASettingViewController *vc = (DASettingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DASettingViewController"];
    vc.recommendApps = [_appData objectForKey:@"apps"];
    vc.title = NSLocalizedString(@"设置", nil);
    
    UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIImage *nvImg = [UIImage imageNamed:@"bg_nav.png"];
    [nVC.navigationBar setBackgroundImage:nvImg forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:nVC
                       animated:YES
                     completion:^{
                         
                     }];
}

#pragma mark - To PhotoWall ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ShowPhotosInAlbumSegueIdentifier"])
    {
        DAPhotoWallViewController *vc = (DAPhotoWallViewController *)[segue destinationViewController];
        
        NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
        
        NSDictionary *dic = _dataSource[@"albums"][selectedIndexPath.row];
        vc.albumDic = dic;
        
        NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
        vc.canNotGotoUserAlbum = (_seletedCategory == doubanCategory.count);
        
        CGFloat offset = [_tableView rectForRowAtIndexPath:selectedIndexPath].origin.y-[_tableView contentOffset].y;
        vc.paperIndicatorOffset = offset;
    }
}

- (IBAction)showPhotosInAlbum:(UISwipeGestureRecognizer *)gesture {
    if (IsShowingCategory) return;
    
    CGPoint point = [gesture locationInView:_tableView];
    NSIndexPath *selectedIndexPath = [_tableView indexPathForRowAtPoint:point];
    if (!selectedIndexPath) return;
    
    NSUInteger row = selectedIndexPath.row;
    
    [self hidePaperIndicator];
    
    DAPhotoWallViewController *vc = (DAPhotoWallViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DAPhotoWallViewController"];
    
    NSDictionary *dic = _dataSource[@"albums"][row];
    
    vc.albumDic = dic;
    NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
    vc.canNotGotoUserAlbum = (_seletedCategory == doubanCategory.count);
    
    CGFloat offset = [_tableView rectForRowAtIndexPath:selectedIndexPath].origin.y-[_tableView contentOffset].y;
    vc.paperIndicatorOffset = offset;

    _lastSelectedRow = row;
    ////
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndexPath];
    UIView *view = [cell.contentView viewWithTag:4];
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1;
                     }completion:^(BOOL finished) {
                         [self.navigationController pushViewController:vc animated:YES];
                     }];
}

- (void)hidePaperIndicator{
    UITableViewCell *lastSeletedSell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSelectedRow inSection:0]];
    UIView *view0 = [lastSeletedSell.contentView viewWithTag:4];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view0.alpha = 0;
                     }];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
    return ([doubanCategory count]+2);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSUInteger item = indexPath.item;
    
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = RGBACOLOR(0, 0, 0, 0.2).CGColor;
    
    UIButton *button = (UIButton *)[[cell.contentView subviews] lastObject];
    
    NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
    NSUInteger doubanCategoryCount = doubanCategory.count;
    if (item < doubanCategoryCount) {
        NSString *title = doubanCategory[item][@"category"];
        NSRange range = [title rangeOfString:@"&amp;"];
        if (range.location != NSNotFound) {
            NSMutableString *muString = [NSMutableString stringWithString:title];
            [muString replaceCharactersInRange:range withString:@"&"];
            [button setTitle:muString forState:UIControlStateNormal];
        }else{
            [button setTitle:title forState:UIControlStateNormal];
        }
    }else if(item == doubanCategoryCount){
        [button setTitle:NSLocalizedString(@"我的相册", nil) forState:UIControlStateNormal];
    }else if(item == doubanCategoryCount+1){
        [button setTitle:NSLocalizedString(@"❤收藏", nil) forState:UIControlStateNormal];
    }
    
    button.tag = item;
    if (item == _seletedCategory) {
        button.backgroundColor = [DADataEnvironment colorWithCategoryIndex:_seletedCategory];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        cell.layer.borderWidth = 0.5;
    }else{
        button.backgroundColor = RGBCOLOR(240, 240, 240);
        [button setTitleColor:RGBCOLOR(132, 132, 132) forState:UIControlStateNormal];
        
        cell.layer.borderWidth = 0;
    }
    
    return cell;
}

- (IBAction)choseCategory:(UIButton *)button {
    NSUInteger index = button.tag;
    
    if (_seletedCategory != index) {
        NSUInteger lastSelected = _seletedCategory;
        SLBlock changeColorBlock = ^{
            UICollectionViewCell *lastSelectedCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:lastSelected inSection:0]];
            
            lastSelectedCell.layer.borderWidth = 0;
            UIButton *button1 = (UIButton *)[[lastSelectedCell.contentView subviews] lastObject];
            button1.backgroundColor = RGBCOLOR(240, 240, 240);
            [button1 setTitleColor:RGBCOLOR(132, 132, 132) forState:UIControlStateNormal];
            
            /////////////
            UICollectionViewCell *selectedCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            selectedCell.layer.borderWidth = 0.5;
            
            button.backgroundColor = [DADataEnvironment colorWithCategoryIndex:index];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        };
        
        NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
        NSUInteger doubanCategoryCount = doubanCategory.count;
        if (index < doubanCategoryCount) {
            _dataSource = [doubanCategory objectAtIndex:index];
            
            self.title = _dataSource[@"category"];
            [_tableView reloadData];
            
            _seletedCategory = index;
            
            changeColorBlock();
        }else {
            SLBlock loadMineDataBlock = ^{
                _seletedCategory = index;
                
                if(index == doubanCategoryCount){
                    _dataSource = @{@"category":NSLocalizedString(@"我的相册", nil), @"albums":[DADataEnvironment sharedDADataEnvironment].myAlbums};
                }else if(index == doubanCategoryCount+1){
                    _dataSource = @{@"category":NSLocalizedString(@"❤收藏", nil), @"albums":[DADataEnvironment sharedDADataEnvironment].collectedAlbums};
                }
                
                self.title = _dataSource[@"category"];
                [_tableView reloadData];
                
                changeColorBlock();
            };
            
            DoubanAuthEngine *engine = [DoubanAuthEngine sharedDoubanAuthEngine];
            if (![engine isValid]) {
                DALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DALoginViewController"];
                loginVC.finishedBlock = ^(id vc, id obj){
                    DoubanAuthEngine *engine = [DoubanAuthEngine sharedDoubanAuthEngine];
                    if ([engine isValid]) {
                        if (index == doubanCategoryCount) {
                            [DAHttpClient userAlbumsWithUserName:[@([[DOUOAuthStore sharedInstance] userId]) description]
                                                           start:0
                                                         success:^(NSArray *array) {
                                                             [DADataEnvironment sharedDADataEnvironment].myAlbums = [array mutableCopy];
                                                             loadMineDataBlock();
                                                         } error:^(NSInteger index) {
                                                             
                                                         } failure:^(NSError *error) {
                                                             
                                                         }];
                        }else if(index == doubanCategoryCount+1){
                            [DAHttpClient collectedAlbumsWithSuccess:^(NSArray *array) {
                                [DADataEnvironment sharedDADataEnvironment].collectedAlbums = [array mutableCopy];
                                
                                loadMineDataBlock();
                            } error:^(NSInteger index) {
                            } failure:^(NSError *error) {
                            }];
                        }
                    }
                };
                
                UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
                UIImage *nvImg = [UIImage imageNamed:@"bg_nav.png"];
                [nVC.navigationBar setBackgroundImage:nvImg forBarMetrics:UIBarMetricsDefault];
                
                [self presentViewController:nVC animated:YES completion:nil];
            }else{
                if (index == doubanCategoryCount && [DADataEnvironment sharedDADataEnvironment].myAlbums.count == 0) {
                    [DAHttpClient userAlbumsWithUserName:[@([[DOUOAuthStore sharedInstance] userId]) description]
                                                   start:0
                                                 success:^(NSArray *array) {
                                                     [DADataEnvironment sharedDADataEnvironment].myAlbums = [array mutableCopy];
                                                     loadMineDataBlock();
                                                 } error:^(NSInteger index) {
                                                     [self showFailTips:NSLocalizedString(@"请求出错", nil)];
                                                 } failure:^(NSError *error) {
                                                     [self showFailTips:NSLocalizedString(@"请求失败", nil)];
                                                 }];
                }else if(index == doubanCategoryCount+1 && [DADataEnvironment sharedDADataEnvironment].collectedAlbums.count == 0){
                    [DAHttpClient collectedAlbumsWithSuccess:^(NSArray *array) {
                        [DADataEnvironment sharedDADataEnvironment].collectedAlbums = [array mutableCopy];
                        
                        loadMineDataBlock();
                    } error:^(NSInteger index) {
                        [self showFailTips:NSLocalizedString(@"请求出错", nil)];
                    } failure:^(NSError *error) {
                        [self showFailTips:NSLocalizedString(@"请求失败", nil)];
                    }];
                }else {
                    loadMineDataBlock();
                }
            }
        }
    }
    
    [self showOrHideCategory:nil];
}

- (void)setTitle:(NSString *)title{
    UILabel *titleLbl = [self.navigationItem.titleView subviewWithTag:kTagTitleLbl];
    NSRange range = [title rangeOfString:@"&amp;"];
    if (range.location != NSNotFound) {
        NSMutableString *muString = [NSMutableString stringWithString:title];
        [muString replaceCharactersInRange:range withString:@"&"];
        titleLbl.text = muString;
    }else{
        titleLbl.text = title;
    }
    
    UIView *indiImgView = [self.navigationItem.titleView subviewWithTag:kTagTitleIndiImgView];
    
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    CGPoint center = CGPointMake(103, 22);
    center.x += [title sizeWithFont:font].width*0.5+indiImgView.width;
    indiImgView.center = center;
}

- (void)hideCategory:(UITapGestureRecognizer *)gesture{
    [self showOrHideCategory:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"去下载", nil)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_LINK_iTunes]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    if ([@"myAlbums" isEqualToString:keyPath]) {
//        NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
//        
//        if (_seletedCategory == doubanCategory.count) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _dataSource = @{@"category":NSLocalizedString(@"我的相册", nil), @"albums":[DADataEnvironment sharedDADataEnvironment].myAlbums};
//                
//                [_tableView reloadData];
//            });
//        }
    if ([@"collectedAlbums" isEqualToString:keyPath]) { //for add or delete collected album
        NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
        
        if (_seletedCategory == doubanCategory.count+1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _dataSource = @{@"category":NSLocalizedString(@"❤收藏", nil), @"albums":[DADataEnvironment sharedDADataEnvironment].collectedAlbums};
                
                [_tableView reloadData];
            });
        }
    }else if([@"douban_userdefaults_user_id" isEqualToString:keyPath]) { //for clear auth
        NSArray *doubanCategory = [_appData valueForKeyPath:@"cg_all"];
        
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        NSInteger userId  = [USER_DEFAULT integerForKey:@"douban_userdefaults_user_id"];
        
        if (old && !userId && _seletedCategory >= doubanCategory.count) {
            if (![[DoubanAuthEngine sharedDoubanAuthEngine] isValid]) {
                UICollectionViewCell *lastSelectedCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_seletedCategory inSection:0]];
                
                lastSelectedCell.layer.borderWidth = 0;
                UIButton *button1 = (UIButton *)[[lastSelectedCell.contentView subviews] lastObject];
                button1.backgroundColor = RGBCOLOR(240, 240, 240);
                [button1 setTitleColor:RGBCOLOR(132, 132, 132) forState:UIControlStateNormal];
                
                /////////////
                UICollectionViewCell *selectedCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                selectedCell.layer.borderWidth = 0.5;
                
                UIButton *button = (UIButton *)[[selectedCell.contentView subviews] lastObject];
                button.backgroundColor = [DADataEnvironment colorWithCategoryIndex:0];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                _dataSource = [doubanCategory objectAtIndex:0];
                
                self.title = _dataSource[@"category"];
                [_tableView reloadData];
                
                _seletedCategory = 0;
            }
        }
    }
}

@end
