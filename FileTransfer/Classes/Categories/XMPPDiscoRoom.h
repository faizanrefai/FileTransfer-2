//
//  XMPPDiscoRoom.h
//  FileTransfer
//
//  Created by Admin on 11/9/12.
//
//

#import "XMPPModule.h"

static NSString *const XMPPDiscoRoomNamespace  = @"http://jabber.org/protocol/disco#items";

@protocol XMPPDiscoRoomDelegate <NSObject>
- (void)didGetXMPPRoomList:(BOOL)success;
@end

@interface XMPPDiscoRoom : XMPPModule {
    NSMutableArray *rooms;
}
@property (nonatomic, strong) NSMutableArray *rooms;

+ (XMPPDiscoRoom *)sharedInstance;
- (void)discoRoom;
- (NSArray *)jointRooms;
@end
