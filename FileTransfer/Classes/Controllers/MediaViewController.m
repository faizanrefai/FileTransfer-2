//
//  MediaViewController.m
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import "MediaViewController.h"
#import "ListFileViewCell.h"
#import "FileTransferMessage.h"
#import "AppConstants.h"
#import "AppDelegate.h"
#import "ImageDetailViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define PADDING 20
#define CELL_HEIGH 70
#define NUMBER_IMAGE_IN_ROW 4

@interface MediaViewController ()
- (void)configureTabBarItem;
- (NSFetchedResultsController *)fileFetchedResultController;
- (NSArray *)messagesAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MediaViewController
@synthesize tableView;


-(id)init {
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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.title = @"Media";
    
    [self testPhoneNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fileFetchedResultController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSInteger result = 0;
    NSArray *sections = [[self fileFetchedResultController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		result = (NSInteger)((float)sectionInfo.numberOfObjects/NUMBER_IMAGE_IN_ROW + 0.5);
	}
	
	return result;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fileFetchedResultController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
        return sectionInfo.name;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentify = @"Cell";
    
    ListFileViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[ListFileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    cell.fileMessages = [self messagesAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *ar = [self messagesAtIndexPath:indexPath];
    NSString *url  = [[ar objectAtIndex:indexPath.row]valueForKey:@"url"];
   // NSURL *url = [urlArray objectAtIndex:indexPath.row];
    NSData *data = [NSData dataWithContentsOfFile:url];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        ImageDetailViewController *imageDetailViewController = [[ImageDetailViewController alloc] initWithImage:image];
        [[self navigationController] pushViewController:imageDetailViewController animated:YES];
    }
    else {
    }
}

#pragma mark - IBAction methods

#pragma mark - FetchedReusltControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] reloadData];
}

#pragma mark - Private methods
- (NSFetchedResultsController *)fileFetchedResultController {
    if (fileFetchedResultController == nil) {
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        //Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FileTransferMessage" inManagedObjectContext:context];
        
        //Sort array
        NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"nickname" ascending:YES];
        NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES];

        NSArray *sorts = [NSArray arrayWithObjects:nameSort, timeSort, nil];
        
        //Pridicate
        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ AND fromMe=0", streamBarJid];
        
        
        //Fetch request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setSortDescriptors:sorts];
        [request setPredicate:predicate];
        
        //Fetch result controller
        fileFetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"nickname" cacheName:nil];
        
        
        [fileFetchedResultController setDelegate:self];
        
        NSError *error = nil;
		if (![fileFetchedResultController performFetch:&error])
		{
		}
    }
    
    return fileFetchedResultController;
}

- (NSArray *)messagesAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    NSArray *sections = [[self fileFetchedResultController] sections];
	if (indexPath.section < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:indexPath.section];
        
        int max = indexPath.row*NUMBER_IMAGE_IN_ROW + NUMBER_IMAGE_IN_ROW;
        
        if (sectionInfo.numberOfObjects/NUMBER_IMAGE_IN_ROW == indexPath.row) {
            max = sectionInfo.numberOfObjects;
        }
        
        for (int index=indexPath.row*NUMBER_IMAGE_IN_ROW; index < max; index++) {
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
            FileTransferMessage *message = [[self fileFetchedResultController] objectAtIndexPath:realIndexPath];
            [messages addObject:message];
        }
        
		//return (NSInteger)((float)sectionInfo.numberOfObjects/NUMBER_IMAGE_IN_ROW + 0.5);
	}
    
    return messages;
    
}

#pragma mark - private methods
- (void)configureTabBarItem {
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Media" image:nil tag:0];
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"media_icon_green.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"media_icon_gray.png"]];
    
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               nil] forState:UIControlStateNormal];
    
    UIColor *selectedColor = [UIColor colorWithRed: (float)71/255 green: (float)156/255 blue: (float)63/255 alpha:1.0];
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               selectedColor, UITextAttributeTextColor,
                                               nil] forState:UIControlStateSelected];
}

- (void)testPhoneNumber {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    for( int i = 0 ; i < n ; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        ABMultiValueRef *phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, i);
            NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel1 = ABMultiValueCopyLabelAtIndex(phones, j);
            NSString *phoneLabel1 =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            //CFRelease(phones);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            CFRelease(phoneNumberRef);
            CFRelease(locLabel);
            NSLog(@"  - %@ (%@)", phoneNumber, phoneLabel);
        }    }
}
@end
