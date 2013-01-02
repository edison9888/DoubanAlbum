//
//  UIAlertViewAddition.h
//  DoubanAlbum
//
//  Created by Tonny on 12-12-10.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "UIAlertViewAddition.h"

@implementation UIAlertView (Addition)

+(void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:title message:message  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end