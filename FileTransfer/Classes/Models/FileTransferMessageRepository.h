//
//  FileTransferMessageRepository.h
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import "BaseRepository.h"
#import "FileTransferMessage.h"

@interface FileTransferMessageRepository : BaseRepository
+ (FileTransferMessageRepository *)sharedInstance;
- (FileTransferMessage *)createFileTransferMessage;
- (void)addMessage:(FileTransferMessage *)message;

@end
