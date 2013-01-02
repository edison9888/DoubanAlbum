//
//  DAScanePhotoLayout.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-19.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAScanePhotoLayout.h"

@interface DAScanePhotoLayout ()

@property (nonatomic, strong) NSMutableArray *itemAttributes;

@end

@implementation DAScanePhotoLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    UICollectionView *collectionView = [self collectionView];
    NSUInteger itemCount = [collectionView numberOfItemsInSection:0];
    
    if (itemCount == 0) return;
    
    _itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
    
    BOOL portraite = self.collectionView.width < self.collectionView.height;
    
    int idx = 0;
    for (; idx<itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        if (portraite) {
            attributes.frame = CGRectMake(10+idx*self.collectionView.width, 30, 300, self.collectionView.height-60);
        }else{
            attributes.frame = CGRectMake(30+idx*self.collectionView.width, 10, self.collectionView.width-60, 300);
        }
        
        [_itemAttributes addObject:attributes];
    }
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = self.collectionView.frame.size;
    
    UICollectionView *collectionView = [self collectionView];
    NSUInteger itemCount = [collectionView numberOfItemsInSection:0];
    
    contentSize.width = itemCount*self.collectionView.width;
    
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
