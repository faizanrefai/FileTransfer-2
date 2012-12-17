//
//  MUCFileTransferController.h
//  FileTransfer
//
//  Created by Admin on 12/17/12.
//
//

#import <Foundation/Foundation.h>
#import "MUCFileTransferTask.h"
#import "XMPPRoomFileTransferMessageCoreDataStorageObject.h"

@interface MUCFileTransferController : NSObject {
    NSMutableArray *fileTransferTasks;
}
+(MUCFileTransferController *)sharedInstance;
- (MUCFileTransferTask *)fileTransferTaskForMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message;
- (MUCFileTransferTask *)createFileTransferTaskWithMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message;
@end
