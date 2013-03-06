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
#import "MBProgressHUD.h"
#import "ShowMessage.h"
#import "DeviceUtil.h"
#import "DateUtil.h"
#import "DirectoryHelper.h"
#import "FileTransferViewCell.h"
#import "EnumTypes.h"
#import "MUCFileTransferController.h"
#import "MUCFileTransferTask.h"
#import "ImageDetailViewController.h"
#import <RestKit/RestKit.h>

@interface RoomChatViewController ()
- (void)configureDataForCell:(UITableViewCell *)cell message:(XMPPRoomMessageCoreDataStorageObject *)message;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void)didDownloadFileTransferGroup:(NSNotification *)notification;
- (void)joinRoom;
- (void)showActionSheet;
- (void)exitRoom;
- (void)showMembers;
- (void)showAllUsersWithSelectedJids:(NSArray *)jids;

- (void)sendInviteMessageToUsers:(NSArray *)users;
- (void)sendFile:(NSData *)fileData;
- (void)getBanUserList;
- (void)sendBanUserList:(NSArray *)selectedUsers;
- (void)sendRequestWithSelectedUsers:(NSArray *)selectedUsers;
- (NSArray *)jidsFromRoomOccupants:(NSArray *)occupants;
- (NSArray *)occupantsInRoom;
- (NSArray *)visitorOccupantInRoom;
- (void)sendMessageWithFileURL:(NSString *)url status:(FileTransferStatus)status;
- (void)showImagePicker;
- (void)configureFileTransferCell:(FileTransferViewCell *)cell forMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message;
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
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite User", @"Show Members", @"Lock/Unlock", @"Send File", @"Leave Room", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (didDownloadFileTransferGroup:)
                                                 name: didDownloadFileTransferGroup object:nil];

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
    [messageFetchedResultsController setDelegate:nil];

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
    if ([message isKindOfClass:[XMPPRoomFileTransferMessageCoreDataStorageObject class]]) {
        return [FileTransferViewCell heightForCellWithText:message.body];
    }
    return [ChatViewCell heightForCellWithText:message.body];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *message = [[[self messageFetchedResultsController] fetchedObjects] objectAtIndex:indexPath.row];
    static NSString *CellIdentifier;
    BOOL fileTransferMessage;
    if ([message isKindOfClass:[XMPPRoomFileTransferMessageCoreDataStorageObject class]]) {
        CellIdentifier = @"FileTransferViewCell";
        fileTransferMessage = YES;
    }
    else {
        CellIdentifier = @"ChatViewCell";
        fileTransferMessage = NO;
    }
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
        if (fileTransferMessage) {
            cell = [[FileTransferViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
        }
        else {
            cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier];
        }
	}

    if (fileTransferMessage) {
        [(FileTransferViewCell *)cell setMessage:message];
        [self configureFileTransferCell:cell forMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message];
    }
    else {
        [(ChatViewCell *)cell setMessage:message];
    }
    
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *message = [[[self messageFetchedResultsController] fetchedObjects] objectAtIndex:indexPath.row];
    if ([message isKindOfClass:[XMPPRoomFileTransferMessageCoreDataStorageObject class]]) {
        
        NSString *path = [DirectoryHelper savedFilesDirectory];
        if ([[[(XMPPRoomFileTransferMessageCoreDataStorageObject *)message jid] resource] isEqualToString:[XMPPUtil myUsername]]) {
            path = [DirectoryHelper sentFilesDirectory];
        }
        
        path = [path stringByAppendingPathComponent:fileName];
        NSData *data = nil;
        if ([DirectoryHelper fileExistAtPath:path isDir:NO]) {
            data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
            UIImage *image = [UIImage imageWithData:data];
            ImageDetailViewController *imageDetailViewController = [[ImageDetailViewController alloc] initWithImage:image];
            [[self navigationController] pushViewController:imageDetailViewController animated:YES];
        }
    }
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
    selectType = kSelectTypeNone;
    if (buttonIndex == 0) {
        selectType = kSelectTypeInvite;
        [self showAllUsersWithSelectedJids:nil];
    }
    //Show memeber
    else if (buttonIndex == 1){
        [self showMembers];
    }
    //Lock/unlock
    else if (buttonIndex == 2) {
        selectType = kSelectTypeBan;
        [self getBanUserList];
        
    }
    //Send File
    else if (buttonIndex == 3) {
        selectType = kSendFileType;
        [self showImagePicker];
    }
    //Exit
    else if (buttonIndex == 4) {
        [self exitRoom];
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [inputTextField resignFirstResponder];
    return YES;
}

