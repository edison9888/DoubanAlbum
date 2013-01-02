//
//  DOUOAuthRequest.m
//  DOUAPIEngine
//
//  Created by Lin GUO on 11-10-31.
//  Copyright (c) 2011年 Douban Inc. All rights reserved.
//

#import "DOUOAuthService.h"
#import "DOUOAuth2.h"
#import "DOUOAUthStore.h"
#import "JSONKit.h"
#import "DAHttpClient.h"

@interface DOUOAuthService ()
@end


@implementation DOUOAuthService

@synthesize delegate = delegate_;

@synthesize clientId = clientId_;
@synthesize clientSecret = clientSecret_;
@synthesize authorizationURL = authorizationURL_;
@synthesize callbackURL = callbackURL_;
@synthesize authorizationCode = authorizationCode_;
@synthesize accessToken = accessToken_;
@synthesize refreshToken = refreshToken_;


static DOUOAuthService *myInstance = nil;

+ (DOUOAuthService *)sharedInstance {
  
  @synchronized(self) {
    if (myInstance == nil) {
      myInstance = [[DOUOAuthService alloc] init];
    }
    
  }
  return myInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (myInstance == nil) {
      myInstance = [super allocWithZone:zone];
      return myInstance;  // assignment and return on first allocation
    }
  }
  return nil; 
}


- (id)copyWithZone:(NSZone *)zone {
  return self;
}


- (id)retain {
  return self;
}


- (unsigned)retainCount {
  return UINT_MAX;
}


- (oneway void)release {
  //nothing
}


- (id)autorelease {
  return self;
}



- (void)dealloc {
  [clientId_ release];
  [clientSecret_ release];
  [accessToken_ release];
  [authorizationCode_ release];
  [callbackURL_ release];
  [authorizationURL_ release];
  [super dealloc];
}



#pragma mark - Auth2 actions

//- (ASIFormDataRequest *)formRequest {
//    
//    NSURL *URL = [NSURL URLWithString:authorizationURL_];
//    
//    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:URL] autorelease];
//    [request setHTTPMethod:@"POST"];
//    [request setTimeoutInterval:30];
//    [request setValue:@"Accept-Encoding" forKey:@"gzip"];
//  
//  [req setPostValue:kDouban_API_Key forKey:kClientIdKey];
//  [req setPostValue:kDouban_API_Secret forKey:kClientSecretKey];
//  [req setPostValue:kRedirectUrl forKey:kRedirectURIKey];
//
//  return req;
//}
//
//
- (void)validateAuthorizationCode {
    DAHttpClient *client = (DAHttpClient *)[DAHttpClient clientWithBaseURL:[NSURL URLWithString:@"https://www.douban.com"]];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST"
                         path:@"/service/auth2/token"
                   parameters:@{kGrantTypeKey:kGrantTypeAuthorizationCode,
                                    kOAuth2ResponseTypeCode:self.authorizationCode,
                                                kClientIdKey:kDouban_API_Key,
                                                kClientSecretKey:kDouban_API_Secret,
                                                kRedirectURIKey:kRedirectUrl}];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                   NSDictionary *dic = [response objectFromJSONString];
                                   
                                   id token = dic[kAccessTokenKey];
                                   
                                   if (token) {
                                       DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
                                       [store updateWithSuccessDictionary:dic];
                                       
                                       if ([delegate_ respondsToSelector:@selector(OAuthClient:didAcquireSuccessDictionary:)]) {
                                           [delegate_ OAuthClient:self didAcquireSuccessDictionary:dic];
                                       }            
                                   }
                               }else{
                                   if ([delegate_ respondsToSelector:@selector(OAuthClient:didFailWithError:)]) {
                                       [delegate_ OAuthClient:self didFailWithError:error];
                                   }
                               }
                           }];
}


