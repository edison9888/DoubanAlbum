//
//  DADataEnvironment.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-16.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DADataEnvironment.h"
#import "SINGLETONGCD.h"
#import "DOUOAuthStore.h"
#import "JSONKit.h"
#import "DoubanAuthEngine.h"

NSString * const Key_Album_Id = @"album_id";
NSString * const Key_Album_Name = @"album_name";
NSString * const Key_Album_Cover = @"album_cover"; //img3.douban.com/...
NSString * const Key_Album_Describe = @"album_describe";

NSString * const Key_Douban_Collected_Albums_Note_Name = @"豆瓣相册 (精选集) 我的收藏";

static const char *CategoryColors =
"208,138,138;"
"217,183,141;"
"228,230,144;"
"189,230,144;"
"170,229,144;"

"171,229,186;"
"170,229,229;"
"153,184,228;"
"139,139,227;"
"151,122,198;"

"208,138,226;"
"208,139,182;"
"208,138,140";

@implementation DADataEnvironment

SINGLETON_GCD(DADataEnvironment)

+ (UIColor *)colorWithCategoryIndex:(NSUInteger)index{
    NSString *colorString = [[NSString alloc] initWithBytes:CategoryColors length:strlen(CategoryColors) encoding:NSUTF8StringEncoding];
    
    NSArray *array = [colorString componentsSeparatedByString:@";"];
    NSString *string = [array objectAtIndex:MIN(array.count-1, index)];
    
    NSArray *color = [string componentsSeparatedByString:@","];
    return RGBCOLOR([color[0] integerValue], [color[1] integerValue], [color[2] integerValue]);
}

+ (UIColor *)colorForTitleAndDescribe{
    NSString *colorString = [[NSString alloc] initWithBytes:CategoryColors length:strlen(CategoryColors) encoding:NSUTF8StringEncoding];
    
    NSArray *array = [colorString componentsSeparatedByString:@";"];
    NSUInteger index = arc4random()%array.count;
    
    NSString *string = [array objectAtIndex:MIN(array.count-1, index)];
    
    NSArray *color = [string componentsSeparatedByString:@","];
    
    return [UIColor colorWithRed:([color[0] integerValue]/255.0) green:[color[1] integerValue]/255.0 blue:[color[2] integerValue]/255.0 alpha:.5];
}

- (NSMutableArray *)myAlbums{
    if (!_myAlbums) {
        _myAlbums = [NSMutableArray arrayWithCapacity:4];
    }
    
    return _myAlbums;
}

- (NSMutableArray *)collectedAlbums{
    if (!_collectedAlbums) {
        _collectedAlbums = [NSMutableArray arrayWithCapacity:4];
    }
    
    return _collectedAlbums;
}

+ (void)addCollectAlbum:(NSDictionary *)albumDic{
    DADataEnvironment *env = [DADataEnvironment sharedDADataEnvironment];
    NSMutableArray *collectedAlbums = [env mutableArrayValueForKey:@"collectedAlbums"]; //KVO
    
    NSArray *albumIds = [collectedAlbums valueForKeyPath:Key_Album_Id];
    
    id albumId = albumDic[Key_Album_Id];
    NSUInteger index = [albumIds indexOfObject:[albumId description]];
    if (index != NSNotFound) {
        [collectedAlbums removeObjectAtIndex:index];
    }
    
    [collectedAlbums addObject:albumDic];
}

+ (void)removeCollectAlbum:(NSDictionary *)albumDic{
    DADataEnvironment *env = [DADataEnvironment sharedDADataEnvironment];
    NSMutableArray *collectedAlbums = [env mutableArrayValueForKey:@"collectedAlbums"]; //KVO
    
    NSArray *albumIds = [collectedAlbums valueForKeyPath:Key_Album_Id];
    
    id albumId = albumDic[Key_Album_Id];
    NSUInteger index = [albumIds indexOfObject:[albumId description]];
    if (index != NSNotFound) {
        [collectedAlbums removeObjectAtIndex:index];
    }
}

+ (void)clear{
    DADataEnvironment *env = [DADataEnvironment sharedDADataEnvironment];
    [env.myAlbums removeAllObjects];
    [env.collectedAlbums removeAllObjects];
}

@end
