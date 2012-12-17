//
//  FileTransferMessage.h
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPMessageOneToOneChat.h"


@interface FileTransferMessage : XMPPMessageOneToOneChat

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * url;

@end