//- (void)validateUsername:(NSString *)username password:(NSString *)password {  
//  ASIFormDataRequest *req = [self formRequest];
//  [req setDelegate:self];
//
//  [req setPostValue:kGrantTypePassword forKey:kGrantTypeKey];  
//  [req setPostValue:username forKey:kUsernameKey];
//  [req setPostValue:password forKey:kPasswordKey];
//
//  [req startAsynchronous];
//}
//
//
- (NSError *)validateRefresh {
    if (!self.refreshToken) return nil;
    
    DAHttpClient *client = (DAHttpClient *)[DAHttpClient clientWithBaseURL:[NSURL URLWithString:@"https://www.douban.com"]];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST"
                                                        path:@"/service/auth2/token"
                                                  parameters:@{kGrantTypeKey:kGrantTypeRefreshToken,
                                     kOAuth2ResponseTypeToken:self.refreshToken,
                                                kClientIdKey:kDouban_API_Key,
                                            kClientSecretKey:kDouban_API_Secret,
                                             kRedirectURIKey:kRedirectUrl}];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    if (!error) {
        NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary *dic = [response objectFromJSONString];
        
        id token = dic[kAccessTokenKey];
        
        if (token) {
            DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
            [store updateWithSuccessDictionary:dic];
            
            [[DAHttpClient sharedDAHttpClient] setDefaultHeader:kAccessTokenKey value:token];
        }
    }
    
    return error;
}

//
//
//- (void)requestFailed:(ASIHTTPRequest *)req {
//  NSError *error = nil;
//  
//  NSError *asiError = [req error];
//  // handle the http error
//  if (asiError) {
//     error = [DOUHttpRequest adapterError:asiError];
//  }
//
//  // handle the oauth error
//  int statusCode = [req responseStatusCode];
//  if (statusCode >= 400 && statusCode <= 403) {
//    NSString *response = [req responseString];
//    NSDictionary *dic = [response JSONValue];  
//    if (dic) {
//      NSInteger code = [[dic objectForKey:@"code"] integerValue];
//      error = [NSError errorWithDomain:DOUOAuthErrorDomain
//                                  code:code 
//                              userInfo:dic];
//    }
//  }
//
//  if ([delegate_ respondsToSelector:@selector(OAuthClient:didFailWithError:)]) {
//    [delegate_ OAuthClient:self didFailWithError:error];
//  }

//}
//
//
//- (void)requestFinished:(ASIHTTPRequest *)req {
//  NSError *error = nil;
//
//  NSError *asiError = [req error];
//  if (asiError) {
//    error = [DOUHttpRequest adapterError:asiError];
//  }
//  
//  // handle the oauth error
//  int statusCode = [req responseStatusCode];
//  if (statusCode >= 400 && statusCode <= 403) {
//    NSString *response = [req responseString];
//    NSDictionary *dic = [response JSONValue];  
//    if (dic) {
//      NSInteger code = [[dic objectForKey:@"code"] integerValue];
//      error = [NSError errorWithDomain:DOUOAuthErrorDomain
//                                  code:code 
//                              userInfo:dic];
//    }
//  }
//  
//  // Error
//  if (error) {
//    if ([delegate_ respondsToSelector:@selector(OAuthClient:didFailWithError:)]) {
//      [delegate_ OAuthClient:self didFailWithError:error];
//      return ;
//    }
//  }
//
//  // Success
//  NSString *response = [req responseString];
//  NSDictionary *dic = [response JSONValue];
//  DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
//  [store updateWithSuccessDictionary:dic];
//  
//  if ([delegate_ respondsToSelector:@selector(OAuthClient:didAcquireSuccessDictionary:)]) {
//    [delegate_ OAuthClient:self didAcquireSuccessDictionary:dic];
//  }
//}
//
//
//
//
//#if NS_BLOCKS_AVAILABLE
//
//- (void)validateUsername:(NSString *)username
//                password:(NSString *)password 
//                callback:(DOUBasicBlock)block {
//  ASIFormDataRequest *req = [self formRequest];
//  
//  [req setDelegate:self];
//
//  [req setPostValue:@"password" forKey:kGrantTypeKey];
//  [req setPostValue:username forKey:kUsernameKey];
//  [req setPostValue:password forKey:kPasswordKey];
//  [req setCompletionBlock:block];
//  [req setFailedBlock:block];
//  
//  [req startAsynchronous];
//}
//
//
//- (void)validateAuthorizationCodeWithCallback:(DOUBasicBlock)block {
//  ASIFormDataRequest *req = [self formRequest];
//  [req setDelegate:self];
//  [req setPostValue:@"authorization_code" forKey:kGrantTypeKey]; 
//  [req setPostValue:self.authorizationCode forKey:kOAuth2ResponseTypeCode];
//
//  [req setCompletionBlock:block];
//  [req setFailedBlock:block];
//  
//  [req startAsynchronous];
//}


//#endif



- (void)logout {
  DOUOAuthStore *store = [DOUOAuthStore sharedInstance];
  [store clear];
}

@end
