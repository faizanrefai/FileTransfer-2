//
//  XMPPMessageOneToOneChat.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPJID.h"
#import "XMPPMessage.h"

@interface XMPPMessageOneToOneChat : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * fromMe;
@property (nonatomic, retain) XMPPJID * jid;
@property (nonatomic, retain) NSString * jidStr;
@property (nonatomic, retain) NSDate * localTimestamp;
@property (nonatomic, retain) XMPPMessage * message;
@property (nonatomic, retain) NSString * messageStr;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSDate * remoteTimestamp;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSNumber * type;

@end
