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
#import "FileTransferMessage.h"
#import "FileTransferMessageRepository.h"
#import "XMPPUtil.h"

@interface FileTransferTask ()
- (BOOL)isFileTransferRequest:(XMPPIQ *)iq;
- (BOOL)isByeStreamsRequestSession:(XMPPIQ *)iq;
@end

@implementation FileTransferTask
- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)aJid {
    self = [super init];
    if (self) {
        jid = aJid;
        xmppStream = stream;
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        isClient = YES;
    }
    return self;
}

- (id)initWithStream:(XMPPStream *)stream fileTransferRequest:(XMPPIQ *)iq {
    self = [super init];
    if (self) {
        xmppStream = stream;
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
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
        [siFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    dataToSend = data;
    [siFileTransfer sendRequestWithFileName:fileName fileSize:[dataToSend length] mineType:mineType];
}


#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if ([self isByeStreamsRequestSession:iq]) {
        if (byteStreams == nil) {
            byteStreams = [[InBandByteStreams alloc] initWithRequestId:iq xmppStream:xmppStream];
            [byteStreams addDelegate:self delegateQueue:dispatch_get_main_queue()];
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
        [byteStreams addDelegate:self delegateQueue:dispatch_get_main_queue()];
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
    isSending = NO;
}

- (void)inBandByStreams:(InBandByteStreams *)byStream didStartSendFile:(NSString *)filePath {
}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didStartReceiveFile:(NSString *)filePath {
}

- (void)inBandByteStreams:(InBandByteStreams *)byStream didFinishSendFile:(NSString *)filePath{
    NSString *path = [DirectoryHelper sentFilesDirectory];
    path = [path stringByAppendingPathComponent:siFileTransfer.fileName];
    NSError *error = nil;
    [dataToSend writeToFile:path options:NSDataWritingAtomic error:&error];
    if (!error) {
        FileTransferMessageRepository *fileTransferMessageRepository = [FileTransferMessageRepository sharedInstance];
        FileTransferMessage *fileTransferMessage = [fileTransferMessageRepository createFileTransferMessage];
        fileTransferMessage.fileName = siFileTransfer.fileName;
        fileTransferMessage.url = path;
        fileTransferMessage.jidStr = jid.bareJID.full;
        fileTransferMessage.localTimestamp = [NSDate date];
        fileTransferMessage.status = [NSNumber numberWithInteger:kFileTransferStatusSuccess];
        fileTransferMessage.fromMe = [NSNumber numberWithBool:YES];
        fileTransferMessage.streamBareJidStr = [XMPPUtil streamBareJidStr];
        [fileTransferMessageRepository addMessage:fileTransferMessage];
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
        if (!showReceivedMessage) {
            NSString *message = [NSString stringWithFormat:@"Received file: %@", siFileTransfer.fileName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
                        
            FileTransferMessageRepository *fileTransferMessageRepository = [FileTransferMessageRepository sharedInstance];
            FileTransferMessage *fileTransferMessage = [fileTransferMessageRepository createFileTransferMessage];
            fileTransferMessage.fileName = siFileTransfer.fileName;
            fileTransferMessage.url = path;
            fileTransferMessage.localTimestamp = [NSDate date];
            fileTransferMessage.status = [NSNumber numberWithInteger:kFileTransferStatusSuccess];
            fileTransferMessage.fromMe = [NSNumber numberWithBool:NO];
            fileTransferMessage.streamBareJidStr = [XMPPUtil streamBareJidStr];
            fileTransferMessage.jidStr = jid.bareJID.full;
            [fileTransferMessageRepository addMessage:fileTransferMessage];
        }
    }
    else {
        NSLog(@"write file error: %@", error.localizedDescription);
    }
    isSending = NO;
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
