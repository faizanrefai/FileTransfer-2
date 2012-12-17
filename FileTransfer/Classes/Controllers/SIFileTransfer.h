//
//  SIFileTransfer.h
//  FileTransfer
//
//  Created by Admin on 12/6/12.
//
//

#import <Foundation/Foundation.h>
#import "XMPPModule.h"
#import "XMPPIDTracker.h"

@class XMPPIQ;
@class XMPPJID;
@class XMPPStream;

@class SIFileTransfer;

@protocol SIFileTransferDelegate <NSObject>
- (void)siFileTransfer:(SIFileTransfer *)fileTransfer didReceiveFileTransferRequest:(XMPPIQ *)iq;
- (void)siFileTransfer:(SIFileTransfer *)fileTransfer didReceiveFileTransferReponse:(XMPPIQ *)iq;
@end

@interface SIFileTransfer : XMPPModule {
    XMPPJID *jid;
   	XMPPIDTracker *responseTracker;
    NSString *fileName;
    NSUInteger fileSize;
    NSString *mineType;
    NSString *uuid;
}

- (id)initWithXMPPStream:(XMPPStream *)stream jid:(XMPPJID *)jid ;
- (id)initWithRequestId:(XMPPIQ *)iq xmppStream:(XMPPStream *)stream;

- (void)sendRequestWithFileName:(NSString *)fileName
                       fileSize:(unsigned long)size
                       mineType:(NSString *)mineType;
- (void)sendResponseResult;
- (NSString *)fileName;
- (NSInteger)fileSize;
@end
