//
//  ShowMessage.h
//  BlutoothChat
//
//  Created by Admin on 11/23/12.
//  Copyright (c) 2012 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kMessageTypeNone,
    kMessageTypeInfo,
    kMessageTypeWarning,
    kMessageTypeError
}ShowMessageType;

@interface ShowMessage : NSObject
+ (void)showInfoMessageWithTitle:(NSString *)title message:(NSString *)message type:(ShowMessageType)type inView:(UIView *)view;
@end
