//
//  DAWaterfallLayout.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-11.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAWaterfallLayout.h"
#import "DAPhotoWallViewController.h"
#import "DAHtmlRobot.h"

@interface DAWaterfallLayout ()
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, strong) NSMutableArray *columnHeights; // height for each column
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
@end

@implementation DAWaterfallLayout{
    CGFloat         nextStyleY;
    
    NSUInteger countForStyle0;
    NSUInteger countForStyle1;
    NSUInteger countForStyle2;
    NSUInteger countForStyle3;
    
    NSUInteger style;
    
    BOOL        needNewStyle;
    
    BOOL        _hasConfigNameAndDescribeLayout;
}

- (void)clearLayoutAttributes{
    _hasConfigNameAndDescribeLayout = NO;
    needNewStyle = YES;
    
    countForStyle0 = 0;
    countForStyle1 = 0;
    countForStyle2 = 0;
    countForStyle3 = 0;
    style = 0;
    
    nextStyleY = 65;
    
    _allItemAttributes = [NSMutableArray arrayWithCapacity:[[self collectionView] numberOfItemsInSection:0]];
}

- (UICollectionViewLayoutAttributes *)lastAttributsFrom:(NSArray *)itemsAttributes{
    if (itemsAttributes.count > 0) {
        return [itemsAttributes lastObject];
    }else{
        return [_allItemAttributes lastObject];
    }
}

- (UICollectionViewLayoutAttributes *)lastSecondAttributsFrom:(NSArray *)itemsAttributes{
    NSUInteger count = itemsAttributes.count;
    if (count >= 2) {
        return [itemsAttributes objectAtIndex:count-2];
    }else if(count == 1){
        return [_allItemAttributes lastObject];
    }else{
        return [_allItemAttributes objectAtIndex:_allItemAttributes.count-2];
    }
}

- (UICollectionViewLayoutAttributes *)lastThirdAttributsFrom:(NSArray *)itemsAttributes{
    NSUInteger count = itemsAttributes.count;
    if (count >= 3) {
        return [itemsAttributes objectAtIndex:count-3];
    }else if(count == 2){
        return [_allItemAttributes lastObject];
    }else if(count == 1){
        return [_allItemAttributes objectAtIndex:_allItemAttributes.count-2];
    }else{
        return [_allItemAttributes objectAtIndex:_allItemAttributes.count-3];
    }
}

#pragma mark - Accessors

//- (void)setItemWidth:(CGFloat)itemWidth
//{
//    if (_itemWidth != itemWidth) {
//        _itemWidth = itemWidth;
//        [self invalidateLayout];
//    }
//}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        nextStyleY = 65;
        
        _allItemAttributes = [[NSMutableArray alloc] initWithCapacity:[[DAHtmlRobot commandFor:kPhotosInAlbumCountPerPage] integerValue]+3];
    }
    
    return self;
}

- (NSUInteger)countOfAlbumTitleAndDescribe{
    return [((DAPhotoWallViewController *)[self.collectionView dataSource]) countOfAlbumTitleAndDescribe];
}

- (void)configTitleAndDescribeHeaderViewWithCount:(NSUInteger)albumNDCount itemAttributes:(NSMutableArray *)itemAttributes{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat width = [self collectionView].width;
    if (albumNDCount == 1) {
        attributes.frame = CGRectMake(0, 0, width-10, 60);
    }else{
        attributes.frame = CGRectMake(0, 0, width*90/300, 60);
    }
    
    [itemAttributes addObject:attributes];
    if (albumNDCount == 2) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        UICollectionViewLayoutAttributes *attributes =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGFloat x = width*90/300+5;
        attributes.frame = CGRectMake(x, 0, width-10-x, 60);
        
        [itemAttributes addObject:attributes];
    }
}

#pragma mark - Methods to Override

