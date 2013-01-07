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
#import "DeviceUtil.h"

#import "FriendListViewController.h"
#import "CurrentOneToOneChatViewController.h"
#import "CallViewController.h"
#import "MediaViewController.h"
#import "SettingsViewController.h"

@interface ViewController ()
- (void)didAuthenticated:(NSNotification *)notification;
- (void)didAuthenticateFail:(NSNotification *)notification;
- (void)xmppDidDisconect:(NSNotification *)notification;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void)loginwithUsername:(NSString *)username password:(NSString *)password;
- (UITabBarController *)createTabBarController;
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


    if ([DeviceUtil isSimulator]) {
        usernameTextField.text = @"hauc1";
    }
    else {
        usernameTextField.text = @"hauc2";
    }
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
    //FriendListViewController *friendListViewController = [[FriendListViewController alloc] init];
    //    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:friendListViewController];
    //    [self presentModalViewController:navigationController animated:YES];

    [self presentModalViewController:[self createTabBarController] animated:YES];
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

- (UITabBarController *)createTabBarController {
//    UITabBarController *tabBarController = [[UITabBarController alloc] initWithNibName:@"MainTaBarController" bundle:[NSBundle mainBundle]];
    //
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];

    //Chat
    CurrentOneToOneChatViewController *currentOneToOneChatViewController = [[CurrentOneToOneChatViewController alloc] init];
    UINavigationController *currentOneToOneChatNavController = [[UINavigationController alloc] initWithRootViewController:currentOneToOneChatViewController];
    [[currentOneToOneChatNavController navigationBar] setHidden:YES];

    //Call
    CallViewController *callViewController = [[CallViewController alloc] init];
    UINavigationController *callNavController = [[UINavigationController alloc] initWithRootViewController:callViewController];
    [[callNavController navigationBar] setHidden:YES];
    
    //Media
    MediaViewController *mediaViewController = [[MediaViewController alloc] init];
    UINavigationController *mediaNavController = [[UINavigationController alloc] initWithRootViewController:mediaViewController];
    [[mediaNavController navigationBar] setHidden:YES];
    
    //Contact
    FriendListViewController *friendListViewController = [[FriendListViewController alloc] init];
    UINavigationController *friendListNavigationController = [[UINavigationController alloc] initWithRootViewController:friendListViewController];
    [[friendListNavigationController navigationBar] setHidden:YES];
    
    //Setttings
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [[settingsNavController navigationBar] setHidden:YES];
    
    
    tabBarController.viewControllers = [NSArray arrayWithObjects: currentOneToOneChatNavController, callNavController, mediaNavController,friendListNavigationController, settingsNavController, nil];
    
    [[tabBarController tabBar] setBackgroundImage:[UIImage imageNamed:@"background_tab_bar.png"]];
    [tabBarController setSelectedIndex:0];
    return tabBarController;
}
@end
