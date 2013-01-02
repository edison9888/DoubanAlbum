//
//  DoubanAuthEngine.m
//  
//
//  Created by Tonny on 12-12-9.
//
//

#import "DoubanAuthEngine.h"
#import "SINGLETONGCD.h"
#import "DOUOAuthStore.h"
#import "DOUOAuthService.h"

@implementation DoubanAuthEngine

SINGLETON_GCD(DoubanAuthEngine)

- (id)init
{
    self = [super init];
    if (self) {
        _appClientId = kDouban_API_Key;
        _appClientSecret = kDouban_API_Secret;
    }
    return self;
}

#pragma mark - Helper

+ (NSUInteger)currentUserId{
    if ([[DoubanAuthEngine sharedDoubanAuthEngine] isValid]) {
        DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
        return store.userId;
    }
    return NSNotFound;
}


#pragma mark - OAuth

- (BOOL)isValid {
    DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
    if (store.accessToken) {
        BOOL isValid = ![store hasExpired];
        
        SLLog(@"Auth isValid %@", isValid?@"YES":@"NO");
        return isValid;
    }
    
    SLLog(@"Auth isValid NO");
    return NO;
}

+ (NSError *)executeRefreshToken {
    DOUOAuthService *service = [DOUOAuthService sharedInstance];
    service.authorizationURL = kTokenUrl;
    
    return [service validateRefresh];
}

//check if necessory refresh access token before each request,  sync
+ (void)checkRefreshToken{
    DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
    if (store.userId != 0 && store.refreshToken && [store shouldRefreshToken]) {
        [self executeRefreshToken];
    }
}

@end
