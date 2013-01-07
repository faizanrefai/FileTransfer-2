//
//  RegisterViewController.m
//  FileTransfer
//
//  Created by Admin on 11/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import <Restkit/JSONKit.h>
#import "MBProgressHUD.h"
#import "AppConstants.h"
#import "XMPPHandler.h"


#import "FriendListViewController.h"
#import "CurrentOneToOneChatViewController.h"
#import "CallViewController.h"
#import "MediaViewController.h"
#import "SettingsViewController.h"

@interface RegisterViewController ()
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (UITabBarController *)createTabBarController;
@end

@implementation RegisterViewController
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize rePasswordTextField;
@synthesize registerButton;
@synthesize registerScrollView;
@synthesize delegate;

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
	// Do any additional setup after loading the view.
    //Add keyboard notification handle
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthenticated:) name:didXMPPAuthenticated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthenticateFail:) name:didXMPPAuthenticateFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppDidDisconect:) name:xmppDidDisconnect object:nil];

    [self.registerScrollView setContentSize:self.registerScrollView.frame.size];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction methods
- (void)registerAction:(id)sender {
    username = usernameTextField.text;
    password = passwordTextField.text;
    NSString *rePassword = rePasswordTextField.text;
    NSString *deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    
    if (username.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter username!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if (![password isEqualToString:rePassword]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password not match!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: username, @"Username", password, @"Password", deviceId, @"DeviceID", @"user_info", @"type", nil];
        [[RKClient sharedClient] post:@"/insert_data.php?" params:params delegate:self]; 
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    // allow backspace
    if (range.length > 0 && [string length] == 0) {
        return YES;
    }
    
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
}


#pragma mark - Private methods
- (void)keyboardDidShow:(NSNotification *)notification {
    if (keyboardVisible) {
        return;
    }
    // Get the size of the keyboard.
    NSDictionary* info = [notification userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // Save the current location so we can restore
    // when keyboard is dismissed
    contentFrame = self.registerScrollView.frame;
    
    // Resize the scroll view to make room for the keyboard
    CGRect viewFrame = self.registerScrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
    self.registerScrollView.frame = viewFrame;    

    // Keyboard is now visible
    keyboardVisible = YES;
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (!keyboardVisible) {
        return;
    }
    
    self.registerScrollView.frame = contentFrame;
    keyboardVisible = NO;
}

#pragma mark - RKRequest Delegate
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([request isGET]) {  
        // Handling GET /foo.xml  
        if ([response isOK]) {  
            // Success! Let's take a look at the data  
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);  
        }  
    } else if ([request isPOST]) {  
        // Handling POST /other.json  file
        NSString *jsonString = [response bodyAsString];
        NSLog(@"%@", jsonString);
        id object = [jsonString objectFromJSONString];
        if ([object isKindOfClass:[NSDictionary class]]) {
            //{"UserId":"128","msg":"Username is already LoggedIn"}
            NSDictionary *dataDictionary = (NSDictionary *)object;
            NSString *message = [dataDictionary objectForKey:@"msg"];
            
            if ([message isEqualToString:@"Record Inserted"]) {
                [self loginwithUsername:username password:password];
                if ([delegate respondsToSelector:@selector(registerSuccessWithUsername:password:)]) {
                    [delegate registerSuccessWithUsername:username password:password];
                }
            }
            else if ([message isEqualToString:@"Username is already LoggedIn"]) {
                [self loginwithUsername:username password:password];
                if ([delegate respondsToSelector:@selector(registerSuccessWithUsername:password:)]) {
                    [delegate registerSuccessWithUsername:username password:password];
                }
            }

            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Register Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                if ([delegate respondsToSelector:@selector(registerDidFailWithMessage:)]) {
                    [delegate registerDidFailWithMessage:@"Regiser fail!"];
                }                
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(registerDidFailWithMessage:)]) {
                [delegate registerDidFailWithMessage:@"Regiser fail!"];
            }                
        }
    } else if ([request isDELETE]) {  
        // Handling DELETE /missing_resource.txt  
        if ([response isNotFound]) {  
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);  
        }  
    }  
}  

- (IBAction)cancelAction:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    [usernameTextField resignFirstResponder];
}


- (void)loginwithUsername:(NSString *)userJID password:(NSString *)pass {
    [usernameTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([userJID rangeOfString:xmppHostName].location == NSNotFound) {
        userJID = [userJID stringByAppendingFormat:@"@%@", xmppHostName];
    }
    if (![[XMPPHandler sharedInstance] loginWithUsername:userJID password:pass]) {
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
