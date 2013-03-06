//
//  ListFilesViewController.m
//  FileTransfer
//
//  Created by Admin on 12/1/12.
//
//

#import "ListFilesViewController.h"
#import "ImageDetailViewController.h"
#import "AppDelegate.h"
#import "FileTransferMessage.h"
#import "AppConstants.h"
#import "ListFileViewCell.h"

#define PADDING 20
#define CELL_HEIGH 70
#define NUMBER_IMAGE_IN_ROW 4

@interface ListFilesViewController ()
- (NSFetchedResultsController *)fileFetchedResultController;
- (NSArray *)messagesAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ListFilesViewController
@synthesize urlArray;
@synthesize tableView;
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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.title = @"Media";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%d",[[self.fileFetchedResultController sections] count]);
    return [[self.fileFetchedResultController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSArray *sections = [[self fileFetchedResultController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return (NSInteger)((float)sectionInfo.numberOfObjects/NUMBER_IMAGE_IN_ROW + 0.5);
	}
	
	return 0;
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.fileMessages = [self messagesAtIndexPath:indexPath];    
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [urlArray objectAtIndex:indexPath.row];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        ImageDetailViewController *imageDetailViewController = [[ImageDetailViewController alloc] initWithImage:image];
        [[self navigationController] pushViewController:imageDetailViewController animated:YES];
    }
    else {
    }
}

#pragma mark - IBAction methods
- (IBAction)cancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectAction:(id)sender {
    if ([delegate respondsToSelector:@selector(didSelectFileURL:)]) {
        [delegate didSelectFileURL:nil];
    }
}

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
        NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"nickName" ascending:YES];
        NSArray *sorts = [NSArray arrayWithObjects:nameSort, nil];
        
        //Pridicate
        NSString *streamBarJid = [[NSUserDefaults standardUserDefaults] objectForKey:kStreamBareJIDString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ ", streamBarJid];
        
        
        //Fetch request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setSortDescriptors:sorts];
        [request setPredicate:predicate];
        
        //Fetch result controller
        fileFetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"nickName" cacheName:nil];
        
        [fileFetchedResultController setDelegate:self];
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
@end
