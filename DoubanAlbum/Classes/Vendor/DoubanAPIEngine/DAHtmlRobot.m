//
//  DAHtmlRobot.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-10.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAHtmlRobot.h"
#import "SINGLETONGCD.h"
#import "GCDHelper.h"
#import "NSStringAddition.h"
#import "JSONKit.h"
#import "DAHttpClient.h"

static NSInteger const CacheMaxCacheAge = 60*60*24*1; // 5 days, it's safe within 5 days, not been clean when cleanM

static NSString * const kDoubanAlbumDataPath = @"DoubanAlbumData";
static NSString * const kPhotosInAlbumPath = @"PhotosInAlbum";
static NSString * const kUserAlbumPath = @"AlbumsForUser";

//相册 url
NSString * const kPhotosInAlbumUrlFomater = @"pa_urlformater"; //@"http://www.douban.com/photos/album/%@?start=%d",
NSString * const kPhotosInAlbumCountPerPage = @"pa_cperpage";//18
//相册 照片Id
static NSString * const kPhotosIdInAlbumExpression = @"pa_id_express";//http://www.douban.com/photos/photo/[0-9]*/
//相册 相册描述
static NSString * const kAlbumDescribeExpression = @"pa_de_express";//<div id=\"link-report\" class=\"pl\" style=\"padding-bottom:30px\">

///////////////////////////////////////////////////

//相册集 url
static NSString * const kUserAlbumUrlFomater = @"ua_urlfomater"; //http://www.douban.com/people/%@/photos?start=%d
static NSString * const kUserAlbumCountPerPage = @"ua_cperpage"; //16
//相册集 相册id
static NSString * const kUserAlbumIdExpression = @"ua_id_express"; //http://www.douban.com/photos/album/[0-9]*/
//相册集 相册封面
static NSString * const kAlbumCoverInUserAlbumsExpression = @"uac_express";//<img class=\"album\" src=\"http://
//相册集 相册名字
static NSString * const kAlbumNameInUserAlbumsExpress = @"ua_name_express"; //<a href=\"http://www.douban.com/photos/album/%@/\">

static NSDictionary *RobotCommands_Default;
static NSMutableDictionary *RobotCommands;

@implementation DAHtmlRobot

SINGLETON_GCD(DAHtmlRobot)

+ (void)initialize{
    if (self == [DAHtmlRobot class]) {
        [self initialCacheFolder];
        
        RobotCommands_Default = @{
            kPhotosIdInAlbumExpression:@"http://www.douban.com/photos/photo/[0-9]*/",
            kAlbumDescribeExpression:@"<div id=\"link-report\" class=\"pl\" style=\"padding-bottom:30px\">",
            kUserAlbumIdExpression:@"http://www.douban.com/photos/album/[0-9]*/",
            kAlbumCoverInUserAlbumsExpression:@"<img class=\"album\" src=\"http://",
        
            kUserAlbumUrlFomater:@"http://www.douban.com/people/%@/photos?start=%d",
            kPhotosInAlbumUrlFomater:@"http://www.douban.com/photos/album/%@?start=%d",
        
            kAlbumNameInUserAlbumsExpress:@"<a href=\"http://www.douban.com/photos/album/%@/\">",
        
            kUserAlbumCountPerPage:@(16),
            kPhotosInAlbumCountPerPage:@(18)
        };
    }
}

+ (void)setRobotCommands:(NSDictionary *)dic{
    SLLog(@"dic %@", dic);
    
    if (dic.count == RobotCommands_Default.count) {
        RobotCommands = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        NSString *httpString = @"http___3ww.";
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
            NSMutableString *muObj = [NSMutableString stringWithString:obj];;
            
            NSRange range = [obj rangeOfString:httpString];
            if (range.location != NSNotFound) {
                muObj = [NSMutableString stringWithString:obj];
                [muObj replaceCharactersInRange:range withString:@"http://www."];
            }
        
            range = [muObj rangeOfString:@"&lt;"];
            while (range.location != NSNotFound) {
                [muObj replaceCharactersInRange:range withString:@"<"];
                range = [muObj rangeOfString:@"&lt;"];
            }
            
            range = [muObj rangeOfString:@"&gt;"];
            while (range.location != NSNotFound) {
                [muObj replaceCharactersInRange:range withString:@">"];
                range = [muObj rangeOfString:@"&gt;"];
            }
            
            RobotCommands[key] = muObj;
        }];
        
        SLLog(@"RobotCommands %@", RobotCommands);
    }
}

