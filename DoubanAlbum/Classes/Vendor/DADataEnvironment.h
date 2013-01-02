//
//  DADataEnvironment.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-16.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const Key_Album_Id;
extern NSString * const Key_Album_Name;
extern NSString * const Key_Album_Cover;
extern NSString * const Key_Album_Describe;

extern NSString * const Key_Douban_Collected_Albums_Note_Name;

extern NSString * const kPhotosInAlbumUrlFomater;

@interface DADataEnvironment : NSObject

@property (nonatomic, strong) NSMutableArray *myAlbums;
@property (nonatomic, strong) NSMutableArray *collectedAlbums;

+ (DADataEnvironment *)sharedDADataEnvironment;

+ (NSString *)contentForCollentedAlbumNoteWithAlubmInfo:(NSDictionary *)albumDic like:(BOOL)like;

+ (void)clear;

+ (UIColor *)colorWithCategoryIndex:(NSUInteger)index;

+ (UIColor *)colorForTitleAndDescribe;

+ (void)addCollectAlbum:(NSDictionary *)dic;

+ (void)removeCollectAlbum:(NSDictionary *)dic;

@end
