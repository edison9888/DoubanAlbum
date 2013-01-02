//
//  DATagsLayout.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-13.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DATagsLayout.h"
#import <QuartzCore/QuartzCore.h>

@interface DATagsLayout ()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, strong) NSMutableArray *columnHeights; // height for each column
@property (nonatomic, strong) NSMutableArray *itemAttributes;

@end

@implementation DATagsLayout{
    CGFloat             _contentSizeHeight;
}

#pragma mark - Methods to Override

- (void)prepareLayout
{
    [super prepareLayout];
    
    UICollectionView *collectionView = [self collectionView];
    _itemCount = [collectionView numberOfItemsInSection:0];
    
    if (_itemCount == 0) return;
    
    UIInterfaceOrientation oritation = [[collectionView viewController] interfaceOrientation];
    
    CGFloat gap = 5.0;
    
    _itemAttributes = [NSMutableArray arrayWithCapacity:_itemCount];
    
    UIFont *font = [UIFont boldSystemFontOfSize:14];

    CGFloat offsetX = 10;
    CGFloat X = 10;
    CGFloat Y = 10;
    
    NSUInteger count = _category.count;
    int idx = 0;
    for (; idx<count+2; idx++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        NSString *title = nil;
        if (idx < count) {
            title = _category[idx][@"category"];
        }else if(idx == count){
            title = NSLocalizedString(@"我的相册", nil);
        }else if(idx == count+1){
            title = NSLocalizedString(@"❤收藏", nil);
        }
        CGFloat titleW = [title sizeWithFont:font].width;
        CGFloat bunW = titleW+17;
        
        if (idx == 0) {
            attributes.frame = CGRectMake(X, Y, bunW, 30);
        }else{
            UICollectionViewLayoutAttributes *lastAttributes = [_itemAttributes objectAtIndex:idx-1];
            CGRect lastFrame = lastAttributes.frame;
            
            CGFloat x = lastFrame.origin.x + lastFrame.size.width + gap;
            if (x+bunW > (UIInterfaceOrientationIsPortrait(oritation)?APP_SCREEN_WIDTH:APP_SCREEN_HEIGHT)-offsetX*2-gap) {
                attributes.frame = CGRectMake(10, lastFrame.origin.y+lastFrame.size.height+gap, bunW, 30);
            }else{
                lastFrame.origin.x = x;
                lastFrame.size.width = bunW;
                attributes.frame = lastFrame;
            }
        }
        
//        SLog(@"(%f, %f, %f , %f)", attributes.frame.origin.x, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height);
        
        [_itemAttributes addObject:attributes];
    }
    
    UICollectionViewLayoutAttributes *lastAttributes = [_itemAttributes lastObject];
    CGFloat bottom = lastAttributes.frame.origin.y+lastAttributes.frame.size.height;
    
    collectionView.height = bottom+10;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:collectionView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    maskLayer.path = path.CGPath;
    collectionView.layer.mask = maskLayer;
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = self.collectionView.frame.size;
    
    UICollectionViewLayoutAttributes *lastAttributes = [_itemAttributes lastObject];
    CGFloat bottom = lastAttributes.frame.origin.y+lastAttributes.frame.size.height;
    contentSize.height = bottom+10;
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    return _itemAttributes[path.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return _itemAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


@end
