//
//  RoomChatViewController.m
//  FileTransfer
//
//  Created by Admin on 11/11/12.
//
//

#import "RoomChatViewController.h"
#import "XMPPHandler.h"
#import "XMPPStream.h"
#import "AppConstants.h"
#import "ChatViewCell.h"
#import "RoomMemberListViewController.h"
#import "RoomChatRepository.h"
#import "XMPPUtil.h"

@interface RoomChatViewController ()
- (void)configureDataForCell:(UITableViewCell *)cell message:(XMPPRoomMessageCoreDataStorageObject *)message;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void)joinRoom;
- (void)showActionSheet;
- (void)exitRoom;
- (void)showMembers;
- (void)showAllUsers;

@end

@implementation RoomChatViewController
@synthesize tableView;
@synthesize inputTextField;
@synthesize sendButton;
@synthesize inputTextView;
@synthesize roomJID;

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
    self.title = roomJID.user;
    
    //Create exit room button
    UIBarButtonItem *exitRoomButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet)];
    [[self navigationItem] setRightBarButtonItem:exitRoomButton];
    
    //
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite User", @"Show Members", @"Leave Room", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[self messageFetchedResultsController] fetchedObjects] count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[self messageFetchedResultsController] fetchedObjects] count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [room removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - public methods
- (id)initWithRoomJID:(XMPPJID *)jid {
    self = [super init];
    if (self) {
        self.roomJID = jid;
        

    }
    return self;
}

- (void)setRoomJID:(XMPPJID *)jid {
    roomJID = jid;
    [self joinRoom];
}

#pragma mark NSFetchedResultsController
- (NSFetchedResultsController *)messageFetchedResultsController
{
	if (messageFetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[XMPPHandler sharedInstance] managedObjectContext_room];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"remoteTimestamp" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
        
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ and roomJIDStr=%@", streamBarJid, roomJID.bare];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		messageFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[messageFetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![messageFetchedResultsController performFetch:&error])
		{
		}        
	}
	
	return messageFetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[self messageFetchedResultsController] fetchedObjects] count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



#pragma mark - UITableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self messageFetchedResultsController] fetchedObjects] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPRoomMessageCoreDataStorageObject *message = [[[self messageFetchedResultsController] fetchedObjects] objectAtIndex:indexPath.row];
    return [ChatViewCell heightForCellWithText:message.body];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChatViewCell";
	
	ChatViewCell *cell = (ChatViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier];
	}
    NSManagedObject *message = [[[self messageFetchedResultsController] fetchedObjects] objectAtIndex:indexPath.row];
    cell.message = message;
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - UIAction methods
- (IBAction)sendAction:(id)sender {
    NSString *text = inputTextField.text;
    if (text.length > 0) {
        [room sendMessage:text];
    }
    inputTextField.text = @"";
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"index: %d", buttonIndex);
    if (buttonIndex == 0) {
        [self showAllUsers];
    }
    else if (buttonIndex == 1){
        [self showMembers];
    }
    else if (buttonIndex == 2) {
        [self exitRoom];
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [inputTextField resignFirstResponder];
    return YES;
}

#pragma mark - UsersViewController delegate
- (void)didSelectUser:(XMPPUserCoreDataStorageObject *)user {
    [self dismissModalViewControllerAnimated:YES];
    NSString *myUsername = [XMPPUtil myUsername];
    NSString *message = [NSString stringWithFormat:@"%@ invite you join room: %@", myUsername, room.roomJID.user];
    [room inviteUser:user.jid withMessage:message];
}

#pragma mark - Private methods
- (void)configureDataForCell:(UITableViewCell *)cell message:(XMPPRoomMessageCoreDataStorageObject *)message {
    
}

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
    CGRect viewFrame = self.tableView.frame;
    viewFrame.size.height -= keyboardSize.height;
    self.tableView.frame = viewFrame;
    
    //Set frame for input view
    viewFrame = self.inputTextView.frame;
    viewFrame.origin.y -= keyboardSize.height;
    self.inputTextView.frame = viewFrame;
    
    // Keyboard is now visible
    keyboardVisible = YES;
    if ([[[self messageFetchedResultsController] fetchedObjects] count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[self messageFetchedResultsController] fetchedObjects] count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

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
    
    CGRect viewFrame = self.tableView.frame;
    viewFrame.size.height += keyboardSize.height;
    self.tableView.frame = viewFrame;
    
    //Set frame for input view
    viewFrame = self.inputTextView.frame;
    viewFrame.origin.y += keyboardSize.height;
    self.inputTextView.frame = viewFrame;
    
    // Keyboard is no longer visible
    keyboardVisible = NO;
    if ([[[self messageFetchedResultsController] fetchedObjects] count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[[self messageFetchedResultsController] fetchedObjects] count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void)joinRoom {
    room = [[RoomChatRepository sharedInstance] roomWithJID:self.roomJID];
    if (room == nil) {
        
        XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage = [[XMPPHandler sharedInstance] xmppRoomCoreDataStore];
        room = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomCoreDataStorage jid:roomJID];
    }
    if (![room isJoined]) {
        XMPPStream *xmppStream = [[XMPPHandler sharedInstance] xmppStream];
        [room activate:xmppStream];
        NSString *myJIDString = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        XMPPJID *myJID = [XMPPJID jidWithString:myJIDString];
        [room joinRoomUsingNickname:myJID.user history:nil];
        [[RoomChatRepository sharedInstance] addRoom:room];
    }
    [room removeDelegate:self];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)exitRoom {
    [room leaveRoom];
    [[RoomChatRepository sharedInstance] removeRoom:room];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)showActionSheet {
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

- (void)showMembers {
    NSManagedObjectContext *moc = [[XMPPHandler sharedInstance] managedObjectContext_room];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomOccupantCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"nickname" ascending:YES];    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ and roomJIDStr=%@", streamBarJid, roomJID.bare];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *items = [moc executeFetchRequest:fetchRequest error:nil];
    RoomMemberListViewController *memberListViewController = [[RoomMemberListViewController alloc] init];
    memberListViewController.members = items;
    [self.navigationController pushViewController:memberListViewController animated:YES];

}

- (void)showAllUsers {
    SelectUserViewController *usersViewController = [[SelectUserViewController alloc] init];
    usersViewController.delegate = self;
    [self presentModalViewController:usersViewController animated:YES];
}


@end
