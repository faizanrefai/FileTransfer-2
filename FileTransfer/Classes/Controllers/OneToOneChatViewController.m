//
//  OneToOneChatViewController.m
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OneToOneChatViewController.h"
#import "AppDelegate.h"
#import "XMPPMessageOneToOneChat.h"
#import "OneToOneChatViewCell.h"
#import "XMPPHandler.h"
#import "AppConstants.h"

@interface OneToOneChatViewController ()
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
@end

@implementation OneToOneChatViewController
@synthesize user = user_;
@synthesize inputTextField;
@synthesize mainTable;
@synthesize sendButton;
@synthesize inputTextView;

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
    [self.mainTable setDelegate:self];
    [self.mainTable setDataSource:self];
    self.inputTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
    self.title = @"Chat";
	// Do any additional setup after loading the view.
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



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	return [[[self fetchedResultsController] fetchedObjects] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageOneToOneChat *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    return [OneToOneChatViewCell heightForCellWithText:message.body];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"OneToOneChatCell";
	
	OneToOneChatViewCell *cell = (OneToOneChatViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[OneToOneChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
	}
	
	XMPPMessageOneToOneChat *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	cell.chatMessage = message;

	return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSManagedObjectContext *moc = appDelegate.managedObjectContext;
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageOneToOneChat"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
        
        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidStr=%@ AND streamBareJidStr=%@ ", user_.jidStr, streamBarJid];
        [fetchRequest setPredicate:predicate];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainTable reloadData];
    [self.mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[self fetchedResultsController] fetchedObjects] count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UIAction methods
- (IBAction)sendAction:(id)sender {
    NSString *text = inputTextField.text;
    if (text.length > 0) {
        [[XMPPHandler sharedInstance] sendMessage:text to:user_.jidStr];
    }
    inputTextField.text = @"";
}


#pragma mark - Keyboard delegate
-(void) keyboardDidShow: (NSNotification *)notif 
{
    // If keyboard is visible, return
    if (keyboardVisible) 
    {
        NSLog(@"Keyboard is already visible. Ignoring notification.");
        return;
    }
    
    // Get the size of the keyboard.
    NSDictionary* info = [notif userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // Save the current location so we can restore
    // when keyboard is dismissed
    
    // Resize the scroll view to make room for the keyboard
    CGRect viewFrame = self.mainTable.frame;
    viewFrame.size.height -= keyboardSize.height;
    self.mainTable.frame = viewFrame;
    
    //Set frame for input view
    viewFrame = self.inputTextView.frame;
    viewFrame.origin.y -= keyboardSize.height;
    self.inputTextView.frame = viewFrame;
    
    // Keyboard is now visible
    keyboardVisible = YES;

}

-(void) keyboardDidHide: (NSNotification *)notif 
{
    // Is the keyboard already shown
    if (!keyboardVisible) 
    {
        NSLog(@"Keyboard is already hidden. Ignoring notification.");
        return;
    }
    
    // Get the size of the keyboard.
    NSDictionary* info = [notif userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    CGRect viewFrame = self.mainTable.frame;
    viewFrame.size.height += keyboardSize.height;
    self.mainTable.frame = viewFrame;
    
    //Set frame for input view
    viewFrame = self.inputTextView.frame;
    viewFrame.origin.y += keyboardSize.height;
    self.inputTextView.frame = viewFrame;
    
    // Keyboard is no longer visible
    keyboardVisible = NO;	
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [inputTextField resignFirstResponder];
    return YES;
}
@end
