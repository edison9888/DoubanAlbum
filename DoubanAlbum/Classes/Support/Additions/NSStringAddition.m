//
//  NSStringAddition.m
//  DoubanAlbum
//
//  modify from Three20 by Tonny on 6/5/11.
//  Copyright 2012 SlowsLab. All rights reserved.
//

//#import <CoreLocation/CLGeocoder.h>
//#import <CoreLocation/CLPlacemark.h>
//#import <AddressBook/AddressBook.h>
//#import <MapKit/MapKit.h>

#import "NSStringAddition.h"
#import "NSDataAddition.h"

@implementation NSString (Addition)
//////////////////////////////////////////////////////////////////////

- (NSComparisonResult)versionStringCompare:(NSString *)other {
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [other componentsSeparatedByString:@"a"];
    
    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];
    
    // If main parts are different, return that result, regardless of alpha part
    NSComparisonResult mainDiff;
    if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
        return mainDiff;
    }
    
    // At this point the main parts are the same; just deal with alpha stuff
    // If one has an alpha part and the other doesn't, the one without is newer
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;
        
    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;
        
    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }
    
    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespaceAndNewlines {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEmptyOrWhitespace {
    return self == nil || !([self length] > 0) || [[self trimmedWhitespaceString] length] == 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) isEmail{
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

- (BOOL)isLegalPrice{
    if([self isEmptyOrWhitespace]){
        return NO;
    }
    
    NSString *integerOrFloatPointRegEx = @"0|[1-9]+[0-9]*|(0|[1-9]+[0-9]*).[0-9]*[1-9]+$";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", integerOrFloatPointRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

-(BOOL)isNumber{
    if([self isEmptyOrWhitespace]){
        return NO;
    }
    
    NSString *integerOrFloatPointRegEx = @"[0-9]+$";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", integerOrFloatPointRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

-(BOOL)isLegalName{
    if([self isEmptyOrWhitespace]){
        return NO;
    }
    
    NSString *integerOrFloatPointRegEx = @"^\\w+$";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", integerOrFloatPointRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

/////////////////////////////////////////////////////////////////////////// unicodeEncode
- (NSString*)unicodeEncode{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSInteger length = [self length];
    unichar *buffer = calloc( [self length ], sizeof( unichar ) );
    [self getCharacters:buffer];
    
    for (NSInteger i = 0; i < length; i++){
        unichar ch = buffer[i];
        
        if ((ch & 0xff80) == 0){
            if ([self isCharSafe:ch] == YES){
                [result appendFormat:@"%c", ch];
            } else if (ch == ' '){
                [result appendString:@"+"];
            } else{
                [result appendString:@"%"];
                [result appendFormat:@"%c", [self intToHex:((ch >> 4) & '\x000f')]];
                [result appendFormat:@"%c", [self intToHex:(ch & '\x000f')]];
            }
        }	else{
            [result appendString:@"%u"];
            [result appendFormat:@"%c", [self intToHex:((ch >> 12) & '\x000f')]];
            [result appendFormat:@"%c", [self intToHex:((ch >> 8) & '\x000f')]];
            [result appendFormat:@"%c", [self intToHex:((ch >> 4) & '\x000f')]];
            [result appendFormat:@"%c", [self intToHex:(ch & '\x000f')]];
        }
    }
    free(buffer);
    if (result) {
        return result;
    }
    return @"";
}

-(unichar) intToHex:(int)n{
    if (n <= 9){
        return (unichar)(n + 0x30);
    }
    return (unichar)((n - 10) + 0x61);
}

-(BOOL) isCharSafe:(unichar)ch{
    if (((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) || ((ch >= '0') && (ch <= '9')))	{
        return YES;
    }
    switch (ch){
        case '\'':
        case '(':
        case ')':
        case '*':
        case '-':
        case '.':
        case '_':
        case '!':
            return YES;
    }
    return NO;
}

- (BOOL)isOnlyContainNumberOrLatter{
    for (NSInteger i = 0; i < self.length; i++) {
        unichar ch = [self characterAtIndex:i];
        if (!(((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) || ((ch >= '0') && (ch <= '9')))){ //0=48
            return NO;
        }
    }
    return YES;
}

-(BOOL)containString:(NSString *)string{
    return [self rangeOfString:string].location != NSNotFound;
}

-(NSString *)removeSpace{
    if(![self containString:@" "]){
        return self;
    }
    
    NSMutableString *mString = [NSMutableString stringWithString:self];
    [mString replaceCharactersInRange:[self rangeOfString:@" "] withString:@""];
    
    NSString *string = [mString removeSpace];
    
    return string;
}

- (NSString *)replaceSpaceWithUnderline{
    if(![self containString:@" "]){
        return self;
    }
    
    NSMutableString *mString = [NSMutableString stringWithString:self];
    [mString replaceCharactersInRange:[self rangeOfString:@" "] withString:@"_"];
    
    NSString *string = [mString replaceSpaceWithUnderline];
    
    return string;
}

- (NSString *)replaceDotWithUnderline{
    if(![self containString:@"."]){
        return self;
    }
    
    NSMutableString *mString = [NSMutableString stringWithString:self];
    [mString replaceCharactersInRange:[self rangeOfString:@"."] withString:@"_"];
    
    NSString *string = [mString replaceDotWithUnderline];
    
    return string;
}

- (NSString *)encodeString{
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                    (__bridge CFStringRef)self,
                                                                    NULL,
                                                                    (CFStringRef)@";/?:@&=$+{}<>,",
                                                                    kCFStringEncodingUTF8);
    NSString *result = [NSString stringWithString:(__bridge NSString *)stringRef];
    CFRelease(stringRef);
    
    return result;
}

-(NSString *)trimmedWhitespaceString{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(NSString *)trimmedWhitespaceAndNewlineString{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDate*)date{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *date = [formatter dateFromString:self];
	return date;
}

- (NSDate*)dateWithFormate:(NSString*) formate {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:formate];
	NSDate *date = [formatter dateFromString:self];
	return date;
}

+(NSDate *)dateFromString:(NSString *)string{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:string];

    return date;
}

- (NSDictionary *)parseURLParams{
	NSArray *pairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:[pairs count]];
	for(NSString *aPair in pairs){
		NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
		if([keyAndValue count] != 2) continue;
        [muDic setObject:[keyAndValue objectAtIndex:1] forKey:[keyAndValue objectAtIndex:0]];
	}
    
	return muDic;
}

- (NSString *)getValueStringFromUrlForParam:(NSString *)param {
    NSUInteger location = [self rangeOfString:@"?"].location;
    NSString *params = nil;
    if (location != NSNotFound) {
        params = [self substringFromIndex:location+1];
    }else{
        params = self;
    }
    
    NSDictionary *dic = [params parseURLParams];
    return dic[param];
}


@end