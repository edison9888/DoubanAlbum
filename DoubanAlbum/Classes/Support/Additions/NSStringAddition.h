//
//  NSStrinAddition.h
//  DoubanAlbum
//
//  modify from Three20 by Tonny on 6/5/11.
//  Copyright 2012 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreLocation/CLLocation.h>

@interface NSString (Addition)

@property (nonatomic, readonly) NSString* md5Hash;

- (NSComparisonResult)versionStringCompare:(NSString *)other;

- (BOOL)isWhitespaceAndNewlines;

- (BOOL)isEmptyOrWhitespace;

- (BOOL)isEmail;

- (BOOL)isLegalPrice;

- (BOOL)isNumber;

-(BOOL)isLegalName;

- (BOOL)isOnlyContainNumberOrLatter;

-(unichar) intToHex:(int)n;

-(BOOL) isCharSafe:(unichar)ch;

-(BOOL)containString:(NSString *)string;

-(NSString *)removeSpace;

-(NSString *)replaceSpaceWithUnderline;

- (NSString *)replaceDotWithUnderline;

- (NSString *)encodeString;

-(NSString *)trimmedWhitespaceString;

-(NSString *)trimmedWhitespaceAndNewlineString;

// date
+(NSDate *)dateFromString:(NSString *)string;

- (NSDictionary *)parseURLParams;

- (NSString *)getValueStringFromUrlForParam:(NSString *)param;

- (NSDate *)date;


@end
