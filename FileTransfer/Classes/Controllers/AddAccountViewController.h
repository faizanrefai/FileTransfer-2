//
//  AddAccountViewController.h
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import <UIKit/UIKit.h>
#import "XMPPTransports.h"
#import "EnumTypes.h"

typedef enum {
    kRegisterTypeNone,
    kRegisterNewAccount,
    kUnregisterAccount
}RegisterType;

@interface AddAccountViewController : UIViewController {
    XMPPTransports *xmppTransports;
    BOOL doneRegister;
    RegisterType registerType;
}

@property (nonatomic) AccountType accountType;
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

- (IBAction)addAcountAction:(id)sender;

@end
