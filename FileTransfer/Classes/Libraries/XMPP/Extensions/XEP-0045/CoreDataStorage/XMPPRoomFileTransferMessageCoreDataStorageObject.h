//
//  XMPPRoomFileTransferMessageCoreDataStorageObject.h
//  FileTransfer
//
//  Created by Admin on 12/17/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPRoomMessageCoreDataStorageObject.h"


@interface XMPPRoomFileTransferMessageCoreDataStorageObject : XMPPRoomMessageCoreDataStorageObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * localURL;
@property (nonatomic, retain) NSString * remoteURL;
@property (nonatomic, retain) NSNumber * status;

@end
