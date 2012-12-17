//
//  EnumTypes.h
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    accountTypeNone,
    yahooAccountType,
    msnAccountType,
    xmppAccountType
}AccountType;

typedef enum {
    kFileTransferStatusNone,
    kFileTransferStatusSending,
    kFileTransferStatusReceiving,
    kFileTransferStatusFail,
    kFileTransferStatusSuccess
}FileTransferStatus;
