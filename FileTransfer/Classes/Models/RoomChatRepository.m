//
//  RoomChatRepository.m
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import "RoomChatRepository.h"

@implementation RoomChatRepository
@synthesize rooms;

- (id)init {
    self = [super init];
    if (self) {
        self.rooms = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)sharedInstance {
    static RoomChatRepository *staticInstance = nil;
    if (staticInstance == nil) {
        staticInstance = [[RoomChatRepository alloc] init];
    }
    return staticInstance;
}

- (void)addRoom:(XMPPRoom *)room {
    if (![rooms containsObject:room]) {
        [rooms addObject:room];
    }
}

- (void)removeRoom:(XMPPRoom *)room {
    if ([rooms containsObject:room]) {
        [rooms removeObject:room];
    }
}

- (XMPPRoom *)roomWithName:(NSString *)roomName {
    XMPPRoom *result = nil;
    for (XMPPRoom *room in rooms) {
        NSString *name = room.roomJID.user;
        if ([roomName isEqualToString:name]) {
            result = room;
            break;
        }
    }
    return result;
}

- (XMPPRoom *)roomWithJID:(XMPPJID *)roomJid {
    XMPPRoom *result = nil;
    for (XMPPRoom *room in rooms) {
        if ([roomJid isEqualToJID:room.roomJID]) {
            result = room;
            break;
        }
    }
    return result;
}

@end
