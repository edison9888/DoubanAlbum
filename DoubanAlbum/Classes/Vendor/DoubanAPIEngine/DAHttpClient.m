//
//  DAHttpClient.m
//  DoubanAlbum
//
//  Created by Tonny on 12-12-9.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "DAHttpClient.h"
#import "DoubanAuthEngine.h"
#import "AFJSONRequestOperation.h"
#import "SINGLETONGCD.h"
#import "DOUOAuthStore.h"
#import "DOUOAuth2.h"
#import "JSONKit.h"
#import "DAHtmlRobot.h"
#import "DoubanAuthEngine.h"
#import "DALoginViewController.h"
#import "NSStringAddition.h"
#import "GCDHelper.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "BundleHelper.h"

///user
NSString * const kDoubanMeProfileURLString = @"/v2/user/~me";
NSString * const kDoubanUserProfileURLString = @"/v2/user/%@";//id or uid

//////album need login
///album basic
NSString * const kDoubanAlbumInfoURLString = @"/v2/album/%d/";//album id
NSString * const kDoubanPhotosInAlbumURLString = @"/v2/album/%d/photos?start=%d&count=%d&order=asc"; //album id
//BUG
//there is a bug in Douban api, order=asc does not work

NSString * const kDoubanPhotoURLString = @"/v2/photo/%d"; //photo id

///album advanced
NSString * const kDoubanUserAlbumsURLString = @"/v2/album/user_created/%d"; //user id

///user notes
NSString * const kDoubanCreateNotesURLString = @"/v2/notes";
NSString * const kDoubanDeleteOrUpdateNotesURLString = @"/v2/note/%d"; //DELETE PUT

NSString * const kDoubanUserNotesListURLString = @"/v2/note/user_created/%d?format=abstract";

NSString * const kDoubanShuoURLString = @"/shuo/v2/statuses/";

@implementation DAHttpClient

SINGLETON_GCD(DAHttpClient);

- (id)init {
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        self = [super initWithBaseURL:[NSURL URLWithString:kHttpsApiBaseUrl]]; //需要授权的api
    }else {
        self = [super initWithBaseURL:[NSURL URLWithString:kHttpApiBaseUrl]];
    }
    
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        //set HTTP Header
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        if (isValid) {
            id accessToken = [[DOUOAuthStore sharedInstance] accessToken];
            [self setDefaultHeader:kAccessTokenKey value:accessToken];
        }
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

+ (void)incrementActivityCount{
    [DAHttpClient sharedDAHttpClient];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

+ (void)decrementActivityCount{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSParameterAssert(method);
    
    if (!path) {
        path = @"";
    }
    
    NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:self.baseURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:[self valueForKey:@"_defaultHeaders"]];
	
    /////----Tonny add
    if ([method isEqualToString:@"GET"]) {
        if (!parameters) {
            parameters = @{@"apikey":kDouban_API_Key};
        }else{
            NSMutableDictionary *newPara = [NSMutableDictionary dictionaryWithDictionary:parameters];
            newPara[@"apikey"] = kDouban_API_Key;
            
            parameters = nil;
            parameters = newPara;
        }
    }
    /////----end
    
    SLog(@"--<url>: %@", url);
    SLog(@"--param: %@\n", parameters.count>0?[parameters JSONString]:@"无");
    
    if (parameters) {
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            NSError *error = nil;
            
            switch (self.parameterEncoding) {
                case AFFormURLParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) dataUsingEncoding:self.stringEncoding]];
                    break;
                case AFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
                    break;
                case AFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    break;
            }
            
            if (error) {
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
    }
    
	return request;
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        imageDic:(NSDictionary *)imageDic
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = nil;
    if (imageDic) {
        NSString *key = [[imageDic allKeys] lastObject];
        UIImage *image = [[imageDic allValues] lastObject];
        NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.7) name:key fileName:key mimeType:@"image/jpeg"];
        }];
        
        operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
        
        [self enqueueHTTPRequestOperation:operation];
    }else{
        [[DAHttpClient sharedDAHttpClient] postPath:path parameters:parameters success:success failure:failure];
    }
}

