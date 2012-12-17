//
//  FileTransferController.m
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import "FileTransferController.h"
#import "XMPPHandler.h"
#import "FileTransferTask.h"
#import "UIAlertView+BlockExtensions.h"

@interface FileTransferController ()
@end

@implementation FileTransferController
+ (FileTransferController *)sharedInstance {
    static FileTransferController *staticInstance = nil;
    if (staticInstance == nil) {
        staticInstance = [[FileTransferController alloc] init];
        
    }
    return staticInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        fileTransferTasks = [[NSMutableArray alloc] init];
        xmppStream = [[XMPPHandler sharedInstance] xmppStream];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)sendFileData:(NSData *)data fileName:(NSString *)fileName mineType:(NSString *)mineType toJID:(XMPPJID *)jid {
    FileTransferTask *fileTrasnferTask = [[FileTransferTask alloc] initWithStream:xmppStream jid:jid];
    [fileTrasnferTask requestSendFileData:data fileName:fileName mineType:mineType];
    
    [fileTransferTasks addObject:fileTrasnferTask];
}

- (void)addProgressView:(UIProgressView *)progressView forMessage:(FileTransferMessage *)message {
    for (FileTransferTask *fileTransferTask in fileTransferTasks) {
        if ([fileTransferTask containFileTransferMessage:message]) {
            fileTransferTask.progressView = progressView;
        }
    }
}
#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if ([self isFileTransferRequest:iq]) {
        NSString *from = [iq attributeStringValueForName:@"from"];
        XMPPJID *jid = [XMPPJID jidWithString:from];
        NSString *message = [NSString stringWithFormat:@"%@ send you a file", jid.user];

        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:message completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                if (buttonIndex == 1) {
                    FileTransferTask *fileTransferTask = [[FileTransferTask alloc] initWithStream:xmppStream fileTransferRequest:iq];
                    [fileTransferTasks addObject:fileTransferTask];
                }
            } cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
            [alert show];
        });
        return YES;
    }
    return NO;
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

@end
