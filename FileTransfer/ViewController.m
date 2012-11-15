//
//  ViewController.m
//  FileTransfer
//
//  Created by Admin on 10/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "XMPPHandler.h"
#import "FriendListViewController.h"
#import "RegisterViewController.h"
#import "AppConstants.h"
#import "MBProgressHUD.h"

@interface ViewController ()
- (void)didAuthenticated:(NSNotification *)notification;
- (void)didAuthenticateFail:(NSNotification *)notification;
- (void)xmppDidDisconect:(NSNotification *)notification;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void)loginwithUsername:(NSString *)username password:(NSString *)password;
@end

@implementation ViewController
@synthesize passwordTextField;
@synthesize usernameTextField;
@synthesize loginButton;
@synthesize registerButton;
@synthesize mainScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthenticated:) name:didXMPPAuthenticated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthenticateFail:) name:didXMPPAuthenticateFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppDidDisconect:) name:xmppDidDisconnect object:nil];


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - IBAction methods
- (IBAction)loginAction:(id)sender {
    NSString *password = [passwordTextField text];
    NSString *userJID = [usernameTextField text];
    [self loginwithUsername:userJID password:password];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *registerViewController = [[RegisterViewController alloc] init];
    registerViewController.delegate = self;
    [self presentModalViewController:registerViewController animated:YES];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - RegisterProtocol delegate
- (void)registerSuccessWithUsername:(NSString *)username password:(NSString *)password {
    [self dismissModalViewControllerAnimated:YES];
    [self loginwithUsername:username password:password];
}

-(void)registerDidFailWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Register Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Private methods
- (void)keyboardDidShow:(NSNotification *)notification {
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
}

- (void)loginwithUsername:(NSString *)userJID password:(NSString *)password {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([userJID rangeOfString:xmppHostName].location == NSNotFound) {
        userJID = [userJID stringByAppendingFormat:@"@%@", xmppHostName];
    }
    if (![[XMPPHandler sharedInstance] loginWithUsername:userJID password:password]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error!" 
		                                                    message:@"User JID or password not correct!." 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
		[alertView show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)didAuthenticated:(NSNotification *)notification {
    FriendListViewController *friendListViewController = [[FriendListViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:friendListViewController];
    [self presentModalViewController:navigationController animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didAuthenticateFail:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Loin fail, username or password not correct" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)xmppDidDisconect:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can not connect to xmpp server!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}
@end