+ (void)myProfileWithSuccess:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    [DoubanAuthEngine checkRefreshToken];
    
    [[DAHttpClient sharedDAHttpClient] getPath:kDoubanMeProfileURLString parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        SLLog(@"result %@", JSON);
        
        NSInteger r = [[JSON valueForKeyPath:@"id"] intValue];
        if(JSON && r != 0){
            success(JSON);
        }else{
            error(r);
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

+ (void)userProfileWithId:(NSString *)userId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    [DoubanAuthEngine checkRefreshToken];
    
    NSString *path = [NSString stringWithFormat:kDoubanUserProfileURLString, userId];
    [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        SLLog(@"result %@", JSON);
        NSInteger r = [[JSON valueForKeyPath:@"id"] intValue];
        if(JSON && r != 0){
            success(JSON);
        }else{
            error(r);
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

+ (void)albumInfoWithId:(NSUInteger)albumId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        NSString *path = [NSString stringWithFormat:kDoubanAlbumInfoURLString, albumId];
        
        [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            SLLog(@"result %@", JSON);
            
            NSInteger r = [[JSON valueForKeyPath:@"id"] intValue];
            if(JSON && r != 0){
                success(JSON);
            }else{
                error(r);
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }else{
        
    }
}

+ (void)photosInAlbumWithId:(NSUInteger)albumId start:(NSUInteger)start success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        //TODO api与抓网页的结果 顺序 是反的
        [DAHtmlRobot cachedDataWithAlbumId:albumId
                           userName:nil
                              start:start
                         completion:^(id dic) {
                             NSArray *array = dic[@"photoIds"];
                             if (array.count == [[DAHtmlRobot commandFor:kPhotosInAlbumCountPerPage] integerValue]) {
                                 success(dic);
                             }else{
                                NSString *path = [NSString stringWithFormat:kDoubanPhotosInAlbumURLString, albumId, start, [[DAHtmlRobot commandFor:kPhotosInAlbumCountPerPage] integerValue]];
                                
                                [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
                                    SLLog(@"result %@", JSON);
                                    
                                    if(JSON){
                                        NSArray *pictureIds = [JSON valueForKeyPath:@"photos.id"];
                                        NSString *des = [JSON valueForKeyPath:@"album.desc"];
                                        
                                        SLLog(@"des %@", des);
                                        [DAHtmlRobot cacheData:pictureIds forUser:nil forAlbum:albumId start:start];
                                        
                                        NSMutableDictionary *result = [@{@"photoIds":pictureIds} mutableCopy];
                                        if (des.length > 0) {
                                            result[Key_Album_Describe] = des;
                                            
                                            [DAHtmlRobot cacheAlbumDescribe:des forAlbum:albumId];
                                        }
                                        
                                        success(result);
                                    }else{
                                        error(0);
                                    }
                                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                                    //TODO 1001 not found
                                    failure(error);
                                }];
                             }
                         }];
    }else{
        [DoubanAuthEngine checkRefreshToken];
        
        [DAHtmlRobot photosInAlbum:albumId
                             start:start
                        completion:^(NSDictionary *dic) {
                            success(dic);
                        }];
    }
}

+ (void)photoWithId:(NSUInteger)photoId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        [DoubanAuthEngine checkRefreshToken];
        
        NSString *path = [NSString stringWithFormat:kDoubanPhotoURLString, photoId];
        
        [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            SLLog(@"result %@", JSON);
            
            if(JSON){
                success(JSON);
            }else{
                error(0);
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }else{
        
    }
}

///album advanced
+ (void)userAlbumsWithUserName:(NSString *)userName start:(NSUInteger)start success:(SLArrayBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    
    [DAHtmlRobot userAlbumsWithUserName:userName
                         start:start
                    completion:^(NSArray *array) {
                        success(array);
                    }];
    /// 高级api
//    [[DoubanAuthEngine sharedDoubanAuthEngine] checkRefreshToken];
//    
//    NSString *path = [NSString stringWithFormat:kDoubanUserAlbumsURLString, userId];
//    
//    [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
//        SLLog(@"result %@", JSON);
//        
//        if(JSON){
//            success(JSON);
//        }else{
//            error(0);
//        }
//    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
//        failure(error);
//    }];
}

////user notes

+ (void)likeAlbumWithAlbumDic:(NSDictionary *)albumDic like:(BOOL)like success:(SLIndexBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc{
    
    [self contentForCollentedAlbumNoteWithAlubmInfo:albumDic like:like viewController:vc completion:^(NSString *content){
        NSDictionary *para = @{@"title":Key_Douban_Collected_Albums_Note_Name, @"privacy":@"private", @"can_reply":@"false", @"content":content};
        
        SLIndexBlock successBlock = ^(NSInteger index){
            if (like) {
                [DADataEnvironment addCollectAlbum:albumDic];
            }else{
                [DADataEnvironment removeCollectAlbum:albumDic];
            }
            
            success(index);
        };
        
        [self createOrUpdateNoteWithParameters:para update:YES success:successBlock error:error failure:failure viewController:vc];
    }];
}

+ (NSString *)contentForCollentedAlbumNoteWithAlubmInfo:(NSDictionary *)albumDic like:(BOOL)like{
    NSMutableArray *albums = [[DADataEnvironment sharedDADataEnvironment].collectedAlbums mutableCopy];
    
    if (!like) {
        id albumId = albumDic[Key_Album_Id];
        
        NSArray *albumIds = [[DADataEnvironment sharedDADataEnvironment].collectedAlbums valueForKeyPath:Key_Album_Id];
        NSUInteger index = [albumIds indexOfObject:[albumId description]];
        if (index != NSNotFound) {
            [albums removeObjectAtIndex:index]; //KVO
        }
    }else{
        [albums addObject:albumDic]; ////KVO
    }
    
    NSString *start = @"---start---";
    NSString *end = @"---end---";
    
    NSMutableString *muString = [NSMutableString stringWithString:start];
    
    NSString *json = [@{@"albums":albums, @"data_version":[BundleHelper bundleFullVersionString]} JSONString];
    if (json) {
        [muString appendString:json];
        
        NSRange range = [muString rangeOfString:@"http://"];
        while (range.location != NSNotFound) {
            [muString replaceCharactersInRange:range withString:@""];
            range = [muString rangeOfString:@"http://"];
        }
    }
    [muString appendString:end];
    
    [muString appendString:@"\n\n---------------------------------------------------\n此日记是iOS应用 (豆瓣相册 精选集) 自动创建的日记，帮助纪录下您收藏的精选集，凌乱的格式暂时有点抱歉，您可以忽略该日记，也可以考虑删除它。不过我们时刻都在寻找比这更高级的方法。"];
    
    return muString;
}

+ (void)contentForCollentedAlbumNoteWithAlubmInfo:(NSDictionary *)albumDic like:(BOOL)like viewController:(UIViewController *)vc completion:(SLObjectBlock)completion{
    
    SLBlock loadCollectedAlbumsBlock = ^{
        NSString *key = [self collectedAlbumsNoteKeyForCurrentUser];
        NSUInteger noteId = [USER_DEFAULT integerForKey:key];
        
        if (!noteId) {
            //check AlbumCollectedNote exist in douban
            [self collectedAlbumsNoteId:^(NSString *noteIdT) {
                if (noteIdT) {
                    SLLog(@"找到 noteId %@", noteIdT);
                    NSString *key = [self collectedAlbumsNoteKeyForCurrentUser];
                    [USER_DEFAULT setObject:noteIdT forKey:key];
                    [USER_DEFAULT synchronize];
                    
                    [self collectedAlbumsWithSuccess:^(NSArray *array) {
                        [DADataEnvironment sharedDADataEnvironment].collectedAlbums = [array mutableCopy];
                        
                        NSString *content = [self contentForCollentedAlbumNoteWithAlubmInfo:albumDic like:like];
                        completion(content);
                    } error:^(NSInteger index) {
                        completion(nil);
                    } failure:^(NSError *error) {
                        completion(nil);
                    }];
                }else{
                    SLLog(@"没找到 noteId");
                    
                    NSString *content = [self contentForCollentedAlbumNoteWithAlubmInfo:albumDic like:like];
                    completion(content);
                }
            }];
        }else{
            [self collectedAlbumsWithSuccess:^(NSArray *array) {
                SLLog(@"更新 collectedAlbums");
                
                [DADataEnvironment sharedDADataEnvironment].collectedAlbums = [array mutableCopy];
                
                NSString *content = [self contentForCollentedAlbumNoteWithAlubmInfo:albumDic like:like];
                completion(content);
            } error:^(NSInteger index) {
                completion(nil);
            } failure:^(NSError *error) {
                completion(nil);
            }];
        }
    };
    
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        loadCollectedAlbumsBlock();
    }else{
        [DoubanAuthEngine checkRefreshToken];
        
        BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
        if (isValid) {
            loadCollectedAlbumsBlock();
        }else{
            DALoginViewController *loginVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"DALoginViewController"];
            loginVC.finishedBlock = ^(id vc, id obj){
                if ([obj boolValue]) {
                    SLLog(@"授权成功");
                    
                    loadCollectedAlbumsBlock();
                }
            };
            
            UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            UIImage *nvImg = [UIImage imageNamed:@"bg_nav.png"];
            [nVC.navigationBar setBackgroundImage:nvImg forBarMetrics:UIBarMetricsDefault];
            
            [vc presentViewController:nVC animated:YES completion:nil];
        }
    }
}