+ (NSString *)commandFor:(NSString *)key{
    if (RobotCommands) {
        return RobotCommands[key];
    }else{
        return RobotCommands_Default[key];
    }
}

+ (void)initialCacheFolder{
    [GCDHelper dispatchBlock:^{
        NSString *categoryPath = [APP_CACHES_PATH stringByAppendingPathComponent:kDoubanAlbumDataPath];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:categoryPath])
        {
            [manager createDirectoryAtPath:categoryPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        }
        
        NSString *photoListInAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kPhotosInAlbumPath];
        
        if (![manager fileExistsAtPath:photoListInAlbumCachePath])
        {
            [manager createDirectoryAtPath:photoListInAlbumCachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        }
        
        NSString *albumListForUserCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kUserAlbumPath];
        if (![manager fileExistsAtPath:albumListForUserCachePath])
        {
            [manager createDirectoryAtPath:albumListForUserCachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        }
    } completion:^{
        [self cleanOuttimeImageInDisk];
    }];
}

+ (NSOperationQueue *)sharedOperationQueue {
    static NSOperationQueue *_operationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _operationQueue;
}

+ (void)requestCategoryLocalData:(SLDictionaryBlock)localBolck completion:(SLDictionaryBlock)completion{
    
    if (localBolck) {
        localBolck([self latestDoubanAlbumData]);
    }
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"DoubanAlbumData_Local" ofType:@"plist"];
//    
//    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
//    completion(dic);
//#warning  
//    return;
    
    static NSString *url  = @"http://www.douban.com/note/251470569/";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[self sharedOperationQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               __block BOOL needUpdateView = YES;
                               __block id result = nil;
                               [GCDHelper dispatchBlock:^{
                                   NSString *resultString = nil;
                                   if (error == nil) {
                                       NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       NSRange startR = [html rangeOfString:@"---start---"];
                                       NSRange endR = [html rangeOfString:@"---end---"];
                                       
                                       if (startR.location != NSNotFound && endR.location != NSNotFound) {
                                           NSUInteger start = startR.location+startR.length;
                                           NSString *content = [html substringWithRange:NSMakeRange(start, endR.location-start)];
                                           
                                           NSMutableString *muString = [NSMutableString stringWithString:content];
                                           
                                           NSRange range = [muString rangeOfString:@"&quot;"];
                                           while (range.location != NSNotFound) {
                                               [muString replaceCharactersInRange:range withString:@"\""];
                                               range = [muString rangeOfString:@"&quot;"];
                                           }
                                           
                                           SLLog(@"content %@", muString);
                                           
                                           resultString = muString;
                                       }
                                   }
                                   
                                   if (resultString == nil) {
                                       NSString *path = [[NSBundle mainBundle] pathForResource:@"DoubanAlbumData_Local" ofType:@"plist"];
                                       result = [NSDictionary dictionaryWithContentsOfFile:path];
                                   }else{
                                       result = [resultString objectFromJSONString];
                                       
                                       if ([result count] > 0) {
                                           needUpdateView = [self cacheDoubanAlbumData:result];
                                       }
                                   }
                               } completion:^{
                                   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:result];
                                   dic[@"needUpdateView"] = @(needUpdateView);
                                   
                                   completion(dic);
                               }];
                           }];

}

+ (void) photosInAlbum:(NSUInteger)albumId start:(NSUInteger)start completion:(SLDictionaryBlock)completion{
    [self dataWithDataType:DoubanDataTypePhotosInAlbum
                  userName:nil
                   albumId:albumId
                     start:start
                completion:^(id dic) {
                    completion(dic);
                }];
}

