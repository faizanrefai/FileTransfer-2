//
//  FileTransferTask.h
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import <Foundation/Foundation.h>
#import "SIFileTransfer.h"
#import "InBandByteStreams.h"
#import "XMPPJID.h"
#import "XMPPStream.h"
#import "FileTransferMessage.h"

@interface FileTransferTask : NSObject {
    SIFileTransfer *siFileTransfer;
    InBandByteStreams *byteStreams;
    XMPPJID *jid;
    XMPPStream *xmppStream;
    NSData *dataToSend;
    BOOL isClient;
    float percent;
    BOOL isSending;
    UIProgressView *progressView;
    FileTransferMessage *fileTransferMessage;
}

@property (nonatomic, strong) UIProgressView *progressView;

- (id)initWithStream:(XMPPStream *)stream jid:(XMPPJID *)jid;
- (id)initWithStream:(XMPPStream *)stream fileTransferRequest:(XMPPIQ *)iq;
- (void)requestSendFileData:(NSData *)data fileName:(NSString *)fileName mineType:(NSString *)mineType;
- (BOOL)containFileTransferMessage:(FileTransferMessage *)message;
@end
