//
//  NSDataAddition.m
//  DoubanAlbum
//
//  modify from Three20 by Tonny on 6/5/11.
//  Copyright 2012 SlowsLab. All rights reserved.
//

#import "NSDataAddition.h"

typedef uint32_t CC_LONG;		/* 32 bit unsigned integer */

/*** MD5 ***/

#define CC_MD5_DIGEST_LENGTH	16			/* digest length in bytes */
#define CC_MD5_BLOCK_BYTES		64			/* block size in bytes */
#define CC_MD5_BLOCK_LONG       (CC_MD5_BLOCK_BYTES / sizeof(CC_LONG))

typedef struct CC_MD5state_st
{
	CC_LONG A,B,C,D;
	CC_LONG Nl,Nh;
	CC_LONG data[CC_MD5_BLOCK_LONG];
	int num;
} CC_MD5_CTX;

extern int CC_MD5_Init(CC_MD5_CTX *c);
extern int CC_MD5_Update(CC_MD5_CTX *c, const void *data, CC_LONG len);
extern int CC_MD5_Final(unsigned char *md, CC_MD5_CTX *c);
extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md);


@implementation NSData (Addition)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], [self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

@end