+ (void)userAlbumsWithUserName:(NSString *)userName start:(NSUInteger)start completion:(SLArrayBlock)completion{
    [self dataWithDataType:DoubanDataTypeAlbumsForUser
                  userName:userName
                   albumId:0
                     start:start
                completion:^(id array) {
                    completion(array);
                }];
}

+ (void)dataWithDataType:(DoubanDataType)dataType userName:(NSString *)userName albumId:(NSUInteger)albumId start:(NSUInteger)start completion:(SLObjectBlock)completion{
    NSString *fomatter = nil;
    NSUInteger countPerPage = 0;
    NSString *target = nil;

    if (dataType == DoubanDataTypeAlbumsForUser) { //用户相册列表
        fomatter = [self commandFor:kUserAlbumUrlFomater];
        countPerPage = [[self commandFor:kUserAlbumCountPerPage] integerValue];
        
        target = userName;
    }else if (dataType == DoubanDataTypePhotosInAlbum) { ////相册图片
        fomatter = [self commandFor:kPhotosInAlbumUrlFomater];
        countPerPage = [[self commandFor:kPhotosInAlbumCountPerPage] integerValue];
        
        target = [@(albumId) description];
    }
    
    [self cachedDataWithAlbumId:albumId
                       userName:userName
                          start:start
                     completion:^(id dic) {
                         NSUInteger count = 0;
                         if (dataType == DoubanDataTypePhotosInAlbum){
                             count = [[dic valueForKey:@"photoIds"] count];
                         }else{
                             count = [dic count];
                         }
                         
                         if (count == countPerPage) {
                             completion(dic);
                         }else{
                             NSString *url = [NSString stringWithFormat:fomatter, target, start];
                             
                             SLLog(@"url %@", url);
                             
                             [DAHttpClient incrementActivityCount];
                             NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                             [NSURLConnection sendAsynchronousRequest:request
                                                                queue:[self sharedOperationQueue]
                                                    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                        [DAHttpClient decrementActivityCount];
                                                        
                                                        if (error == nil) {
                                                            __block id results = nil;
                                                            [GCDHelper dispatchBlock:^{
                                                                if (dataType == DoubanDataTypePhotosInAlbum){
                                                                    results = [NSMutableDictionary dictionaryWithCapacity:2];
                                                                    
                                                                    [self analysePhotosInAlbumWithData:data withResults:results express:[self commandFor:kPhotosIdInAlbumExpression]];
                                                                    
                                                                    [self cacheData:results[@"photoIds"] forUser:nil forAlbum:albumId start:start];
                                                                    
                                                                    NSString *des = results[Key_Album_Describe];
                                                                    if (des.length > 0) {
                                                                        [DAHtmlRobot cacheAlbumDescribe:des forAlbum:albumId];
                                                                    }
                                                                }else{
                                                                    results = [NSMutableArray arrayWithCapacity:countPerPage];
                                                                    
                                                                    [self analyseUserAlbumsWithData:data withResults:results];
                                                                    
                                                                    [self cacheData:results forUser:userName forAlbum:0 start:start];
                                                                }
                                                            } completion:^{
                                                                completion(results);
                                                            }];
                                                        }else{
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(nil);
                                                            });
                                                        }
                                                    }];
                         }
                     }];
}

