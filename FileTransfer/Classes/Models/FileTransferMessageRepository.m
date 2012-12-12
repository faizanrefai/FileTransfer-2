//
//  FileTransferMessageRepository.m
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import "FileTransferMessageRepository.h"

@implementation FileTransferMessageRepository
+ (FileTransferMessageRepository *)sharedInstance {
    static FileTransferMessageRepository *staticInstance = nil;
    if (staticInstance == nil) {
        staticInstance = [[FileTransferMessageRepository alloc] init];
    }
    return staticInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        entityName_ = @"FileTransferMessage";
    }
    return self;
}

- (FileTransferMessage *)createFileTransferMessage {
    FileTransferMessage *message = (FileTransferMessage *)[NSEntityDescription insertNewObjectForEntityForName:entityName_ inManagedObjectContext:managedObjectContext_];
    return message;
}

- (void)addMessage:(FileTransferMessage *)message {
    if (message) {
        [self insertObject:message];
    }
}

@end
