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
#import "DirectoryHelper.h"
#import "FileTransferController.h"
#import "FileTransferMessage.h"
#import "OneToOneFileTransferCell.h"

#define FILE_TRANSFER_CELL_HEIGH 100
#define TABBAR_HEIGH 48

@interface OneToOneChatViewController ()
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void)sendFileAction;
- (NSString *)currentDateString;
- (void)reloadMessages;
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
    [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:@"palfad.com", nil]];
    turnSockets = [[NSMutableArray alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
    self.title = @"Chat";
	// Do any additional setup after loading the view.
    
    //Add send file button
    UIBarButtonItem *sendFileButton = [[UIBarButtonItem alloc] initWithTitle:@"Send File" style:UIBarButtonItemStyleBordered target:self action:@selector(sendFileAction)];
    self.navigationItem.rightBarButtonItem = sendFileButton;
    
    [[[XMPPHandler sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self reloadMessages];
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

- (void)dealloc {
    [chatMessageFetchedResultsController setDelegate:nil];
    [fileTransferMessageFetchedResultsController setDelegate:nil];
    [[[XMPPHandler sharedInstance] xmppStream] removeDelegate:self];
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
	//return [[[self chatMessageFetchedResultsController] fetchedObjects] count];
    return messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heigh = 44;
    NSObject *message = [messages objectAtIndex:indexPath.row];
    if ([message isKindOfClass:[FileTransferMessage class]]) {
        heigh = FILE_TRANSFER_CELL_HEIGH;
    }
    
    NSString *text = [(XMPPMessageOneToOneChat *)message body];
    heigh = [OneToOneChatViewCell heightForCellWithText:text];
    
    return heigh;
//    XMPPMessageOneToOneChat *message = [[self chatMessageFetchedResultsController] objectAtIndexPath:indexPath];
//    return [OneToOneChatViewCell heightForCellWithText:message.body];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *message = [messages objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    if (![message isKindOfClass:[FileTransferMessage class]]) {
        static NSString *CellIdentifier = @"OneToOneChatCell";
        
        cell = (OneToOneChatViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[OneToOneChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        }
        [(OneToOneChatViewCell *)cell setChatMessage:(XMPPMessageOneToOneChat *)message];
    }
    else {
        static NSString *CellIdentifier = @"FileTransferCell";
        
        cell = (OneToOneFileTransferCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[OneToOneFileTransferCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CellIdentifier];
        }
        [(OneToOneFileTransferCell *)cell setMessage:(FileTransferMessage *)message];
    }
	return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)chatMessageFetchedResultsController
{
	if (chatMessageFetchedResultsController == nil)
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
		
		chatMessageFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[chatMessageFetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![chatMessageFetchedResultsController performFetch:&error])
		{
		}
        
	}
	
	return chatMessageFetchedResultsController;
}

- (NSFetchedResultsController *)fileTransferMessageFetchedResultsController
{
	if (fileTransferMessageFetchedResultsController == nil)
	{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSManagedObjectContext *moc = appDelegate.managedObjectContext;
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"FileTransferMessage"
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
		
		fileTransferMessageFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                  managedObjectContext:moc
                                                                                    sectionNameKeyPath:nil
                                                                                             cacheName:nil];
		[fileTransferMessageFetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fileTransferMessageFetchedResultsController performFetch:&error])
		{
		}
        
	}
	
	return fileTransferMessageFetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self reloadMessages];
    [self.mainTable reloadData];
    
    [self.mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UIAction methods
- (IBAction)sendAction:(id)sender {
    NSString *text = inputTextField.text;
    if (text.length > 0) {
        [[XMPPHandler sharedInstance] sendMessage:text to:user_.jidStr];
    }
    inputTextField.text = @"";
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    viewFrame.size.height -= (keyboardSize.height - TABBAR_HEIGH);
    self.mainTable.frame = viewFrame;
    
    //Set frame for input view
    viewFrame = self.inputTextView.frame;
    viewFrame.origin.y -= (keyboardSize.height - TABBAR_HEIGH);
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
    viewFrame.size.height += (keyboardSize.height - TABBAR_HEIGH);
    self.mainTable.frame = viewFrame;
    
    //Set frame for input view
    viewFrame = self.inputTextView.frame;
    viewFrame.origin.y += (keyboardSize.height - TABBAR_HEIGH);
    self.inputTextView.frame = viewFrame;
    
    // Keyboard is no longer visible
    keyboardVisible = NO;	
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [inputTextField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark - UIImagePickerController delegate
//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //Show OriginalImage size
    NSString *fileName = [NSString stringWithFormat:@"photo_%@.png", [self currentDateString]];
    NSData *data = UIImageJPEGRepresentation(originalImage, 1);
        [[FileTransferController sharedInstance] sendFileData:data fileName:fileName mineType:@"image/png" toJID:user_.primaryResource.jid];
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

#pragma mark - 
#pragma TURNSocket delegate
- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
    socket.delegate = self;
    if ([sender isClient]) {
        NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"yahoo-icon.png"], 9);
        //data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:data withTimeout:-1 tag:0];
    }
    else {
        NSData *dataF = [[NSData alloc] init];
        [socket readDataToData:dataF withTimeout:-1 tag:0];
        NSLog(@"dataF: %d", [dataF
                             length]);//  dataF: 0
    }
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
    NSLog(@"turnSocketDidFail");
}

#pragma mark -  GCDAsyncSocket delegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData: %ld, %@", tag, data);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag: %ld", tag);
}

#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if([TURNSocket isNewStartTURNRequest:iq]) {
        dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[[XMPPHandler sharedInstance] xmppStream] incomingTURNRequest:iq];
                [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                [turnSockets addObject:turnSocket];
            });
        });
    }
	return YES;
}


#pragma mark - Private methods
- (void)sendFileAction {
    [self showImagePicker];
}

- (NSString *)currentDateString {
    NSDate *date = [NSDate date];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddhhmmss"];
    NSString *string = [formater stringFromDate:date];
    return string;
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

- (void)reloadMessages {
    NSArray *chatMessages = [self.chatMessageFetchedResultsController fetchedObjects];
    //NSArray *fileTransferMessages = [self.fileTransferMessageFetchedResultsController fetchedObjects];
    messages = nil;
    messages = [[NSMutableArray alloc] initWithArray:chatMessages];
    //[messages addObjectsFromArray:fileTransferMessages];
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescription];
    [messages sortedArrayUsingDescriptors:sortArray];
}
@end
