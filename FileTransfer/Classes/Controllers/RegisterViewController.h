//
//  RegisterViewController.h
//  FileTransfer
//
//  Created by Admin on 11/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RegisterProtocol <NSObject>

- (void)registerSuccessWithUsername:(NSString *)usrname password:(NSString *)password;
- (void)registerDidFailWithMessage:(NSString *)message;
@end

@interface RegisterViewController : UIViewController <UITextFieldDelegate, RKRequestDelegate>{
    BOOL keyboardVisible;
    CGRect contentFrame;
    NSString *username;
    NSString *password;
}
@property (nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (nonatomic) IBOutlet UIButton *registerButton;
@property (nonatomic) IBOutlet UIScrollView *registerScrollView;

@property (nonatomic, assign) id<RegisterProtocol> delegate;

- (IBAction)registerAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@end
