//
//  XMPPUtil.m
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import "XMPPUtil.h"
#import "AppConstants.h"

@implementation XMPPUtil
+ (NSString *)streamBareJidStr {
    NSString *streamBareJidString = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
    return streamBareJidString;

}

+ (NSString *)myJidString {
    NSString *myJidStr = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyJID];
    return myJidStr;
}

+ (NSString *)myUsername {
    XMPPJID *myJid = [XMPPJID jidWithString:[self streamBareJidStr]];
    return myJid.user;
}

+ (XMPPJID *)myBareJID {
    XMPPJID *myJid = [XMPPJID jidWithString:[self streamBareJidStr]];
    return myJid;
}

+ (NSString *)fullServiceName:(NSString *)name {
    return [name stringByAppendingFormat:@".%@", xmppHostName];
}

+ (NSString *)yahooFullServiceName {
    return [self fullServiceName:kYahooService];
}

+ (NSString *)msnFullServiceName {
    return [self fullServiceName:kMSNService];
}

@end
