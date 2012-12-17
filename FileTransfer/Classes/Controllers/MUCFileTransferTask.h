//
//  MUCFileTransferTask.h
//  FileTransfer
//
//  Created by Admin on 12/17/12.
//
//

#import <Foundation/Foundation.h>
#import "XMPPRoomFileTransferMessageCoreDataStorageObject.h"
#import "XMPPJID.h"
#import <RestKit/RestKit.h>

@interface MUCFileTransferTask : NSObject <RKRequestDelegate>{
    NSData *dataToSend;
    XMPPRoomFileTransferMessageCoreDataStorageObject *message;
    BOOL receivedFile;
}

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) XMPPRoomFileTransferMessageCoreDataStorageObject *message;

- (id)initWithMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message;
- (BOOL)containMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message;

- (void)sendFileData:(NSData *)data;
- (void)recevieFile;
@end
