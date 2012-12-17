//
//  AppConstants.m
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppConstants.h"


#pragma mark - Web server
NSString * const webServerName = @"http://173.201.188.96/~wpalfad/webservice";

NSString * const kStreamBareJIDString = @"MyBareJIDString";
NSString * const xmppHostName = @"palfad.com";
//NSString * const xmppHostName = @"ukkc-macbook.local";
NSString * const xmppConferenceHostName = @"conference.palfad.com";
NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

#pragma mark - Notification Message
NSString * const receivedOneToOneMessage = @"ReceivedOneToOneMessage";
NSString * const receivedPresenceStatus = @"ReceivedPresenceStatus";
NSString * const didXMPPAuthenticated = @"didXMPPAuthenticated";
NSString * const didXMPPAuthenticateFail = @"didXMPPAuthenticateFail";
NSString * const xmppDidDisconnect = @"xmppDidDisconnect";
NSString * const xmppDidGetRoomList = @"xmppDidGetRoomList";

NSString * const didDownloadFileTransferGroup = @"didDownloadFileTransferGroup";

#pragma mark - Keychain identify
NSString * const kXMPPPasswordKeychainIdentify = @"XMPPPasswordKeychainIdentify";
NSString * const kYahooPasswordKeychainIdentify = @"YahooKeychainIdentify";
NSString * const kMSNPasswordKeychainIdentify = @"MSNKeychainIdentify";

#pragma mark - xmpp service
NSString * const kYahooService = @"yahoo";
NSString * const kMSNService = @"msn";

#pragma mark - File % Folder
NSString * const kFileFolderName = @"Files";
NSString * const kSentFileFolderName = @"SentFiles";