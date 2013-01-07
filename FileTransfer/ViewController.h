//
//  ViewController.h
//  FileTransfer
//
//  Created by Admin on 10/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewController.h"

@interface ViewController : UIViewController <RegisterProtocol, UITextFieldDelegate>
@property (nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) IBOutlet UIButton *registerButton;
@property (nonatomic) IBOutlet UIScrollView *mainScrollView;


- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;
@end