#pragma mark - SelectUserViewController delegate
- (void)didSelectUsers:(NSArray *)users {
    [self dismissModalViewControllerAnimated:YES];
    if (selectType == kSelectTypeInvite) {
        [self sendInviteMessageToUsers:users];
    }
    else if (selectType == kSelectTypeBan) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendBanUserList:users];
    }
}

#pragma mark - OccupantsViewController Delegate
- (void)occupantsSelected:(NSArray *)occupants {
    [self dismissModalViewControllerAnimated:YES];
    
    if (selectType == kSelectTypeMute) {
        NSArray *occupantsInRoom = [self occupantsInRoom];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSArray *selectedJids = [self jidsFromRoomOccupants:occupants];

        for (XMPPRoomOccupantCoreDataStorageObject *occupant in occupantsInRoom) {
            if ([selectedJids containsObject:occupant.realJIDStr]) {
                occupant.role = @"visitor";
            }
            else {
                //occupant.role = @"participant";
            }
        }
        [room sendVoiceList:occupantsInRoom revokeVoiceList:nil];
    }
}

#pragma mark - XMPPRoom Delegate
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items {
    currentSelectedUsers = items;
    NSArray *jids = [self jidsFromRoomOccupants:currentSelectedUsers];
    [self showAllUsersWithSelectedJids:jids];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ShowMessage showInfoMessageWithTitle:@"Info" message:@"Lock/Unlock user fail!" type:kMessageTypeInfo inView:self.view];
}

- (void)xmppRoom:(XMPPRoom *)sender didSendBanList:(XMPPIQ *)iqResult {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ShowMessage showInfoMessageWithTitle:@"Info" message:@"Lock/Unlock success!" type:kMessageTypeInfo inView:self.view];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotSendBanList:(XMPPIQ *)iqResult {    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ShowMessage showInfoMessageWithTitle:@"Info" message:@"Lock/Unlock user fail!" type:kMessageTypeInfo inView:self.view];

}

- (void)xmppRoom:(XMPPRoom *)sender didFetchVoiceList:(NSArray *)items {
    currentSelectedUsers = items;
    OccupantsViewController *occupantViewController = [[OccupantsViewController alloc] init];
    occupantViewController.delegate = self;
    
    //Get visitor occupant.
    NSArray *visitorOccupants = [self visitorOccupantInRoom];
    occupantViewController.currentOccupantsSelected = visitorOccupants;
    occupantViewController.occupants = [self occupantsInRoom];
    [self presentModalViewController:occupantViewController animated:YES];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchVoiceList:(XMPPIQ *)iqError {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ShowMessage showInfoMessageWithTitle:@"Info" message:@"Mute/Unmute success!" type:kMessageTypeInfo inView:self.view];
}

- (void)xmppRoom:(XMPPRoom *)sender didSendVoiceList:(XMPPIQ *)iqResult {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ShowMessage showInfoMessageWithTitle:@"Info" message:@"Mute/Unmute success!" type:kMessageTypeInfo inView:self.view];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotSendVoiceList:(XMPPIQ *)iqError {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [ShowMessage showInfoMessageWithTitle:@"Info" message:@"Mute/Unmute user fail!" type:kMessageTypeInfo inView:self.view];
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
        
        NSString *path = [DirectoryHelper sentFilesDirectory];
        path = [path stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        [dataToSend writeToFile:path options:NSDataWritingAtomic error:&error];
        if (!error) {
            
        }
        [self sendMessageWithFileURL:jsonString status:kFileTransferStatusSending];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    [ShowMessage showInfoMessageWithTitle:@"Error" message:@"send file fail!" type:kMessageTypeError inView:self.view];
}

- (void)request:(RKRequest *)request
didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    progressView.progress = totalBytesWritten/totalBytesExpectedToWrite;
    if ([request isKindOfClass:[RKObjectLoader class]]){
    
    }
}

