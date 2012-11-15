//
//  RoomListViewController.m
//  FileTransfer
//
//  Created by Admin on 11/11/12.
//
//

#import "RoomListViewController.h"
#import "XMPPDiscoRoom.h"
#import "XMPPJID.h"
#import "AppConstants.h"
#import "RoomChatViewController.h"

@interface RoomListViewController ()
- (void)didGetRoomList:(NSNotification *)notification;
- (void)addNewRoom;
- (void)joinRoomWithJID:(XMPPJID *)jid;
@end

@implementation RoomListViewController
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Rooms";
    roomList = [[XMPPDiscoRoom sharedInstance] rooms];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRoomList:) name:xmppDidGetRoomList object:nil];
    
    UIBarButtonItem *addRoom = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewRoom)];
    [[self navigationItem] setRightBarButtonItem:addRoom];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[XMPPDiscoRoom sharedInstance] discoRoom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // Configure the cell...
    XMPPJID *jid = [roomList objectAtIndex:indexPath.row];
    cell.textLabel.text = jid.user;

    //NSLog(@"user: %@", jid.user);
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    XMPPJID *jid = [roomList objectAtIndex:indexPath.row];
    [self joinRoomWithJID:jid];
}

#pragma mark - NewRoomDelegate
- (void)roomCreated:(XMPPJID *)jid {
    [self dismissModalViewControllerAnimated:NO];
    [self joinRoomWithJID:jid];
}
- (void)createdRoomWithName:(NSString *)roomName {
}

#pragma mark - Private methods
- (void)didGetRoomList:(NSNotification *)notification {
    roomList = [[XMPPDiscoRoom sharedInstance] rooms];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

- (void)addNewRoom {
    NewRoomViewController *newRoomViewController = [[NewRoomViewController alloc] init];
    newRoomViewController.delegate = self;
    [self presentModalViewController:newRoomViewController animated:YES];
}

- (void)joinRoomWithJID:(XMPPJID *)jid {
    RoomChatViewController *roomChatViewController = [[RoomChatViewController alloc] initWithRoomJID:jid];
    [self.navigationController pushViewController:roomChatViewController animated:YES];
    
}

@end
