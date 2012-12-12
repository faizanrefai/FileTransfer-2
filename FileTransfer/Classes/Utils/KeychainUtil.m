//
//  KeychainUtil.m
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import "KeychainUtil.h"
#import "AppConstants.h"

@implementation KeychainUtil

+ (void)initAllKeychains {
    [self keychainForKey:kXMPPPasswordKeychainIdentify];
    [self keychainForKey:kYahooPasswordKeychainIdentify];
    [self keychainForKey:kMSNPasswordKeychainIdentify];
}

+ (KeychainItemWrapper *)keychainForKey:(NSString *)key {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:key accessGroup:nil];
    return keychain;
}

+ (NSString *)attrAccountForKeychain:(KeychainItemWrapper *)keychain {
    NSString  *attrAccount = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    return attrAccount;
}

+ (NSString *)valueDataForKeychain:(KeychainItemWrapper *)keychain {
    NSString  *valueData = [keychain objectForKey:(__bridge id)kSecValueData];
    return valueData;
}


+ (NSString *)attrAccountForKeychainWithKey:(NSString *)keyString {
    KeychainItemWrapper *keychain = [self keychainForKey:keyString];
    return [self attrAccountForKeychain:keychain];
}

+ (NSString *)valueDataForKeychainWithKey:(NSString *)keyString {
    KeychainItemWrapper *keychain = [self keychainForKey:keyString];
    return [self valueDataForKeychain:keychain];

}

//Setter methods
+ (void)setAttrAccount:(id)object forKeychain:(KeychainItemWrapper *)keychain {
    [keychain setObject:object forKey:(__bridge id)kSecAttrAccount];
}

+ (void)setValueData:(id)object forKeychain:(KeychainItemWrapper *)keychain {
    [keychain setObject:object forKey:(__bridge id)kSecValueData];
}

+ (void)setAttrAccount:(id)object forKeychainWithKey:(NSString *)keyString {
    KeychainItemWrapper *keychain = [self keychainForKey:keyString];
    [keychain setObject:object forKey:(__bridge id)kSecAttrAccount];
}

+ (void)setValueData:(id)object forKeychainWithKey:(NSString *)keyString {
    KeychainItemWrapper *keychain = [self keychainForKey:keyString];
    [keychain setObject:object forKey:(__bridge id)kSecValueData];
}

//Reset methods
+ (void)resetKeychain:(KeychainItemWrapper *)keychain {
    [keychain resetKeychainItem];
}

+ (void)resetKeychainForKey:(NSString *)keyString {
    KeychainItemWrapper *keychain = [self keychainForKey:keyString];
    [self resetKeychain:keychain];
}
@end
