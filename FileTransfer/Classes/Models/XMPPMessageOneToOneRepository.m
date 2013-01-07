//
//  XMPPMessageOneToOneRepository.m
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XMPPMessageOneToOneRepository.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPElement+Delay.h"
#import "AppConstants.h"

@interface XMPPMessageOneToOneRepository ()
- (void)insertMessage:(XMPPMessage *)message 
             outgoing:(BOOL)isOutgoing 
               stream:(XMPPStream *)stream;
@end

@implementation XMPPMessageOneToOneRepository

#pragma mark - Public methods
+(XMPPMessageOneToOneRepository *)instance {
    static XMPPMessageOneToOneRepository *staticInstance = nil;
    if (staticInstance == nil) {
        staticInstance = [[XMPPMessageOneToOneRepository alloc] init];
    }
    return staticInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        entityName_ = @"XMPPMessageOneToOneChat";
    }
    return self;
}

- (XMPPMessageOneToOneChat *)createOneToOneMessage {
    XMPPMessageOneToOneChat *message = (XMPPMessageOneToOneChat *)[NSEntityDescription insertNewObjectForEntityForName:entityName_ inManagedObjectContext:managedObjectContext_];
    return message;
}

- (void)addOneToOneMessage:(XMPPMessageOneToOneChat *)message {
    if (message) {
        [self insertObject:message];
    }
}

- (void)handleIncomingMessage:(XMPPMessage *)message stream:(XMPPStream *)stream {
    [self insertMessage:message outgoing:NO stream:stream];
}

- (void)handleOutgoingMessage:(XMPPMessage *)message stream:(XMPPStream *)stream {
    [self insertMessage:message outgoing:YES stream:stream];    
}

#pragma mark - Private methods
- (void)insertMessage:(XMPPMessage *)message 
             outgoing:(BOOL)isOutgoing 
               stream:(XMPPStream *)stream {
    
    NSDate *localTimestamp;
	NSDate *remoteTimestamp;
    if (isOutgoing)
	{
		localTimestamp = [[NSDate alloc] init];
		remoteTimestamp = nil;
	}
	else
	{
		remoteTimestamp = [message delayedDeliveryDate];
		if (remoteTimestamp) {
			localTimestamp = remoteTimestamp;
		}
		else {
			localTimestamp = [[NSDate alloc] init];
		}
	}

    
    XMPPMessageOneToOneChat *messageOneToOne = [self createOneToOneMessage];
    XMPPJID *jid = [message from];
    if (isOutgoing) {
        jid = [message to];
    }
    //messageOneToOne.message = message;
    //messageOneToOne.jid = jid;
    messageOneToOne.jidStr = [jid bare];
    messageOneToOne.nickname = [jid user];
    messageOneToOne.body = [[message elementForName:@"body"] stringValue];
    messageOneToOne.fromMe = [NSNumber numberWithBool:isOutgoing];
    messageOneToOne.localTimestamp = localTimestamp;
    messageOneToOne.remoteTimestamp = remoteTimestamp;
    messageOneToOne.streamBareJidStr = [[stream myJID] bare];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:insertedOneToOneMessage object:messageOneToOne];
}
@end
