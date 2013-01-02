//
//  blocktypedef.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-9.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#ifndef DoubanAlbum_blocktypedef_h
#define DoubanAlbum_blocktypedef_h

typedef void(^SLBlock)(void);
typedef void(^SLBlockBlock)(SLBlock block);
typedef void(^SLObjectBlock)(id obj);
typedef void(^SLArrayBlock)(NSArray *array);
typedef void(^SLMutableArrayBlock)(NSMutableArray *array);
typedef void(^SLDictionaryBlock)(NSDictionary *dic);
typedef void(^SLErrorBlock)(NSError *error);
typedef void(^SLIndexBlock)(NSInteger index);
typedef void(^SLFloatBlock)(CGFloat afloat);

typedef void(^SLCancelBlock)(id viewController);
typedef void(^SLFinishedBlock)(id viewController, id object);

typedef void(^SLSendRequestAndResendRequestBlock)(id sendBlock, id resendBlock);

#endif