//TODO 糟糕的代码
- (void)prepareLayout
{
    [super prepareLayout];
    
    UICollectionView *collectionView = [self collectionView];
    NSUInteger totalItemCount = [collectionView numberOfItemsInSection:0];
    if (totalItemCount == 0) return;
    
    UIInterfaceOrientation oritation = [[collectionView viewController] interfaceOrientation];
    
    NSUInteger itemCount = 0;
    NSUInteger titleDesItemCount = 0;
    if (!_hasConfigNameAndDescribeLayout) { //first time
        titleDesItemCount = [self countOfAlbumTitleAndDescribe];
        if (titleDesItemCount == totalItemCount) return;
        
        _hasConfigNameAndDescribeLayout = YES;
        
        itemCount = totalItemCount-titleDesItemCount;
        
        [self configTitleAndDescribeHeaderViewWithCount:titleDesItemCount itemAttributes:_allItemAttributes];
        
        if (itemCount <= 2) {
            style = 0;
        }else if(itemCount == 3){
            style = rand()%2+1; //1, 2
        }else if(itemCount == 4){
            style = 3;
        }else{
            style = rand()%(MIN(itemCount, 4)); //0, 1, 2, 3
        }
    }else{
        itemCount = [collectionView numberOfItemsInSection:0]-_allItemAttributes.count;
        
        if (itemCount == 0) return;
    }

    CGFloat contentWidth = collectionView.width-2*5;
    
    NSUInteger X = 0;
    NSUInteger Y = 0;
    
    NSUInteger min = 100;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:[[DAHtmlRobot commandFor:kPhotosInAlbumCountPerPage] integerValue]];
    
    NSUInteger start = _allItemAttributes.count;
    for (NSInteger idx = start; idx < itemCount+start; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        UICollectionViewLayoutAttributes *attributes =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        if (style == 0) {
            if (countForStyle0 == 0) {
                X = 0;
                Y = nextStyleY;
                
                if (UIInterfaceOrientationIsPortrait(oritation)) {
                    width = arc4random()%(195-100)+100;
                }else{
                    width = arc4random()%(295-200)+200;
                }
                
                height = 100;
                countForStyle0++;
                
                needNewStyle = NO;
            }else{
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.size.width+5.0;
                Y = lastFrame0.origin.y;
                
                width = contentWidth-lastFrame0.size.width-5.0;
                height = lastFrame0.size.height;
                
                nextStyleY = Y+height+5.0;
                countForStyle0 = 0;
                
                needNewStyle = YES;
            }
        }else if(style == 1){
            if (countForStyle1 == 0) {
                X = 0;
                Y = nextStyleY;
                
                if (UIInterfaceOrientationIsPortrait(oritation)) {
                    width = arc4random()%(195-100)+100;
                }else{
                    width = arc4random()%(295-200)+200;
                }
                
                height = arc4random()%(260-255)+255;
                
                countForStyle1++;
                needNewStyle = NO;
            }else if (countForStyle1 == 1) {
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.size.width+5.0;
                Y = nextStyleY;
                
                width = contentWidth-lastFrame0.size.width-5.0;
                height = arc4random()%(120-min)+min;
                
                nextStyleY = Y+height+5.0;
                countForStyle1++;
                needNewStyle = NO;
            }else{
                UICollectionViewLayoutAttributes *attributes1 = [self lastSecondAttributsFrom:itemAttributes];
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.origin.x;
                Y = lastFrame0.origin.y+lastFrame0.size.height+5.0;
                
                width = lastFrame0.size.width;
                
                CGRect lastFrame1 = attributes1.frame;
                height = lastFrame1.size.height-lastFrame0.size.height-5.0;
                
                nextStyleY = Y+height+5.0;
                countForStyle1 = 0;
                needNewStyle = YES;
            }
        }else if(style == 2){
            if (countForStyle2 == 0) {
                X = 0;
                Y = nextStyleY;
                
                if (UIInterfaceOrientationIsPortrait(oritation)) {
                    width = arc4random()%(195-100)+100;
                }else{
                    width = arc4random()%(295-200)+200;
                }
                
                height = arc4random()%(120-min)+min;
                
                countForStyle2++;
                needNewStyle = NO;
            }else if (countForStyle2 == 1) {
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.origin.x;
                Y = lastFrame0.origin.y+lastFrame0.size.height+5.0;
                
                width = lastFrame0.size.width;
                height = arc4random()%(150-min)+min;
                
                countForStyle2++;
                needNewStyle = NO;
            }else if (countForStyle2 == 2) {
                UICollectionViewLayoutAttributes *attributes1 = [self lastSecondAttributsFrom:itemAttributes];
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                
                CGRect frame1 = attributes1.frame;
                CGRect frame0 = attributes.frame;
                
                X = frame0.origin.x+frame0.size.width+5.0;
                Y = frame1.origin.y;
                
                width = contentWidth-frame0.size.width-5.0;
                height = frame1.size.height+frame0.size.height+5.0;
                
                nextStyleY = Y+height+5.0;
                countForStyle2 = 0;
                needNewStyle = YES;
            }
        }else if(style == 3){
            if (countForStyle3 == 0) {
                X = 0;
                Y = nextStyleY;
                
                if (UIInterfaceOrientationIsPortrait(oritation)) {
                    width = arc4random()%(195-100)+100;
                }else{
                    width = arc4random()%(295-200)+200;
                }
                
                height = arc4random()%(120-min)+min;
                
                countForStyle3++;
                needNewStyle = NO;
            }else if (countForStyle3 == 1) {
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.origin.x;
                Y = lastFrame0.origin.y+lastFrame0.size.height+5.0;
                
                width = lastFrame0.size.width;
                height = arc4random()%(120-min)+min;
                
                countForStyle3++;
                needNewStyle = NO;
            }else if (countForStyle3 == 2) {
                UICollectionViewLayoutAttributes *attributes1 = [self lastSecondAttributsFrom:itemAttributes];
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                
                CGRect lastFrame1 = attributes1.frame;
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.size.width+5.0;
                Y = lastFrame1.origin.y;
                
                width = contentWidth-lastFrame0.size.width-5.0;
                height = arc4random()%(120-min)+min;
                
                nextStyleY = Y+height+5.0;
                countForStyle3++;
                needNewStyle = NO;
            }else{
                UICollectionViewLayoutAttributes *attributes2 = [self lastThirdAttributsFrom:itemAttributes];
                UICollectionViewLayoutAttributes *attributes1 = [self lastSecondAttributsFrom:itemAttributes];
                UICollectionViewLayoutAttributes *attributes = [self lastAttributsFrom:itemAttributes];
                
                CGRect lastFrame2 = attributes2.frame;
                CGRect lastFrame1 = attributes1.frame;
                CGRect lastFrame0 = attributes.frame;
                
                X = lastFrame0.origin.x;
                Y = lastFrame0.origin.y+lastFrame0.size.height+5.0;
                
                width = lastFrame0.size.width;
                height = lastFrame2.size.height+lastFrame1.size.height-lastFrame0.size.height;;
                
                nextStyleY = Y+height+5.0;
                countForStyle3 = 0;
                needNewStyle = YES;
            }
        }
        
//        SLLog(@"style %d (%d %d %d %d), (%d %d %.1f %.1f)", style, countForStyle0, countForStyle1, countForStyle2, countForStyle3, X, Y, width, height);
        attributes.frame = CGRectMake(X, Y, width, height);
        
        if (Y+height >= _contentSizeHeight) {
            _contentSizeHeight = Y+height;
        }
        
        if (needNewStyle) {
            NSUInteger remainder = itemCount-(idx-start);
            if (remainder <= 2) {
                style = 0;
            }else if(remainder == 3){
                style = rand()%2+1; //1, 2
            }else if(remainder == 4){
                style = 3;
            }else{
                NSUInteger originStyle = style;
                style = rand()%(MIN(remainder, 4));
                
                if (originStyle == style) {
                    if (style >= 1) {
                        style--;
                    }else{
                        style = 3;
                    }
                }
            }
        }
        
        [itemAttributes addObject:attributes];
    }

    [_allItemAttributes addObjectsFromArray:itemAttributes];
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = self.collectionView.frame.size;
    contentSize.height = _contentSizeHeight+5.0+20+5.0;
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    
    CGRect frame = attributes.frame;
    frame.origin.y = _contentSizeHeight+5.0;
    attributes.frame = frame;
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    return _allItemAttributes[path.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{   
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:_allItemAttributes];
    [muArr addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    
    return muArr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

#pragma mark - Private Methods

// Find out shortest column.
- (NSUInteger)shortestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

// Find out longest column.
- (NSUInteger)longestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

- (CGFloat)itemHeight{
    return arc4random()%100*2+100;
}

@end
