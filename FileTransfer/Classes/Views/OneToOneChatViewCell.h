//
//  OneToOneChatViewCell.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPMessage.h"
#import "XMPPMessageOneToOneChat.h"

@interface OneToOneChatViewCell : UITableViewCell {
    UIButton *messageButton;
    UILabel *messageLabel;
    UILabel *timeLabel;
    
    UIImage *outGoingChatImage;
    UIImage *inCommingChatImage;
    UIImageView *avartar;
    BOOL isMe;
    BOOL isShowAvatar_;
    XMPPMessageOneToOneChat *chatMessage_;
}

@property(nonatomic, retain) XMPPMessageOneToOneChat *chatMessage;

+ (CGFloat)heightForCellWithText:(NSString *)text;
- (void)layoutViews:(NSString *)text;
@end

