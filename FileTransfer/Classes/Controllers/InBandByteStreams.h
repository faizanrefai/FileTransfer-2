//
//  InBandByteStreams.h
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import <Foundation/Foundation.h>
#import "XMPPModule.h"
#import "XMPPJID.h"
#import "XMPPIDTracker.h"
#import "XMPPIQ.h"
#import "XMPPStream.h"

@protocol InBandByStreamsDelegate;


@interface InBandByteStreams : XMPPModule {
    NSString *sid;
    NSString *stanza;
    int blockSize;
    XMPPJID *jid;
    int currentSeq;
    NSString *uuid;
    NSInteger dataReceiveLength;
    XMPPIDTracker *responseTracker;
    NSMutableDictionary *dataDictionary;
}

- (id)initWithXMPPStream:(XMPPStream *)stream jid:(XMPPJID *)jid;
- (id)initWithRequestId:(XMPPIQ *)iq xmppStream:(XMPPStream *)stream;
- (void)sendRequestInitiatorSession;
- (void)responseAcceptSession;
- (void)sendCloseStream;
- (void)sendFileAtPath:(NSString *)path;
- (void)sendFileData:(NSData *)data;

@end

@protocol InBandByStreamsDelegate <NSObject>

@optional
- (void)didReceiveResponseSessionAcceptByteStream:(InBandByteStreams *)byStream ;
- (void)didReceiveResponseSessionCancelByteStream:(InBandByteStreams *)byStream ;


- (void)inBandByStreams:(InBandByteStreams *)byStream didStartSendFile:(NSString *)filePath;
- (void)inBandByteStreams:(InBandByteStreams *)byStream didStartReceiveFile:(NSString *)filePath;
- (void)inBandByteStreams:(InBandByteStreams *)byStream didFinishSendFile:(NSString *)filePath;
- (void)inBandByteStreams:(InBandByteStreams *)byStream didFinishReceiveFile:(NSData *)data;

- (void)inBandByteStreams:(InBandByteStreams *)byStream didSendDataLength:(NSInteger)percent;
- (void)inBandByteStreams:(InBandByteStreams *)byStream didReceiveDataLength:(NSInteger)percent;


@end
