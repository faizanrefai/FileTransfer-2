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
#import "XMPPHandler.h"
//#import "XMPPUserCoreDataStorageObject+DisplayName.h"
#import "ContactViewCell.h"

#define PADDING 20

@interface FriendListViewController ()
- (void)showAccounts;
- (void)showRooms;
- (void)showActionSheet;
- (void)showFileReceived;
- (NSArray *)urlsAtSavedDirectory;

- (void)configureBarItem;
@end

@implementation FriendListViewController
@synthesize tableView,contacts,contactsArray;

- (id)init {
    self = [super init];
    if (self) {
        [self configureBarItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    contactsArray=[[NSMutableArray alloc] init];
//	ABAddressBookRef m_addressbook = ABAddressBookCreate();
//	
//	if (!m_addressbook) {
//		NSLog(@"opening address book");
//	}
//	
//	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
//	CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
//	
//	for (int i=0;i < nPeople;i++) {
//		NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
//        
//		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
//        
//		//For username and surname
//		ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
//		CFStringRef firstName, lastName;
//		firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
//		lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
//		[dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
//		
//		//For Email ids
//		ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
//		if(ABMultiValueGetCount(eMail) > 0) {
//			[dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
//            
//		}
//		
//		//For Phone number
//		NSString* mobileLabel;
//		for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
//			mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
//			if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
//			{
//				[dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//			}
//			else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
//			{
//				[dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//				break ;
//			}
//            
//            [contactsArray addObject:dOfPerson];
//            CFRelease(ref);
////            CFRelease(firstName);
////            CFRelease(lastName);
//        }
//        NSLog(@"array is %@",contactsArray);
//	}

//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet)];
//    [[self navigationItem] setLeftBarButtonItem:leftItem];
//    
//    //Add roomlist button
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Rooms" style:UIBarButtonItemStyleBordered target:self action:@selector(showRooms)];
//    [[self navigationItem] setRightBarButtonItem:rightItem];
//    
//    //Actionsheet
//    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Account", @"Files Received", nil];
//    
//    //Handle invite muc
//    XMPPMUC *xmppMUC = [[XMPPHandler sharedInstance] xmppMUC];
//    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
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
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"firstDisplayNameCharacter" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd2, sd1, nil];
		
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@", streamBarJid];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"self.firstDisplayNameCharacter"
		                                                                          cacheName:nil];
//        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//		                                                               managedObjectContext:moc
//		                                                                 sectionNameKeyPath:@"firstDisplayNameCharacter"
//		                                                                          cacheName:nil];

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
			cell.imageView.image = [UIImage imageNamed:@"list_icon.png"];
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
    //cell.accessoryView = imageView;
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];

        return sectionInfo.name;
//		int section = [sectionInfo.name intValue];
//		switch (section)
//		{
//			case 0  : return @"Available";
//			case 1  : return @"Away";
//			default : return @"Offline";
//		}
	}
	
	return @"";
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 20)];
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_listing.png"]];
    
    headerImage.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 20);
    
    [headerView addSubview:headerImage];
    
    //Add label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, 0, 300, headerImage.frame.size.height)];
    [headerView addSubview:label];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    label.backgroundColor = [UIColor clearColor];
    
    return headerView;
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
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[ContactViewCell alloc] initWithStyle:UITableViewCellStyleDefault
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
      oneToOneChatViewController.lbl=user.displayName;
    [[self navigationController] pushViewController:oneToOneChatViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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


#pragma mark - IBAction methods
- (IBAction)viewYatoAction:(id)sender {

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

- (void)configureBarItem {
    //Tabbar Item
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contact" image:nil tag:0];
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"contact_icon_green.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"contact_icon_gray.png"]];
    
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               nil] forState:UIControlStateNormal];
    
    UIColor *selectedColor = [UIColor colorWithRed: (float)71/255 green: (float)156/255 blue: (float)63/255 alpha:1.0];
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               selectedColor, UITextAttributeTextColor,
                                               nil] forState:UIControlStateSelected];
}
@end
