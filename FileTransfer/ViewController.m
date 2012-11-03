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

@interface ViewController ()

@end

@implementation ViewController
@synthesize passwordTextField;
@synthesize usernameTextField;
@synthesize loginButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    if (![[XMPPHandler sharedInstance] loginWithUsername:userJID password:password]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error!" 
		                                                    message:@"User JID or password not correct!." 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Ok" 
		                                          otherButtonTitles:nil];
		[alertView show];
    }
    else {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil];
//        
//        UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
        FriendListViewController *friendListViewController = [[FriendListViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:friendListViewController];
                [self presentModalViewController:navigationController animated:YES];
    }
}
@end