+ (void)analysePhotosInAlbumWithData:(NSData *)data withResults:(NSMutableDictionary *)results express:(NSString *)express{
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *err;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:express
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&err];
    if (err == nil) {
        NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        NSMutableArray *photoIds = [NSMutableArray arrayWithCapacity:matches.count];
        for (NSTextCheckingResult *result in matches) {
            NSUInteger preL = [express rangeOfString:@"[0"].location;
            
            NSString *photo = [html substringWithRange:NSMakeRange(result.range.location+preL, result.range.length-preL-1)];
            if (![photoIds containsObject:photo]) {
                [photoIds addObject:photo];
            }
        }
        
        results[@"photoIds"] = photoIds;
    }
    
    ////////抓 相册描述
    regex = [[NSRegularExpression alloc] initWithPattern:[self commandFor:kAlbumDescribeExpression]
                                                 options:NSRegularExpressionCaseInsensitive
                                                   error:&err];
    if (err == nil) {
        NSArray *matches = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, [html length])];
        NSTextCheckingResult *result = [matches lastObject];
        if (result) {
            NSUInteger start = result.range.location+result.range.length;
            
            NSUInteger end = [html rangeOfString:@"</div>" options:0 range:NSMakeRange(start, html.length-start-1)].location;
            
            NSString *describe = [html substringWithRange:NSMakeRange(start, end-start)];
            results[Key_Album_Describe] = describe;
        }
    }
    
    SLLog(@"count %d \n%@ %@", [results count], @"photos", results);
}

+ (void)analyseUserAlbumsWithData:(NSData *)data withResults:(NSMutableArray *)results{
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *err;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[self commandFor:kUserAlbumIdExpression]
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&err];
    if (err == nil) {
        NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        NSMutableArray *temAlbum = [NSMutableArray arrayWithCapacity:matches.count];
        
        NSUInteger preL = [[self commandFor:kUserAlbumIdExpression] rangeOfString:@"[0"].location;
        for (NSTextCheckingResult *result0 in matches) {
            NSString *albumId = [html substringWithRange:NSMakeRange(result0.range.location+preL, result0.range.length-preL-1)];
            if (![temAlbum containsObject:albumId]) {
                [temAlbum addObject:albumId];
                
                NSMutableDictionary *albumDic = [NSMutableDictionary dictionaryWithCapacity:3];
                albumDic[Key_Album_Id] = albumId;
                
                ////////相册封面
                NSString *albumCoverE = [self commandFor:kAlbumCoverInUserAlbumsExpression];
                NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:albumCoverE
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&err];
                NSUInteger start = result0.range.location+result0.range.length;
                NSArray *matches = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(start, [html length]-start-1)];
                if (matches.count > 0) {
                    NSTextCheckingResult *result = [matches objectAtIndex:0];
                    NSRange range = result.range;
                    
                    NSRange range2 = [html rangeOfString:@"\"/></a>" options:0 range:NSMakeRange(range.location, html.length-range.location-1)]; //
                    
                    NSString *albumCover = [html substringWithRange:NSMakeRange(range.location+range.length, range2.location-range.location-range.length)];
                    
                    ///私有相册 访问不到图片
                    if ([albumCover containString:@"otho.douban"]) {
                        NSArray *array = [albumCover componentsSeparatedByString:@"/"];
                        NSString *lastString = [array lastObject];
                        if ([lastString containString:@".jpg"]) {
                            albumCover = [NSString stringWithFormat:@"img3.douban.com/view/photo/albumcover/public/p%@", [lastString substringFromIndex:1]];
                        }
                    }
                    
                    albumDic[Key_Album_Cover] = albumCover;
                }
                
                ////////相册名字
                NSString *nameExpress = [NSString stringWithFormat:[self commandFor:kAlbumNameInUserAlbumsExpress], albumId];
                regex = [[NSRegularExpression alloc] initWithPattern:nameExpress
                                                             options:NSRegularExpressionCaseInsensitive
                                                               error:&err];
                start = result0.range.location+result0.range.length;
                matches = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(start, [html length]-start-1)];
                if (matches.count > 0) {
                    NSTextCheckingResult *result = [matches objectAtIndex:0];
                    
                    start = result.range.location+result.range.length;
                    NSRange endRange = [html rangeOfString:@"</a>" options:0 range:NSMakeRange(start, html.length-start-1)];
                    NSString *albumName = [html substringWithRange:NSMakeRange(start, endRange.location-start)];
                    albumDic[Key_Album_Name] = albumName;
                }
                
                [results addObject:albumDic];
            }
        }
    }
    
    SLLog(@"count %d \n%@ %@", [results count], @"albums", results);
}

