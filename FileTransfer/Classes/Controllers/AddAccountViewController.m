//
//  AddAccountViewController.m
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import "AddAccountViewController.h"
#import "AppConstants.h"
#import "XMPPHandler.h"
#import "KeychainUtil.h"
#import "MBProgressHUD.h"
#import "NSString+Contain.h"

#define TIME_OUT 15



@interface AddAccountViewController ()
- (void)removeAccountAction;
- (void)showValueInKeyChain;
- (void)setValueToKeychain;
- (void)timeOutAction;
- (void)timeOut;
- (NSString *)serviceName;
- (NSString *)keychainString;
- (void)unregisterCurrentAccount;
- (void)registerNewAccount;
- (BOOL)registerRequireError:(XMPPIQ *)iq;
@end

@implementation AddAccountViewController
@synthesize accountType;
@synthesize usernameTextField;
@synthesize passwordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.serviceName;
    
    xmppTransports = [[XMPPHandler sharedInstance] xmppTransport];
    //Add remove account button
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStyleBordered target:self action:@selector(removeAccountAction)];
    self.navigationItem.rightBarButtonItem = removeButton;
	// Do any additional setup after loading the view.
    
    [self showValueInKeyChain];
    
    //Add xmppstream delegate

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[XMPPHandler sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[XMPPHandler sharedInstance] xmppStream] removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
   
}

#pragma mark - IBAction methods
- (IBAction)addAcountAction:(id)sender {
    registerType = kRegisterNewAccount;
    [self unregisterCurrentAccount];
    [self timeOutAction];
}

#pragma mark - XMPPStream delegate
//<iq xmlns="jabber:client" type="result" id="reg2" from="yahoo.ukkc-macbook.local" to="user4@ukkc-macbook.local/22c676b6"/>
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSString *service = [[self serviceName] stringByAppendingFormat:@".%@", xmppHostName];
    NSString *from = [iq attributeStringValueForName:@"from"];
    if ([service isEqualToString:from]) {
        NSString *idValue = [iq attributeStringValueForName:@"id"];
        if ([iq isResultIQ]) {            
            if ([idValue containsString:@"unreg"]) {
                if (registerType == kRegisterNewAccount) {
                    [self registerNewAccount];
                }
            }
            else if ([idValue containsString:@"reg"]) {
                doneRegister = YES;
                [self setValueToKeychain];
                //dispatch_sync(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Add account success!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                //});                
            }
            else {
                
            }

        }
        else if ([iq isErrorIQ]) {
            if ([iq.xmlns isEqualToString:@"jabber:client"]) {
                if ([self registerRequireError:iq]) {
                    if (registerType == kRegisterNewAccount) {
                        [self registerNewAccount];
                    }
                }
                else {
                    doneRegister = YES;
                    //dispatch_sync(dispatch_get_main_queue(), ^{
                    [KeychainUtil resetKeychainForKey:[self keychainString]];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Add account Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    //});
                }
            }
        }
    }
	return NO;
}


#pragma mark - Private methods
- (void)removeAccountAction {
    [self unregisterCurrentAccount];
    usernameTextField.text = @"";
    passwordTextField.text = @"";
}

- (void)showValueInKeyChain {
    NSString *username = @"";
    NSString *password = @"";
    NSString *keychainString = nil;
    if (accountType == yahooAccountType) {
        keychainString = kYahooPasswordKeychainIdentify;
    }
    else if (accountType == msnAccountType) {
        keychainString = kMSNPasswordKeychainIdentify;
    }
    
    if (keychainString) {
        username = [KeychainUtil attrAccountForKeychainWithKey:keychainString];
        password = [KeychainUtil valueDataForKeychainWithKey:keychainString];
    }
    
    usernameTextField.text = username;
    passwordTextField.text = password;
}

- (void)setValueToKeychain {
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    NSString *keychainString = nil;
    if (accountType == yahooAccountType) {
        keychainString = kYahooPasswordKeychainIdentify;
    }
    else if (accountType == msnAccountType) {
        keychainString = kMSNPasswordKeychainIdentify;
    }
    
    if (keychainString) {
        [KeychainUtil setAttrAccount:username forKeychainWithKey:keychainString];
        [KeychainUtil setValueData:password forKeychainWithKey:keychainString];
    }

}


- (NSString *)serviceName {
    NSString *service = @"";
    if (accountType == yahooAccountType) {
        service = kYahooService;
    }
    else if (accountType == msnAccountType) {
        service = kMSNService;
    }
    return service;
}

- (void)timeOutAction {
    
    int64_t delayInSeconds = TIME_OUT;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *title = @"Fail";
        NSString *message = @"Add account fail!";
        if (!doneRegister) {
            [KeychainUtil resetKeychainForKey:[self keychainString]];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

    });
}

- (void)timeOut {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *title = @"Fail";
        NSString *message = @"Add account fail!";
        if (!doneRegister) {
            [KeychainUtil resetKeychainForKey:[self keychainString]];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    });
}

- (NSString *)keychainString {
    NSString *keychainString = nil;
    if (accountType == yahooAccountType) {
        keychainString = kYahooPasswordKeychainIdentify;
    }
    else if (accountType == msnAccountType) {
        keychainString = kMSNPasswordKeychainIdentify;
    }
    return keychainString;
}

- (void)unregisterCurrentAccount {
    [xmppTransports unregisterLegacyService:self.serviceName];
    [KeychainUtil resetKeychainForKey:[self keychainString]];
}

- (void)registerNewAccount {
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    [xmppTransports registerLegacyService:self.serviceName username:username password:password];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[self performSelector:@selector(timeOut) withObject:nil afterDelay:TIME_OUT];
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

- (BOOL)registerRequireError:(XMPPIQ *)iq {
    DDXMLElement *errorElement = [iq elementForName:@"error"];
    if (errorElement) {
        NSInteger code = [errorElement attributeIntegerValueForName:@"code"];
        if (code == 407) {
            return YES;
        }
    }
    return NO;
}
@end
