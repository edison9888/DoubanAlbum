//
//  DAHtmlRobot.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-10.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kPhotosInAlbumCountPerPage;
extern NSString * const kPhotosInAlbumUrlFomater;

typedef enum{
    DoubanDataTypePhotosInAlbum,
    DoubanDataTypeAlbumsForUser,
}DoubanDataType;

@interface DAHtmlRobot : NSObject{
    
}

+ (void)setRobotCommands:(NSDictionary *)dic;

+ (NSString *)commandFor:(NSString *)key;

+ (DAHtmlRobot *)sharedDAHtmlRobot;

+ (void)initialCacheFolder;

+ (void)requestCategoryLocalData:(SLDictionaryBlock)localBolck completion:(SLDictionaryBlock)completion;

+ (void) photosInAlbum:(NSUInteger)albumId start:(NSUInteger)start completion:(SLDictionaryBlock)completion;

+ (void)userAlbumsWithUserName:(NSString *)userName start:(NSUInteger)start completion:(SLArrayBlock)completion;

@end

@interface DAHtmlRobot (Cache)

+ (NSDictionary *)latestDoubanAlbumData;

+ (BOOL)cacheDoubanAlbumData:(NSDictionary *)result;

+ (void)cachedDataWithAlbumId:(NSUInteger)albumId userName:(NSString *)userName start:(NSUInteger)start completion:(SLObjectBlock)completion;

+ (void)cachedAlbumsForUser:(NSString *)userName start:(NSUInteger)start completion:(SLArrayBlock)completion;
+ (void)cacheAlbums:(NSArray *)albums forUser:(NSString *)userName start:(NSUInteger)start;

+ (void)cachedPhotosForAlbum:(NSUInteger)albumId start:(NSUInteger)start completion:(SLArrayBlock)completion;
+ (void)cachePhotos:(NSArray *)photos forAlbum:(NSUInteger)albumId start:(NSUInteger)start;

+ (void)cacheData:(NSArray *)data forUser:(NSString *)userName forAlbum:(NSUInteger)albumId start:(NSUInteger)start;

+ (void)cacheAlbumDescribe:(NSString *)des forAlbum:(NSUInteger)albumId;

+ (void)emptyDisk;

+ (void)cleanOuttimeImageInDisk;

@end
