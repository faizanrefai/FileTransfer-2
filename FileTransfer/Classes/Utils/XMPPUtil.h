//
//  XMPPUtil.h
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import <Foundation/Foundation.h>
#import "XMPPJID.h"

@interface XMPPUtil : NSObject
+ (NSString *)streamBareJidStr;
+ (NSString *)myUsername;
+ (NSString *)myJidString;
+ (XMPPJID *)myBareJID;
+ (NSString *)fullServiceName:(NSString *)name;
+ (NSString *)yahooFullServiceName;
+ (NSString *)msnFullServiceName;
@end
