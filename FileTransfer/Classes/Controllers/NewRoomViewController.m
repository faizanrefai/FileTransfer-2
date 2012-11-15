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

@interface NewRoomViewController ()
- (void)createRoom:(NSString *)roomName;
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
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [room removeDelegate:self];
}

#pragma mark - IBAction methods
- (IBAction)createRoomAction:(id)sender {
    NSString *roomName = roomNameTextField.text;
    if (roomName.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter room name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
//        
        [self createRoom:roomName];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - XMPPRoomDelegate
- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {
    [[RoomChatRepository sharedInstance] addRoom:room];
    if ([delegate respondsToSelector:@selector(roomCreated:)]) {
        [delegate roomCreated:room.roomJID];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Create room fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    [room fetchConfigurationForm];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    [room configureRoomUsingOptions:nil];
}

#pragma mark - Private methods
- (void)createRoom:(NSString *)roomName {
    XMPPJID *roomJID = [XMPPJID jidWithUser:roomName domain:xmppConferenceHostName resource:nil];
    
    XMPPStream *xmppStream = [[XMPPHandler sharedInstance] xmppStream];
    XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage = [[XMPPHandler sharedInstance] xmppRoomCoreDataStore];
    room = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomCoreDataStorage jid:roomJID];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room activate:xmppStream];
    [room joinRoomUsingNickname:[XMPPUtil myUsername] history:nil];
    //[room fetchConfigurationForm];
}
@end
