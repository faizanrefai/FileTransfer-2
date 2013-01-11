//
//  FileTransferTask.m
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import "FileTransferTask.h"
#import "NSXMLElement+XMPP.h"
#import "DirectoryHelper.h"
#import "HUBUtil.h"
#import "MBProgressHUD.h"
#import "FileTransferMessageRepository.h"
#import "XMPPUtil.h"
#import "EnumTypes.h"

@interface FileTransferTask ()
- (BOOL)isFileTransferRequest:(XMPPIQ *)iq;
- (BOOL)isByeStreamsRequestSession:(XMPPIQ *)iq;
@end

@implementation FileTransferTask
@synthesize progressView;

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid {
    self = [super init];
    if (self) {
        jid = aJid;
        xmppStream = stream;
        [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
        isClient = YES;
    }
    return self;
}

- (id)initWithStream:(XMPPStream *)stream fileTransferRequest:(XMPPIQ *)iq {
    self = [super init];
    if (self) {
        xmppStream = stream;
        NSString *jidStr = [iq attributeStringValueForName:@"from"];
        jid = [XMPPJID jidWithString:jidStr];
        
        [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
        siFileTransfer = [[SIFileTransfer alloc] initWithRequestId:iq xmppStream:xmppStream];
        [siFileTransfer sendResponseResult];
        isClient = NO;
    }
    return self;
}

- (void)requestSendFileData:(NSData *)data
                   fileName:(NSString *)fileName
                   mineType:(NSString *)mineType {
    if (siFileTransfer == nil) {
        siFileTransfer = [[SIFileTransfer alloc] initWithXMPPStream:xmppStream jid:jid];
        [siFileTransfer addDelegate:self delegateQueue:dispatch_get_current_queue()];
    }
    dataToSend = data;
    [siFileTransfer sendRequestWithFileName:fileName fileSize:[dataToSend length] mineType:mineType];
}

- (BOOL)containFileTransferMessage:(FileTransferMessage *)message {
    BOOL result = YES;
    if (![message.jidStr isEqualToString:fileTransferMessage.jidStr]) {
        result = NO;
    }
    else  if (![message.streamBareJidStr isEqualToString:fileTransferMessage.streamBareJidStr]) {
        result = NO;
    }
    else if (![message.fileName isEqualToString:fileTransferMessage.fileName]) {
        result = NO;
    }
    else if (message.fromMe.integerValue != fileTransferMessage.fromMe.integerValue) {
        result = NO;
    }
    else if ([message.localTimestamp compare:fileTransferMessage.localTimestamp] != NSOrderedSame) {
        result = NO;
    }
    return result;
}

#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if ([self isByeStreamsRequestSession:iq]) {
        if (byteStreams == nil) {
            byteStreams = [[InBandByteStreams alloc] initWithRequestId:iq xmppStream:xmppStream];
            [byteStreams addDelegate:self delegateQueue:dispatch_get_current_queue()];
            [byteStreams responseAcceptSession];
        }
        
    }
    return NO;
}

#pragma mark - SIFIleTransfer delegate
- (void)siFileTransfer:(SIFileTransfer *)fileTransfer
didReceiveFileTransferRequest:(XMPPIQ *)iq {
    
}
- (void)siFileTransfer:(SIFileTransfer *)fileTransfer
didReceiveFileTransferReponse:(XMPPIQ *)iq {
    if (byteStreams == nil) {
        byteStreams = [[InBandByteStreams alloc] initWithXMPPStream:xmppStream jid:jid];
        [byteStreams addDelegate:self delegateQueue:dispatch_get_current_queue()];
        [byteStreams sendRequestInitiatorSession];
    }
}

#pragma mark - InBandByteStreams delegate
- (void)didReceiveResponseSessionAcceptByteStream:(InBandByteStreams *)byStream  {

    if (!isSending) {
        [byteStreams sendFileData:dataToSend];
        isSending = YES;
    }

}

- (void)didReceiveResponseSessionCancelByteStream:(InBandByteStreams *)byStream  {

}

