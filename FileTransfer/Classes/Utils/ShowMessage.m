//
//  ShowMessage.m
//  BlutoothChat
//
//  Created by Admin on 11/23/12.
//  Copyright (c) 2012 Admin. All rights reserved.
//

#import "ShowMessage.h"

@implementation ShowMessage
+ (void)showInfoMessageWithTitle:(NSString *)title message:(NSString *)message type:(ShowMessageType)type inView:(UIView *)view {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
