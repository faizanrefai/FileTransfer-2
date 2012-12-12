//
//  FriendList.m
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendListViewController.h"
#import "XMPPHandler.h"
#import "OneToOneChatViewController.h"
#import "AppConstants.h"
#import "RoomListViewController.h"
#import "UIAlertView+BlockExtensions.h"
#import "RoomChatViewController.h"
#import "RoomChatRepository.h"
#import "NSString+Contain.h"
#import "XMPPUtil.h"
#import "DirectoryHelper.h"

@interface FriendListViewController ()
- (void)showAccounts;
- (void)showRooms;
- (void)showActionSheet;
- (void)showFileReceived;
- (NSArray *)urlsAtSavedDirectory;
@end

@implementation FriendListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Users";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet)];
    [[self navigationItem] setLeftBarButtonItem:leftItem];
    
    //Add roomlist button
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Rooms" style:UIBarButtonItemStyleBordered target:self action:@selector(showRooms)];
    [[self navigationItem] setRightBarButtonItem:rightItem];
    
    //Actionsheet
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Account", @"Files Received", nil];
    
    //Handle invite muc
    XMPPMUC *xmppMUC = [[XMPPHandler sharedInstance] xmppMUC];
    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [fetchedResultsController setDelegate:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[XMPPHandler sharedInstance] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@", streamBarJid];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
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
	[[self tableView] reloadData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	} 
	else
	{
		NSData *photoData = [[[XMPPHandler sharedInstance] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
			cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
	}
    
    //Check accout type
    NSString *accountImageName = @"xmpp-sign-icon";
    if ([user.jidStr containsString:[XMPPUtil yahooFullServiceName]]) {
        accountImageName = @"yahoo-sign-icon";
    }
    else if ([user.jidStr containsString:[XMPPUtil msnFullServiceName]]) {
        accountImageName = @"msn-sign-icon";
    }
    UIImage *acountTypeImage = [UIImage imageNamed:accountImageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:acountTypeImage];
    cell.accessoryView = imageView;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"FriendListCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
	}
	
	
    @try {
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        cell.textLabel.text = user.displayName;
        [self configurePhotoForCell:cell user:user];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get the selected object in order to fill out the detail view
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    OneToOneChatViewController *oneToOneChatViewController = [[OneToOneChatViewController alloc] init];
    oneToOneChatViewController.user = user;
    [[self navigationController] pushViewController:oneToOneChatViewController animated:YES];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //Get the selected object in order to fill out the detail view
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    OneToOneChatViewController *dest = [segue destinationViewController];
    dest.user = user;
}

#pragma mark - XMPPMuc delegate
- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitation:(XMPPMessage *)message {
    NSLog(@"receive invitaion: %@", message);
    NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
	NSXMLElement * invite  = [x elementForName:@"invite"];
    
    //From jid
    NSString *from = [invite attributeStringValueForName:@"from"];
    XMPPJID *fromJid = [XMPPJID jidWithString:from];
    
    
    //Room jid
    NSString *roomJidString = [message attributeStringValueForName:@"from"];
    XMPPJID *roomJid = [XMPPJID jidWithString:roomJidString];
    
    //Invite reason
    NSXMLElement *reason = [invite elementForName:@"reason"];
    NSString *inviteReason = [reason stringValue];
    inviteReason = [inviteReason stringByAppendingFormat:@"(%@)", roomJid.user];
    
    XMPPRoom *room = [[RoomChatRepository sharedInstance] roomWithJID:roomJid];
    if (!room.isJoined) {
        @autoreleasepool {
            [[[UIAlertView alloc] initWithTitle:fromJid.user message:inviteReason completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                if (buttonIndex == 1) {
                    
                    RoomChatViewController *roomChatViewController = [[RoomChatViewController alloc] initWithRoomJID:roomJid];
                    [self.navigationController pushViewController:roomChatViewController animated:YES];
                }
                
            } cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil] show];
        }
    }    
}

- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitationDecline:(XMPPMessage *)message {
    
}


#pragma mark - AccoutView delegate
- (void)didXMPPLogOut {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionsheet delegate
#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"index: %d", buttonIndex);
    if (buttonIndex == 0) {
        [self showAccounts];
    }
    //Show memeber
    else if (buttonIndex == 1){
        [self showFileReceived];
    }
}


#pragma mark - Private methods
- (void)showAccounts {
    AccountsViewController *accountViewController = [[AccountsViewController alloc] init];
    accountViewController.delegate = self;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)showRooms {
    RoomListViewController *roomListViewController = [[RoomListViewController alloc] init];
    [self.navigationController pushViewController:roomListViewController animated:YES];
}

- (void)showActionSheet {
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}
- (void)showFileReceived {
    ListFilesViewController *listFilesViewController = [[ListFilesViewController alloc] init];
    listFilesViewController.urlArray = [self urlsAtSavedDirectory];
    
    UINavigationController *navigationCotroller = [[UINavigationController alloc] initWithRootViewController:listFilesViewController];
    [self presentModalViewController:navigationCotroller animated:YES];
}

- (NSArray *)urlsAtSavedDirectory {
    NSString *savedFilePath = [DirectoryHelper savedFilesDirectory];
    NSArray *urls = [DirectoryHelper filesAtPath:savedFilePath];
    return urls;
}
@end