@end


@implementation DAHtmlRobot (Cache)

+ (NSDictionary *)latestDoubanAlbumData{
    NSString *latestDataVersion = [USER_DEFAULT objectForKey:@"Key_Latest_Data_Version"];
    
    NSDictionary *dic = nil;
//#warning 
    if (latestDataVersion) {
        NSString *cacheFolderPath = [APP_CACHES_PATH stringByAppendingPathComponent:kDoubanAlbumDataPath];
        NSString *path = [NSString stringWithFormat:@"%@/%@.plist", cacheFolderPath, latestDataVersion];
        
        dic = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    if (!dic) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DoubanAlbumData_Local" ofType:@"plist"];
        dic = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    return dic;
}

+ (BOOL)cacheDoubanAlbumData:(NSDictionary *)result{
    NSString *newDataVersion = result[@"data_version"];
    NSString *latestDataVersion = [USER_DEFAULT objectForKey:@"Key_Latest_Data_Version"];
    if ([newDataVersion compare:latestDataVersion] != NSOrderedSame) {
        NSString *cacheFolderPath = [APP_CACHES_PATH stringByAppendingPathComponent:kDoubanAlbumDataPath];
        NSString *path = [NSString stringWithFormat:@"%@/%@.plist", cacheFolderPath, newDataVersion];
        [result writeToFile:path atomically:YES];
        
        [USER_DEFAULT setObject:newDataVersion forKey:@"Key_Latest_Data_Version"];
        [USER_DEFAULT synchronize];
        
        return YES;
    }
    
    return NO;
}

////用户相册列表
+ (void)cachedAlbumsForUser:(NSString *)userName start:(NSUInteger)start completion:(SLArrayBlock)completion{
    [self cachedDataWithAlbumId:0
                        userName:userName
                           start:start
                      completion:completion];
}

+ (void)cacheAlbums:(NSArray *)albums forUser:(NSString *)userName start:(NSUInteger)start{
    [self cacheData:albums forUser:userName forAlbum:0 start:start];
}

////相册图片
+ (void)cachedPhotosForAlbum:(NSUInteger)albumId start:(NSUInteger)start completion:(SLArrayBlock)completion{
    [self cachedDataWithAlbumId:albumId
                        userName:nil
                           start:start
                      completion:completion];
}

+ (void)cachePhotos:(NSArray *)photos forAlbum:(NSUInteger)albumId start:(NSUInteger)start{
    [self cacheData:photos forUser:nil forAlbum:albumId start:start];
}

+ (void)cachedDataWithAlbumId:(NSUInteger)albumId userName:(NSString *)userName start:(NSUInteger)start completion:(SLObjectBlock)completion{
    NSString *fomatter = nil;
    NSString *fileName = nil;
    NSUInteger countPerPage = 0;
    if (userName) { //用户相册列表
        fomatter = kUserAlbumPath;
        fileName = userName;
        countPerPage = [[self commandFor:kUserAlbumCountPerPage] integerValue];
    }else{ //相册图片
        fomatter = kPhotosInAlbumPath;
        fileName = [@(albumId) description];
        countPerPage = [[self commandFor:kPhotosInAlbumCountPerPage] integerValue];
    }
    
    __block NSMutableArray *results = nil;
    __block NSString *albumDescribe = nil;
    [GCDHelper dispatchBlock:^{
        NSString *photoListInAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:fomatter];
        NSString *path = [NSString stringWithFormat:@"%@/%@.plist", photoListInAlbumCachePath, fileName];
        
        NSMutableDictionary *orginDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        NSUInteger loop = MIN(countPerPage, orginDic.count);
        results = [NSMutableArray arrayWithCapacity:loop];
        
        SLLog(@"读取 %@ %@ start %d count %d", userName?@"userAlbum":[NSString stringWithFormat:@"album %d", albumId], userName?userName:[@(albumId) description], start, loop);
        
        int i;
        for (i = 0; i < loop; i++) {
            id photoId = [orginDic objectForKey:[@(i+start) description]];
            if (!photoId) return ;
            
            [results addObject:photoId];
        }
        
        if (albumId) {
            albumDescribe = [orginDic objectForKey:Key_Album_Describe];
        }
    } completion:^{
        if (albumId) {
            NSMutableDictionary *muDic = [@{@"photoIds":results} mutableCopy];
            if (albumDescribe.length > 0) {
                muDic[Key_Album_Describe] = albumDescribe;
            }
            completion(muDic);
        }else{
            completion(results);
        }
    }];
}

