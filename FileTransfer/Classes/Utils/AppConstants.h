//
//  AppConstants.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kStreamBareJIDString;
extern NSString * const xmppHostName;
extern NSString * const xmppConferenceHostName;
extern NSString *const kXMPPmyJID;
extern NSString *const kXMPPmyPassword;
#pragma mark - Notification Message
extern NSString * const receivedOneToOneMessage;
extern NSString * const receivedPresenceStatus;
extern NSString * const didXMPPAuthenticated;
extern NSString * const didXMPPAuthenticateFail;
extern NSString * const xmppDidDisconnect;
extern NSString * const xmppDidGetRoomList;

#pragma mark - Keychain identify
extern NSString * const kXMPPPasswordKeychainIdentify;
extern NSString * const kYahooPasswordKeychainIdentify;
extern NSString * const kMSNPasswordKeychainIdentify;

#pragma mark - xmpp service
extern NSString * const kYahooService;
extern NSString * const kMSNService;

#pragma mark - File % Folder
extern NSString * const kFileFolderName;
extern NSString * const kSentFileFolderName;