- (void)request:(RKRequest *)request didReceiveData:(NSInteger)bytesReceived totalBytesReceived:(NSInteger)totalBytesReceived totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive {
    if ([request isKindOfClass:[RKObjectLoader class]]){
        
    }
}
         
#pragma mark -
#pragma mark - UIImagePickerController delegate
//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //Show OriginalImage size
    dataToSend = UIImageJPEGRepresentation(originalImage, 1);
    [self sendFile:dataToSend];
    [self dismissModalViewControllerAnimated:YES];
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

//Tells the delegate that the user picked an image. (Deprecated in iOS 3.0. Use imagePickerController:didFinishPickingMediaWithInfo: instead.)
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
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

- (void)didDownloadFileTransferGroup:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self tableView] reloadData];        
    });
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
    NSArray *items = [self occupantsInRoom];
    RoomMemberListViewController *memberListViewController = [[RoomMemberListViewController alloc] init];
    memberListViewController.members = items;
    [self.navigationController pushViewController:memberListViewController animated:YES];
}

- (void)showAllUsersWithSelectedJids:(NSArray *)jids {
    SelectUserViewController *usersViewController = [[SelectUserViewController alloc] init];
    if (jids) {
        usersViewController.usersSelected = jids;
    }
    usersViewController.delegate = self;
    [self presentModalViewController:usersViewController animated:YES];
}

/**
 * Send invite message to first user selected.
 */
- (void)sendInviteMessageToUsers:(NSArray *)users {
    if (users.count > 0) {
        NSString *myUsername = [XMPPUtil myUsername];
        NSString *message = [NSString stringWithFormat:@"%@ invite you join room: %@", myUsername, room.roomJID.user];
        XMPPUserCoreDataStorageObject *user = [users objectAtIndex:0];
        [room inviteUser:user.jid withMessage:message];
    }
}

- (void)sendFile:(NSData *)fileData {
    NSString *name = [DeviceUtil generateUUID];
    name = [name stringByAppendingString:@".png"];
    fileName = [NSString stringWithFormat:@"photo_%@.png", [DateUtil currentDateStringWithFormat:@"yyyyMMddhhmmss"]];
//    RKParams *params = [RKParams params];
//    NSString *name = [DeviceUtil generateUUID];
//    name = [name stringByAppendingString:@".png"];
//    [params setValue:name forParam:@"name"];
//    
//    fileName = [NSString stringWithFormat:@"photo_%@.png", [DateUtil currentDateStringWithFormat:@"yyyyMMddhhmmss"]];
//    
//    //Create attachment
//    RKParamsAttachment *attchment = [params setData:fileData MIMEType:@"image/png" forParam:@"file"];
//    
//    [[RKClient sharedClient] post:@"/file_transfer.php" params:params delegate:self];
    [self sendMessageWithFileURL:nil status:kFileTransferStatusSending];
    dataToSend = fileData;
}

/*
 * Get Ban user list from server.
 */
- (void)getBanUserList {
    [room fetchBanList];
}

/*
 * send list ban user
 */
- (void)sendBanUserList:(NSArray *)users {
    NSMutableArray *selectedJids = [[NSMutableArray alloc] init];
    for (XMPPUserCoreDataStorageObject *user in users) {
        NSString *jid = user.jidStr;
        [selectedJids addObject:jid];
    }    
    
    NSMutableArray *removeBanList = [[NSMutableArray alloc] init];
    NSArray *currentSelectedJids = [self jidsFromRoomOccupants:currentSelectedUsers];
    for (NSString *jid in currentSelectedJids) {
        if (![selectedJids containsObject:jid]) {
            [removeBanList addObject:jid];
        }
    }
    [room sendBanList:selectedJids removeBanList:removeBanList];
}

