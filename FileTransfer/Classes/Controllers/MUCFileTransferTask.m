//
//  MUCFileTransferTask.m
//  FileTransfer
//
//  Created by Admin on 12/17/12.
//
//

#import "MUCFileTransferTask.h"
#import "DeviceUtil.h"
#import "ShowMessage.h"
#import "DirectoryHelper.h"
#import "EnumTypes.h"
#import "DateUtil.h"
#import "AppConstants.h"
#import "XMPPHandler.h"

@interface MUCFileTransferTask ()

@end

@implementation MUCFileTransferTask
@synthesize progressView;
@synthesize message;

- (id)initWithMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)aMessage {
    self = [super init];
    if (self) {
        message = aMessage;
    }
    return self;
}

- (BOOL)containMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)aMessage {
    BOOL result = YES;
    if (![message.fileName isEqualToString:aMessage.fileName]) {
        result = NO;
    }
    else if (![message.jidStr isEqualToString:aMessage.jidStr]) {
        result = NO;
    }
    else if (![message.roomJIDStr isEqualToString:aMessage.roomJIDStr]) {
        result = NO;
    }
    else if ([message.localTimestamp compare:aMessage.localTimestamp] != NSOrderedSame) {
        result = NO;
    }
    return result;
}



#pragma mark - RKRequest delegate
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if ([request isGET]) {
        // Handling GET /foo.xml
        if ([response isOK] && !receivedFile) {
            NSString *path = [DirectoryHelper savedFilesDirectory];
            path = [path stringByAppendingPathComponent:message.fileName];
            NSError *error = nil;
            NSData *data = response.body;
            [data writeToFile:path options:NSDataWritingAtomic error:&error];
            receivedFile = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:didDownloadFileTransferGroup object:nil];
            
        }
    } else if ([request isPOST]) {
        // Handling POST /other.json  file
        NSString *jsonString = [response bodyAsString];
        NSLog(@"%@", jsonString);
        
        NSString *path = [DirectoryHelper sentFilesDirectory];
        path = [path stringByAppendingPathComponent:message.fileName];
        NSError *error = nil;
        [dataToSend writeToFile:path options:NSDataWritingAtomic error:&error];
        if (!error) {
            
        }
        message.status = [NSNumber numberWithInteger:kFileTransferStatusSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:didDownloadFileTransferGroup object:nil];
        
        [self sendMessageWithFileURL:jsonString status:kFileTransferStatusSuccess];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
}

- (void)request:(RKRequest *)request
didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    });
}

- (void)request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (float)totalBytesReceived/(float)totalBytesExpectedToReceive;
    });
}


#pragma mark - Private methods
- (void)sendFileData:(NSData *)data {
    if (data == nil) {
        return;
    }
    RKParams *params = [RKParams params];
    NSString *name = [DeviceUtil generateUUID];
    name = [name stringByAppendingString:@".png"];
    [params setValue:name forParam:@"name"];
    dataToSend = data;
//    message.fileName = [NSString stringWithFormat:@"photo_%@.png", [DateUtil currentDateStringWithFormat:@"yyyyMMddhhmmss"]];
    
    //Create attachment
    RKParamsAttachment *attchment = [params setData:data MIMEType:@"image/png" forParam:@"file"];
    
    [[RKClient sharedClient] post:@"/file_transfer.php" params:params delegate:self];
}

- (void)recevieFile {
    NSString *path = [NSString stringWithFormat:@"/file_transfer"];
    path = [path stringByAppendingPathComponent:message.remoteURL.lastPathComponent];
    [[RKClient sharedClient] get:path delegate:self];
}


- (void)sendMessageWithFileURL:(NSString *)url status:(FileTransferStatus)status{
    NSString *bodyText = [NSString stringWithFormat:@"send file %@", message.fileName];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:bodyText];
    
    //Create file element
    NSXMLElement *fileElement = [NSXMLElement elementWithName:@"file"];
    [fileElement addAttributeWithName:@"name" stringValue:message.fileName];
    
    if (url) {
        NSString *fullURL = [webServerName stringByAppendingPathComponent:url];
        [fileElement addAttributeWithName:@"url" stringValue:fullURL];
    }
    
    [fileElement addAttributeWithName:@"status" stringValue:[NSString stringWithFormat:@"%d", status]];
    
    XMPPMessage *xmppMessage = [XMPPMessage message];
    [xmppMessage addAttributeWithName:@"to" stringValue:message.roomJIDStr];
    [xmppMessage addAttributeWithName:@"type" stringValue:@"groupchat"];
    [xmppMessage addChild:body];
    [xmppMessage addChild:fileElement];
    
    [[[XMPPHandler sharedInstance] xmppStream] sendElement:xmppMessage];
}

@end
