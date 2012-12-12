//
//  XMPPMessageOneToOneRepository.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseRepository.h"
#import "XMPPMessageOneToOneChat.h"
#import "XMPPMessage.h"
#import "XMPPStream.h"
#import "FileTransferMessage.h"


@interface XMPPMessageOneToOneRepository : BaseRepository

+(XMPPMessageOneToOneRepository *)instance;

- (XMPPMessageOneToOneChat *)createOneToOneMessage;
- (void)addOneToOneMessage:(XMPPMessageOneToOneChat *)message;

- (void)handleIncomingMessage:(XMPPMessage *)message stream:(XMPPStream *)stream;
- (void)handleOutgoingMessage:(XMPPMessage *)message stream:(XMPPStream *)stream;
@end
