//
//  NewRoomViewController.m
//  FileTransfer
//
//  Created by Admin on 11/11/12.
//
//

#import "NewRoomViewController.h"
#import "XMPPStream.h"
#import "XMPPHandler.h"
#import "AppConstants.h"
#import "XMPPJID.h"
#import "RoomChatRepository.h"
#import "XMPPUtil.h"
#import "XMPPRoomCoreDataStorage.h"

@interface NewRoomViewController ()
- (void)joinRoom:(NSString *)roomName;
- (BOOL)ownerRoom:(XMPPRoom *)room;
- (void)didGetRoomList:(NSNotification *)notification;
@end

@implementation NewRoomViewController
@synthesize createButton;
@synthesize roomNameTextField;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRoomList:) name:xmppDidGetRoomList object:nil];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [[XMPPDiscoRoom sharedInstance] discoRoom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [room removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction methods
- (IBAction)joinRoomAction:(id)sender {
    NSString *roomName = roomNameTextField.text;
    if (roomName.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter room name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
//        
        [self joinRoom:roomName];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger row = roomList.count;
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RoomListCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    XMPPJID *jid = [roomList objectAtIndex:indexPath.row];
    cell.textLabel.text = jid.user;
    
    //NSLog(@"user: %@", jid.user);
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    XMPPJID *jid = [roomList objectAtIndex:indexPath.row];
    roomNameTextField.text = jid.user;
}

#pragma mark - XMPPRoomDelegate
- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {
    //[[RoomChatRepository sharedInstance] addRoom:room];
    if ([delegate respondsToSelector:@selector(didJointRoom:)]) {
        [delegate didJointRoom:room];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Create room fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    [[RoomChatRepository sharedInstance] addRoom:sender];
    if ([self ownerRoom:sender]) {
        [room fetchConfigurationForm];
    }
    else {
        if ([delegate respondsToSelector:@selector(didJointRoom:)]) {
            [delegate didJointRoom:room];
        }
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    [room configureRoomUsingOptions:nil];
}

#pragma mark - Private methods
- (void)joinRoom:(NSString *)roomName {
    XMPPJID *roomJID = [XMPPJID jidWithUser:roomName domain:xmppConferenceHostName resource:nil];
    
    room = [[RoomChatRepository sharedInstance] roomWithJID:roomJID];
    if ([room isJoined]) {
        if ([delegate respondsToSelector:@selector(didJointRoom:)]) {
            [delegate didJointRoom:room];
        }
    }
    else {
        XMPPStream *xmppStream = [[XMPPHandler sharedInstance] xmppStream];
        //XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage = [[XMPPHandler sharedInstance] xmppRoomCoreDataStore];
        
        room = [[RoomChatRepository sharedInstance] roomWithJID:roomJID];
        if (room == nil) {
            
            XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage = [[XMPPHandler sharedInstance] xmppRoomCoreDataStore];
            room = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomCoreDataStorage jid:roomJID];
        }
        
        //room = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomCoreDataStorage jid:roomJID];
        [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [room activate:xmppStream];
        [room joinRoomUsingNickname:[XMPPUtil myUsername] history:nil];
    }    
        //[room fetchConfigurationForm];
}

- (BOOL)ownerRoom:(XMPPRoom *)xmppRoom {
    NSManagedObjectContext *moc = [[XMPPHandler sharedInstance] managedObjectContext_room];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomOccupantCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"nickname" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ and roomJIDStr=%@ and jidStr=%@", streamBarJid, room.roomJID.bare, room.myRoomJID.full];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];        
    NSArray *items = [moc executeFetchRequest:fetchRequest error:nil];
    
    if ([items count] > 0) {
        XMPPRoomOccupantCoreDataStorageObject *occupant = [items objectAtIndex:0];
        if ([occupant.affiliation isEqualToString:@"owner"]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)didGetRoomList:(NSNotification *)notification {
    roomList = [[XMPPDiscoRoom sharedInstance] rooms];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}


@end
