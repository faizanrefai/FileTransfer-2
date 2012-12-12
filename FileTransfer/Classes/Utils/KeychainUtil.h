//
//  KeychainUtil.h
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@interface KeychainUtil : NSObject

+ (void)initAllKeychains;
+ (KeychainItemWrapper *)keychainForKey:(NSString *)key;

//Getter methods
+ (NSString *)attrAccountForKeychain:(KeychainItemWrapper *)keychain;
+ (NSString *)valueDataForKeychain:(KeychainItemWrapper *)keychain;

+ (NSString *)attrAccountForKeychainWithKey:(NSString *)keyString;
+ (NSString *)valueDataForKeychainWithKey:(NSString *)keyString;

//Setter methods
+ (void)setAttrAccount:(id)object forKeychain:(KeychainItemWrapper *)keychain;
+ (void)setValueData:(id)object forKeychain:(KeychainItemWrapper *)keychain;
+ (void)setAttrAccount:(id)object forKeychainWithKey:(NSString *)keyString;
+ (void)setValueData:(id)object forKeychainWithKey:(NSString *)keyString;

//Reset methods
+ (void)resetKeychain:(KeychainItemWrapper *)keychain;
+ (void)resetKeychainForKey:(NSString *)keyString;

@end
