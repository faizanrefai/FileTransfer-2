//
//  MUCFileTransferController.m
//  FileTransfer
//
//  Created by Admin on 12/17/12.
//
//

#import "MUCFileTransferController.h"

@implementation MUCFileTransferController
+ (MUCFileTransferController *)sharedInstance {
    static MUCFileTransferController *staticInstance;
    if (staticInstance == nil) {
        staticInstance = [[MUCFileTransferController alloc] init];
    }
    return staticInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        fileTransferTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (MUCFileTransferTask *)fileTransferTaskForMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message {
    for (MUCFileTransferTask *fileTransferTask in fileTransferTasks) {
        if ([fileTransferTask containMessage:message]) {
            return fileTransferTask;
        }
    }
    return nil;
}

- (MUCFileTransferTask *)createFileTransferTaskWithMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message {
    MUCFileTransferTask *fileTransferTask = [self fileTransferTaskForMessage:message];
    if (fileTransferTask == nil) {
        fileTransferTask = [[MUCFileTransferTask alloc] initWithMessage:message];
        [fileTransferTasks addObject:fileTransferTask];        
    }
    return fileTransferTask;
}

@end
