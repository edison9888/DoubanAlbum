//
//  DAHttpClient.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-9.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "AFHTTPClient.h"

@interface DAHttpClient : AFHTTPClient{
    NSString        *_apiBaseUrlString;
}

+ (DAHttpClient *)sharedDAHttpClient;

///user

+ (void)incrementActivityCount;

+ (void)decrementActivityCount;

+ (void)myProfileWithSuccess:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

+ (void)userProfileWithId:(NSString *)userId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

///album basic

+ (void)albumInfoWithId:(NSUInteger)albumId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

+ (void)photosInAlbumWithId:(NSUInteger)albumId start:(NSUInteger)start success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

+ (void)photoWithId:(NSUInteger)photoId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

///album advanced

+ (void)userAlbumsWithUserName:(NSString *)userName start:(NSUInteger)start success:(SLArrayBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

////user notes
+ (void)likeAlbumWithAlbumDic:(NSDictionary *)albumDic like:(BOOL)like success:(SLIndexBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc;

+ (void)createOrUpdateNoteWithParameters:(NSDictionary *)para update:(BOOL)update success:(SLIndexBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc;

+ (void)collectedAlbumsWithSuccess:(SLArrayBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;

+ (void)doubanShuoWithParameters:(NSDictionary *)para success:(SLBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc;
@end