- (void)inBandByStreams:(InBandByteStreams *)byStream didStartSendFile:(NSString *)filePath {
    NSString *path = [DirectoryHelper sentFilesDirectory];
    path = [path stringByAppendingPathComponent:siFileTransfer.fileName];
    NSError *error = nil;
    [dataToSend writeToFile:path options:NSDataWritingAtomic error:&error];
    if (!error) {
        if (fileTransferMessage == nil) {
            FileTransferMessageRepository *fileTransferMessageRepository = [FileTransferMessageRepository sharedInstance];
            fileTransferMessage = [fileTransferMessageRepository createFileTransferMessage];
            fileTransferMessage.fileName = siFileTransfer.fileName;
            fileTransferMessage.jidStr = jid.bareJID.full;
            fileTransferMessage.url = path;
            fileTransferMessage.localTimestamp = [NSDate date];
            fileTransferMessage.status = [NSNumber numberWithInteger:kFileTransferStatusSending];
            fileTransferMessage.fromMe = [NSNumber numberWithBool:YES];
            fileTransferMessage.streamBareJidStr = [XMPPUtil streamBareJidStr];
            [fileTransferMessageRepository addMessage:fileTransferMessage];
            [fileTransferMessageRepository saveContext];
        }
    }

}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didStartReceiveFile:(NSString *)filePath {
    if (fileTransferMessage == nil) {
        FileTransferMessageRepository *fileTransferMessageRepository = [FileTransferMessageRepository sharedInstance];
        fileTransferMessage = [fileTransferMessageRepository createFileTransferMessage];
        fileTransferMessage.fileName = siFileTransfer.fileName;
        fileTransferMessage.jidStr = jid.bareJID.full;
        fileTransferMessage.localTimestamp = [NSDate date];
        fileTransferMessage.status = [NSNumber numberWithInteger:kFileTransferStatusReceiving];
        fileTransferMessage.fromMe = [NSNumber numberWithBool:NO];
        fileTransferMessage.streamBareJidStr = [XMPPUtil streamBareJidStr];
        [fileTransferMessageRepository addMessage:fileTransferMessage];
        [fileTransferMessageRepository saveContext];
    }
}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didFinishSendFile:(NSString *)filePath{
    NSString *path = [DirectoryHelper sentFilesDirectory];
    path = [path stringByAppendingPathComponent:siFileTransfer.fileName];
    NSError *error = nil;
    [dataToSend writeToFile:path options:NSDataWritingAtomic error:&error];
    if (!error) {
        fileTransferMessage.url = path;
        fileTransferMessage.status = [NSNumber numberWithInteger:kFileTransferStatusSuccess];
        [[FileTransferMessageRepository sharedInstance] saveContext];
    }
}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didFinishReceiveFile:(NSData *)data {
    NSLog(@"data length: %d", data.length);
    //write data to file.
    NSString *path = [DirectoryHelper savedFilesDirectory];
    path = [path stringByAppendingPathComponent:siFileTransfer.fileName];
    NSError *error = nil;
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if (!error) {
        NSString *message = [NSString stringWithFormat:@"Received file: %@", siFileTransfer.fileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            fileTransferMessage.url = path;
            fileTransferMessage.status = [NSNumber numberWithInteger:kFileTransferStatusSuccess];
            [[FileTransferMessageRepository sharedInstance] saveContext];
        });
    }
    else {
        NSLog(@"write file error: %@", error.localizedDescription);
    }
}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didSendDataLength:(NSInteger)dataSentLength {
    NSInteger dataLength = dataToSend.length;
    percent = (float)dataSentLength/(float)dataLength;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (progressView) {
            progressView.progress = percent;
        }
    });
    
}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didReceiveDataLength:(NSInteger)dataReceivedLength {
    NSInteger dataLength = siFileTransfer.fileSize;
    NSLog(@"datalength: %d, receivedlength: %d, percent: %f", dataLength, dataReceivedLength, percent);
    
    percent = (float)dataReceivedLength/(float)dataLength;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progressView) {
            progressView.progress = percent;
        }
    });
}

#pragma mark - Private methods
- (BOOL)isFileTransferRequest:(XMPPIQ *)iq {
    BOOL result = NO;
    NSString *type = [iq type];
    if ([type isEqualToString:@"set"]) {
        NSXMLElement *siElement = [iq elementForName:@"si"];
        if (siElement) {
            NSXMLElement *fileElement = [siElement elementForName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
            if (fileElement) {
                result = YES;
            }
        }
    }
    return result;
}

- (BOOL)isFileTransferResponse:(XMPPIQ *)iq {
    BOOL result = NO;
    NSString *type = [iq type];
    if ([type isEqualToString:@"result"]) {
        NSXMLElement *siElement = [iq elementForName:@"si" xmlns:@"http://jabber.org/protocol/si"];
        if (siElement) {
            NSXMLElement *feature = [siElement elementForName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
            if (feature) {
                result = YES;
            }
        }
    }
    return result;
}

- (BOOL)isByeStreamsRequestSession:(XMPPIQ *)iq {
    BOOL result = NO;
    NSString *type = [iq type];
    if ([type isEqualToString:@"set"]) {
        NSXMLElement *openElement = [iq elementForName:@"open"xmlns:@"http://jabber.org/protocol/ibb"];
        if (openElement) {
            result = YES;
        }
    }
    return result;
}

@end
