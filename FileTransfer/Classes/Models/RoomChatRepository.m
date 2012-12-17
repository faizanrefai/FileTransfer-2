//
//  RoomChatRepository.m
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import "RoomChatRepository.h"
#import "XMPPHandler.h"
#import "XMPPMessage+XEP0045.h"
#import "DirectoryHelper.h"
#import "XMPPUtil.h"
#import "AppConstants.h"

@interface RoomChatRepository ()
- (void)downloadFileWithURL:(NSString *)url;
- (BOOL)fileExisted:(NSString *)fileName;
@end

@implementation RoomChatRepository
@synthesize rooms;

- (id)init {
    self = [super init];
    if (self) {
        self.rooms = [[NSMutableArray alloc] init];
        [[[XMPPHandler sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
        fileReceiveDict = [[NSMutableDictionary alloc] init];
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
    if (![self roomWithJID:room.roomJID]) {
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

#pragma mark - XMPPStream delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	// This method is invoked on the moduleQueue.
	
    return;
    
	XMPPJID *from = [message from];
    if ([from.resource isEqualToString:[XMPPUtil myUsername]]) {
        return;
    }
	
	// Is this a message we need to store (a chat message)?
	//
	// A message to all recipients MUST be of type groupchat.
	// A message to an individual recipient would have a <body/>.
	
	BOOL isChatMessage;
	
	if ([from isFull])
		isChatMessage = [message isGroupChatMessageWithBody];
	else
		isChatMessage = [message isMessageWithBody];
	
	if (isChatMessage)
	{
        NSXMLElement *fileElement = [message elementForName:@"file"];
        if (fileElement) {
            NSString *fileName = [fileElement attributeStringValueForName:@"name"];
            if (![self fileExisted:fileName]) {
                NSString *url = [fileElement attributeStringValueForName:@"url"];
                [fileReceiveDict setObject:fileName forKey:url];
                [self downloadFileWithURL:url];
            }
        }
	}
}

#pragma mark - Private methods
- (void)downloadFileWithURL:(NSString *)url{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        if (data) {
            //save file to db
            NSString *path = [DirectoryHelper savedFilesDirectory];
            NSString *fileName = [fileReceiveDict objectForKey:url];
            path = [path stringByAppendingPathComponent:fileName];
            NSError *error = nil;
            [data writeToFile:path options:NSDataWritingAtomic error:&error];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:didDownloadFileTransferGroup object:nil];
            }
        }
    });
}

- (BOOL)fileExisted:(NSString *)fileName {
    NSString *path = [DirectoryHelper savedFilesDirectory];
    path = [path stringByAppendingPathComponent:fileName];
    if ([DirectoryHelper fileExistAtPath:path isDir:NO]) {
        return YES;
    }
    return NO;
}
@end
