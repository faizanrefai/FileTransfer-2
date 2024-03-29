//
//  FileTransferController.h
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import <Foundation/Foundation.h>
#import "XMPPStream.h"
#import "FileTransferMessage.h"

@interface FileTransferController : NSObject <UIAlertViewDelegate>{
    XMPPStream *xmppStream;
    NSMutableArray *fileTransferTasks;
}

+ (FileTransferController *)sharedInstance;

- (void)sendFileData:(NSData *)data fileName:(NSString *)fileName mineType:(NSString *)mineType toJID:(XMPPJID *)jid;
- (void)addProgressView:(UIProgressView *)progressView forMessage:(FileTransferMessage *)message;
@end