+ (NSString *)collectedAlbumsNoteKeyForCurrentUser{
    static NSString *formater = @"kAlbumCollectedNoteId_ForUser_%d";
    
    int userId = [[DOUOAuthStore sharedInstance] userId];
    NSString *key = [NSString stringWithFormat:formater, userId];
    return key;
}

+ (void)createOrUpdateNoteWithParameters:(NSDictionary *)para update:(BOOL)update success:(SLIndexBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc{
    if (update) {
        NSString *key = [self collectedAlbumsNoteKeyForCurrentUser];
        NSUInteger noteId = [USER_DEFAULT integerForKey:key];
        
        NSString *path = [NSString stringWithFormat:kDoubanDeleteOrUpdateNotesURLString, noteId];
        
        [[DAHttpClient sharedDAHttpClient] putPath:path parameters:para success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            
            if(JSON){//202
                NSUInteger noteId = [[JSON valueForKey:@"id"] integerValue];
                if (noteId) {
                    SLLog(@"更新日记成功 %d", noteId);
                    success(2);
                }
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *err) {
            NSString *suggestion = [[err userInfo] objectForKey:@"NSLocalizedRecoverySuggestion"];
            if ([suggestion containString:@"1006"]) {
                //用 更新出错 机制实现 创建日记
                [self createOrUpdateNoteWithParameters:para update:NO success:success error:error failure:failure viewController:vc];
            }else{
                if (err.code == 3840) { //JSON error
                    //BUG
                    //there is a bug in Douban api, it's failure but actully success when update note
                    SLLog(@"更新日记成功 %d", noteId);
                    success(2);
                }
            }
        }];
    }else{
        [[DAHttpClient sharedDAHttpClient] postPath:kDoubanCreateNotesURLString parameters:para success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            //                SLLog(@"result %@", JSON);
            if(JSON){
                id noteId = [JSON valueForKey:@"id"];
                if (noteId) {
                    SLLog(@"创建日记成功 %@", noteId);
                    
                    NSString *key = [self collectedAlbumsNoteKeyForCurrentUser];
                    
                    [USER_DEFAULT setObject:noteId forKey:key];
                    [USER_DEFAULT synchronize];
                    
                    success(1);
                }
            }else{
                error(0);
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}

+ (void)deleteNoteWithNoteId:(NSUInteger)noteId success:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc{
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        NSString *path = [NSString stringWithFormat:kDoubanDeleteOrUpdateNotesURLString, noteId];
        [[DAHttpClient sharedDAHttpClient] deletePath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            SLLog(@"result %@", JSON);
            
            if(JSON){
                success(JSON);
            }else{
                error(0);
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }else{
        [DoubanAuthEngine checkRefreshToken];
        BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
        if (isValid) {
            [self deleteNoteWithNoteId:noteId success:success error:error failure:failure viewController:vc];
        }else{
            DALoginViewController *loginVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"DALoginViewController"];
            loginVC.finishedBlock = ^(id vc, id obj){
                if ([obj boolValue]) {
                    [self deleteNoteWithNoteId:noteId success:success error:error failure:failure viewController:vc];
                }
            };
            
            UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            UIImage *nvImg = [UIImage imageNamed:@"bg_nav.png"];
            [nVC.navigationBar setBackgroundImage:nvImg forBarMetrics:UIBarMetricsDefault];
            
            [vc presentViewController:nVC animated:YES completion:nil];
        }
    }
}

+ (void)collectedAlbumsNoteId:(SLObjectBlock)notiBlock{
    [self notesListWithSuccess:^(NSDictionary *dic) {
        NSArray *titles = [dic valueForKeyPath:@"notes.title"];
        
        NSUInteger index = [titles indexOfObject:Key_Douban_Collected_Albums_Note_Name];
        if (index != NSNotFound) {
            NSDictionary *note = [dic objectForKey:@"notes"][index];
            notiBlock(note[@"id"]);
        }else{
            notiBlock(nil);
        }
    } error:^(NSInteger index) {
        notiBlock(nil);
    } failure:^(NSError *error) {
        notiBlock(nil);
    }];
}

+ (void)notesListWithSuccess:(SLDictionaryBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    int userId = [[DOUOAuthStore sharedInstance] userId];
    NSString *path = [NSString stringWithFormat:kDoubanUserNotesListURLString, userId];
    [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        SLLog(@"result %@", JSON);
        
        if(JSON){
            success(JSON);
        }else{
            error(0);
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

+ (void)collectedAlbumsWithSuccess:(SLArrayBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure{
    
    NSString *key = [self collectedAlbumsNoteKeyForCurrentUser];
    NSUInteger noteId = [USER_DEFAULT integerForKey:key];
    if (noteId) {
        NSString *path = [NSString stringWithFormat:kDoubanDeleteOrUpdateNotesURLString, noteId];
        path = [NSString stringWithFormat:@"%@?format=html_full", path];
        [[DAHttpClient sharedDAHttpClient] getPath:path parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
            SLLog(@"JSON %@", JSON);
            
            if(JSON){
                NSString *content = [JSON objectForKey:@"content"];
                if (content) {
                    NSRange startR = [content rangeOfString:@"---start---"];
                    NSRange endR = [content rangeOfString:@"---end---"];
                    
                    if (startR.location != NSNotFound && endR.location != NSNotFound) {
                        __block NSDictionary *collectedAlbums = nil;
                        [GCDHelper dispatchBlock:^{
                            NSUInteger start = startR.location+startR.length;
                            NSString *targetString = [content substringWithRange:NSMakeRange(start, endR.location-start)];
                            
                            NSMutableString *muString = [NSMutableString stringWithString:targetString];
                            NSRange range = [muString rangeOfString:@"&quot;"];
                            while (range.location != NSNotFound) {
                                [muString replaceCharactersInRange:range withString:@"\""];
                                range = [muString rangeOfString:@"&quot;"];
                            }
                            
                            collectedAlbums = [muString objectFromJSONString];
                            SLLog(@"获取我的收藏 %@", collectedAlbums);
                        } completion:^{
                            success(collectedAlbums[@"albums"]);
                        }];
                    }else{
                        error(0);
                    }
                }else{
                    error(0);
                }
            }else{
                error(0);
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }else{
        [DoubanAuthEngine checkRefreshToken];
        
        [self collectedAlbumsNoteId:^(NSString *noteId) {
            if (noteId) {
                NSString *key = [self collectedAlbumsNoteKeyForCurrentUser];
                [USER_DEFAULT setObject:noteId forKey:key];
                [USER_DEFAULT synchronize];
                
                [self collectedAlbumsWithSuccess:success error:error failure:failure];                    
            }else{
                success(nil);
            }
        }];
    }
}

+ (void)doubanShuoWithParameters:(NSDictionary *)para success:(SLBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure viewController:(UIViewController *)vc{
    BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
    if (isValid) {
        NSMutableDictionary *muDic = [para mutableCopy];
        muDic[@"apikey"] = kDouban_API_Key;
        
        UIImage *image = para[@"image"];
        if (image) {
            [muDic removeObjectForKey:@"image"];
        }
        
        [[DAHttpClient sharedDAHttpClient] postPath:kDoubanShuoURLString parameters:muDic imageDic:image?@{@"image":image}:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            SLLog(@"JSON %@", JSON);
            
            if(JSON){
                id shouId = [JSON valueForKey:@"id"];
                if (shouId) {
                    success();
                    return ;
                }
            }
            
            error(0);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }else{
        [DoubanAuthEngine checkRefreshToken];
        BOOL isValid = [[DoubanAuthEngine sharedDoubanAuthEngine] isValid];
        if (isValid) {
            [self doubanShuoWithParameters:para
                                   success:success
                                     error:error
                                   failure:failure
                            viewController:vc];
        }else{
            DALoginViewController *loginVC = [vc.storyboard instantiateViewControllerWithIdentifier:@"DALoginViewController"];
            loginVC.finishedBlock = ^(UIViewController *vc, id obj){
                if ([obj boolValue]) {
                    [self doubanShuoWithParameters:para
                                           success:success
                                             error:error
                                           failure:failure
                                    viewController:vc];
                }else{
                    error(100);
                }
                [vc dismissViewControllerAnimated:NO completion:nil];
            };
            
            UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            UIImage *nvImg = [UIImage imageNamed:@"bg_nav.png"];
            [nVC.navigationBar setBackgroundImage:nvImg forBarMetrics:UIBarMetricsDefault];
            
            [vc presentViewController:nVC animated:YES completion:nil];
        }
    }
}


@end