+ (void)cacheAlbumDescribe:(NSString *)des forAlbum:(NSUInteger)albumId{
    NSString *photoListInAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kPhotosInAlbumPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist", photoListInAlbumCachePath, [@(albumId) description]];
    
    NSMutableDictionary *orginDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [orginDic setObject:des forKey:Key_Album_Describe];
    
    [orginDic writeToFile:path atomically:YES];
}

+ (void)cacheData:(NSArray *)data forUser:(NSString *)userName forAlbum:(NSUInteger)albumId start:(NSUInteger)start{
    if (data.count == 0) return;
    
    NSString *fomatter = nil;
    NSString *fileName = nil;
    NSUInteger countPerPage = 0;
    if (userName) { //用户相册列表
        fomatter = kUserAlbumPath;
        fileName = userName;
        countPerPage = [[self commandFor:kUserAlbumCountPerPage] integerValue];
    }else{ //相册图片
#ifdef DEBUG
        NSAssert(albumId, @"albumId is 0");
#endif
        fomatter = kPhotosInAlbumPath;
        fileName = [@(albumId) description];
        countPerPage = [[self commandFor:kPhotosInAlbumCountPerPage] integerValue];
    }
    
    NSString *photoListInAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:fomatter];
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist", photoListInAlbumCachePath, fileName];
    
    NSMutableDictionary *newAddedDic = [NSMutableDictionary dictionaryWithCapacity:data.count];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        newAddedDic[[@(idx+start) description]] = obj;
    }];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
    {
        SLLog(@"创建 %@ %@ start %d count %d", userName?@"userAlbum":@"album", userName?userName:[@(albumId) description], start, newAddedDic.count);
        [newAddedDic writeToFile:path atomically:YES];
    }else{
        SLLog(@"更新 %@ %@ start %d count %d", userName?@"userAlbum":@"album", userName?userName:[@(albumId) description], start, newAddedDic.count);
        NSMutableDictionary *orginDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        [orginDic addEntriesFromDictionary:newAddedDic];
        
        [orginDic writeToFile:path atomically:YES];
    }
}

+ (void)emptyDisk{
    NSString *doubanAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kDoubanAlbumDataPath];
    [[NSFileManager defaultManager] removeItemAtPath:doubanAlbumCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:doubanAlbumCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    NSString *photoListInAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kPhotosInAlbumPath];
    
    [[NSFileManager defaultManager] removeItemAtPath:photoListInAlbumCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:photoListInAlbumCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    NSString *userAlbumsCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kUserAlbumPath];
    [[NSFileManager defaultManager] removeItemAtPath:userAlbumsCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:userAlbumsCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

+ (void)cleanOuttimeImageInDisk{
    [GCDHelper dispatchBlock:^{
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-CacheMaxCacheAge];
        
        NSString *photoListInAlbumCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kPhotosInAlbumPath];
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:photoListInAlbumCachePath];
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [photoListInAlbumCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
            {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        
        /////////
        NSString *userAlbumsCachePath = [APP_CACHES_PATH stringByAppendingPathComponent:kUserAlbumPath];
        fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:userAlbumsCachePath];
        for (NSString *fileName in fileEnumerator)
        {
            NSString *filePath = [userAlbumsCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
            {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }

    } completion:nil];
}

@end