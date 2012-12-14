//
//  RoomChatRepository.h
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import <Foundation/Foundation.h>
#import "XMPPRoom.h"
#import "XMPPJID.h"

@interface RoomChatRepository : NSObject {
    NSMutableDictionary *fileReceiveDict;
}

@property (nonatomic, strong) NSMutableArray *rooms;

+ (id)sharedInstance;
- (void)addRoom:(XMPPRoom *)room;
- (void)removeRoom:(XMPPRoom *)room;
- (XMPPRoom *)roomWithName:(NSString *)roomName;
- (XMPPRoom *)roomWithJID:(XMPPJID *)roomJid;

@end