- (void)sendRequestWithSelectedUsers:(NSArray *)users {
    NSMutableArray *selectedJids = [[NSMutableArray alloc] init];
    for (XMPPUserCoreDataStorageObject *user in users) {
        NSString *jid = user.jidStr;
        [selectedJids addObject:jid];
    }
    
    NSMutableArray *removeList = [[NSMutableArray alloc] init];
    NSArray *currentSelectedJids = [self jidsFromRoomOccupants:currentSelectedUsers];
    for (NSString *jid in currentSelectedJids) {
        if (![selectedJids containsObject:jid]) {
            [removeList addObject:jid];
        }
    }

    if (selectType == kSelectTypeBan) {
        [room sendBanList:selectedJids removeBanList:removeList];
    }
    else if (selectType ==kSelectTypeMute) {
        //NSMutableArray *voiceOccupants = [[NSMutableArray alloc] init];
        //NSMutableArray *revokeVoiceOccupants = [[NSMutableArray alloc] init];
        //[room sendVoiceList:selectedJids revokeVoiceList:removeList];
    }
}

- (NSArray *)jidsFromRoomOccupants:(NSArray *)occupants {
    NSMutableArray *jids = [[NSMutableArray alloc] init];
    for (XMPPRoomOccupantCoreDataStorageObject *occupant in occupants) {
        [jids addObject:occupant.realJIDStr];
    }
    return jids;
}

- (NSArray *)occupantsInRoom {
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
    return items;
}

- (NSArray *)visitorOccupantInRoom {
    NSArray *occupants = [self occupantsInRoom];
    NSMutableArray *visitorOccupants = [[NSMutableArray alloc] init];
    for (XMPPRoomOccupantCoreDataStorageObject *occupant in occupants) {
        if ([occupant.role isEqualToString:@"visitor"]) {
            [visitorOccupants addObject:occupant];
        }
    }
    return visitorOccupants;
}

- (void)sendMessageWithFileURL:(NSString *)url status:(FileTransferStatus)status{
    NSString *bodyText = [NSString stringWithFormat:@"send file %@", fileName];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:bodyText];
    
    //Create file element
    NSXMLElement *fileElement = [NSXMLElement elementWithName:@"file"];
    [fileElement addAttributeWithName:@"name" stringValue:fileName];

    if (url) {
        NSString *fullURL = [webServerName stringByAppendingPathComponent:url];
        [fileElement addAttributeWithName:@"url" stringValue:fullURL];
    }

    [fileElement addAttributeWithName:@"status" stringValue:[NSString stringWithFormat:@"%d", status]];    
    XMPPMessage *message = [XMPPMessage message];
    [message addAttributeWithName:@"to" stringValue:[roomJID full]];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    [message addChild:body];
    [message addChild:fileElement];
    
    [[[XMPPHandler sharedInstance] xmppStream] sendElement:message];
    
    
}

- (void)showImagePicker {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    [imagePickerController setAllowsEditing:YES];
    
    //Check PhotoLibrary available or not
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentModalViewController:imagePickerController animated:YES];
}

- (void)configureFileTransferCell:(FileTransferViewCell *)cell forMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)message {
    
    MUCFileTransferTask *fileTransferTask = [[MUCFileTransferController sharedInstance] fileTransferTaskForMessage:message];
    
    if (message.status.integerValue == kFileTransferStatusSending) {
        if (fileTransferTask == nil) {
            fileTransferTask = [[MUCFileTransferController sharedInstance] createFileTransferTaskWithMessage:message];
            if (message.fromMe) {
                [fileTransferTask sendFileData:dataToSend];
            }
        }
        fileTransferTask.progressView = cell.progressView;
    }
    else if (message.status.integerValue == kFileTransferStatusSuccess) {
        if (fileTransferTask == nil) {
            fileTransferTask = [[MUCFileTransferController sharedInstance] createFileTransferTaskWithMessage:message];
        }        
        if (!message.fromMe.boolValue) {
            NSString *path = [DirectoryHelper savedFilesDirectory];
            //path = [DirectoryHelper sentFilesDirectory];
            path = [path stringByAppendingPathComponent:message.fileName];
            if (![DirectoryHelper fileExistAtPath:path isDir:NO]) {
                [fileTransferTask recevieFile];
            }
        }
        fileTransferTask.progressView = cell.progressView;
    }
}

@end
