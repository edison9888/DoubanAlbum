//
//  DoubanAuthEngine.h
//  
//
//  Created by Tonny on 12-12-9.
//
//

#import <Foundation/Foundation.h>

@interface DoubanAuthEngine : NSObject{    
    NSString        *_appClientId;
    NSString        *_appClientSecret;
}

+ (DoubanAuthEngine *)sharedDoubanAuthEngine;

+ (NSUInteger)currentUserId;

- (BOOL)isValid;

+ (void)checkRefreshToken;
@end
