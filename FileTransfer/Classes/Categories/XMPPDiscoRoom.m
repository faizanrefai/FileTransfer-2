//
//  XMPPDiscoRoom.m
//  FileTransfer
//
//  Created by Admin on 11/9/12.
//
//

#import "XMPPDiscoRoom.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPIQ.h"
#import "XMPPJID.h"
#import "AppConstants.h"
#import "XMPPStream.h"
#import "XMPPRoom.h"

@implementation XMPPDiscoRoom
@synthesize rooms;

+ (XMPPDiscoRoom *)sharedInstance {
    static XMPPDiscoRoom *staticInstance = nil;
    if (staticInstance == nil) {
        staticInstance = [[XMPPDiscoRoom alloc] init];        
    }
    return staticInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        rooms = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)discoRoom {
    dispatch_block_t block = ^{ @autoreleasepool {		
		// <iq type='get'
		//       id='config1'
		//       to='coven@chat.shakespeare.lit'>
		//   <query xmlns='http://jabber.org/protocol/muc#owner'/>
		// </iq>
		
        XMPPJID __strong *jid = [XMPPJID jidWithString:xmppConferenceHostName];
        XMPPIQ  __strong *iq = [[XMPPIQ alloc] initWithType:@"get" to:jid];
        NSXMLElement __strong *queryElement = [NSXMLElement elementWithName:@"query" xmlns:XMPPDiscoRoomNamespace];
        [iq addChild:queryElement];
        [xmppStream sendElement:iq];
		
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);
}

- (NSArray *)jointRooms {
    NSMutableArray *jointRooms = [[NSMutableArray alloc] init];
    for (XMPPRoom *room in rooms) {
        if ([room isJoined]) {
            [jointRooms addObject:room];
        }
    }
    return jointRooms;
}

#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *type = [iq type];
	NSXMLElement *queryElement = [iq childElement];
	if ([type isEqualToString:@"result"])
	{
        NSString __strong *xmlns = [queryElement xmlns];
        if ([xmlns isEqualToString:XMPPDiscoRoomNamespace]) {
            [rooms removeAllObjects];
            NSArray *items = [queryElement elementsForName:@"item"];
            for (NSXMLElement *element in items) {
                NSString *roomIDString = [element attributeStringValueForName:@"jid"];
                if (roomIDString) {
                    XMPPJID *roomJID = [XMPPJID jidWithString:roomIDString];
                    [rooms addObject:roomJID];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:xmppDidGetRoomList object:nil];
        }
	}
	
	return NO;
}
@end
