//
//  CurrentOneToOneChatViewController.m
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import "CurrentOneToOneChatViewController.h"
#import "XMPPHandler.h"
#import "AppConstants.h"
#import "AppDelegate.h"
#import "XMPPMessageOneToOneChat.h"
#import "CurrentOneToOneChatCell.h"
#import "XMPPRosterCoreDataStorage.h"
#import "OneToOneChatViewController.h"

#define CELL_HEIGH 65

@interface CurrentOneToOneChatViewController ()
- (void)configureTabBarItem;
- (NSFetchedResultsController *)fetchedResultsController;
- (NSArray *)currentChatJids;
- (XMPPMessageOneToOneChat *)lastMessage:(NSString *)jidStr;
- (void)insertedOneToOneMessage:(NSNotification *)notification;
@end

@implementation CurrentOneToOneChatViewController
@synthesize mainTableView;

- (id)init {
    self = [super init];
    if (self) {
        [self configureTabBarItem];
    }
    return self;
}

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
    lastMessages = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertedOneToOneMessage:) name:insertedOneToOneMessage object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)logoutAction:(id)sender {
    [[XMPPHandler sharedInstance] logout];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGH;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[lastMessages allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CurrentOneToOneChatCell";
    CurrentOneToOneChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CurrentOneToOneChatCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
        //cell = [[CurrentOneToOneChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    NSString *key = [[lastMessages allKeys] objectAtIndex:indexPath.row];
    XMPPMessageOneToOneChat *message = [lastMessages objectForKey:key];
    cell.message = message;
    
    return cell;
}

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
    NSString *key = [[lastMessages allKeys] objectAtIndex:indexPath.row];
    XMPPMessageOneToOneChat *message = [lastMessages objectForKey:key];
    XMPPHandler *xmppHandler = [XMPPHandler sharedInstance];
    XMPPUserCoreDataStorageObject *user = [xmppHandler.xmppRosterStorage userForJID:[XMPPJID jidWithString:message.jidStr] xmppStream:[xmppHandler xmppStream] managedObjectContext:xmppHandler.managedObjectContext_roster];
    
    OneToOneChatViewController *oneToOneChatViewController = [[OneToOneChatViewController alloc] init];
    oneToOneChatViewController.user = user;
    [[self navigationController] pushViewController:oneToOneChatViewController animated:YES];
}

#pragma mark - NSFetchResultController delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//- (NSFetchedResultsController *)fetchedResultsController
//{
//	if (fetchedResultController == nil)
//	{
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//		NSManagedObjectContext *moc = appDelegate.managedObjectContext;
//		
//		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageOneToOneChat"
//		                                          inManagedObjectContext:moc];
//		
//		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
//		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
//		
//		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//		[fetchRequest setEntity:entity];
//		[fetchRequest setSortDescriptors:sortDescriptors];
//		[fetchRequest setFetchBatchSize:10];
//        [fetchRequest setReturnsDistinctResults:YES];
//        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"jidStr", nil]];
//        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ ", streamBarJid];
//        [fetchRequest setPredicate:predicate];
//		
//		fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                                                                  managedObjectContext:moc
//                                                                                    sectionNameKeyPath:nil
//                                                                                             cacheName:nil];
//		[fetchedResultController setDelegate:self];
//		
//		
//		NSError *error = nil;
//		if (![fetchedResultController performFetch:&error])
//		{
//		}
//        
//	}
//	
//	return fetchedResultController;
//}
//
//- (NSFetchedResultsController *)messageFetchedResultsController
//{
//	if (messageFetchedResultController == nil)
//	{
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//		NSManagedObjectContext *moc = appDelegate.managedObjectContext;
//		
//		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageOneToOneChat"
//		                                          inManagedObjectContext:moc];
//		
//		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
//		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
//		
//		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//		[fetchRequest setEntity:entity];
//		[fetchRequest setSortDescriptors:sortDescriptors];
//		[fetchRequest setFetchBatchSize:10];
//        
//        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ ", streamBarJid];
//        [fetchRequest setPredicate:predicate];
//		
//		messageFetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                                                      managedObjectContext:moc
//                                                                        sectionNameKeyPath:nil
//                                                                                 cacheName:nil];
//		[messageFetchedResultController setDelegate:self];
//		
//		
//		NSError *error = nil;
//		if (![messageFetchedResultController performFetch:&error])
//		{
//		}
//        
//	}
//	
//	return messageFetchedResultController;
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    
//    //[self.mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    [mainTableView reloadData];
//}

#pragma mark - private methods
- (void)configureTabBarItem {
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chat" image:nil tag:0];
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"chat_icon_green.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"chat_icon_gray.png"]];
    
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               nil] forState:UIControlStateNormal];
    
    UIColor *selectedColor = [UIColor colorWithRed: (float)71/255 green: (float)156/255 blue: (float)63/255 alpha:1.0];
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               selectedColor, UITextAttributeTextColor,
                                               nil] forState:UIControlStateSelected];
}
//
//- (NSArray *)currentChatJids {
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageOneToOneChat"
//                                              inManagedObjectContext:moc];
//    
//    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entity];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"jidStr"]]];
//    [fetchRequest setReturnsDistinctResults:YES];
//    fetchRequest.resultType = NSDictionaryResultType;
//    
//    NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ ", streamBarJid];
//    [fetchRequest setPredicate:predicate];
//    NSArray *items = [moc executeFetchRequest:fetchRequest error:nil];
//    return items;
//}
//
- (void)insertedOneToOneMessage:(NSNotification *)notification {
    XMPPMessageOneToOneChat *message = (XMPPMessageOneToOneChat *)notification.object;
    [lastMessages setObject:message forKey:message.jidStr];
    [mainTableView reloadData];
}
@end
