//
//  UsersViewController.m
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import "SelectUserViewController.h"

@interface SelectUserViewController ()
- (BOOL)rowAtIndexPathSelected:(NSIndexPath *)indexPath;
- (void)removeSelectedRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation SelectUserViewController
@synthesize delegate;
@synthesize multiSelect;
@synthesize usersSelected;

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
    self.title = @"Select User";
    
    
    //Add invite button
	// Do any additional setup after loading the view.
    if (rowsSelected == nil) {
        rowsSelected = [[NSMutableArray alloc] init];
    }
    
    self.multiSelect = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.fetchedResultsController setDelegate:nil];
}

#pragma mark - 
#pragma mark - Override methods
- (void)setUsersSelected:(NSArray *)jids {
    usersSelected = jids;
    
    if (rowsSelected == nil) {
        rowsSelected = [[NSMutableArray alloc] init];
    }
    
    NSArray *userList = [self.fetchedResultsController fetchedObjects];
    for (XMPPUserCoreDataStorageObject *user in userList) {
        for (NSString *jid in usersSelected) {
            if ([jid isEqualToString:user.jidStr]) {
                NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:user];
                [rowsSelected addObject:indexPath];
            }
        }
    }
}

#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    if ([self rowAtIndexPathSelected:indexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.multiSelect) {
        if ([self rowAtIndexPathSelected:indexPath]) {
            [self removeSelectedRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else {
            [rowsSelected addObject:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else {
        if ([self rowAtIndexPathSelected:indexPath]) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [rowsSelected removeAllObjects];
        }
        else {
            //Set last selected cell to none type
            if (rowsSelected.count == 1) {
                NSIndexPath *lastIndexPath = [rowsSelected objectAtIndex:0];
                UITableViewCell *lastSelectedCell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
                [lastSelectedCell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            [rowsSelected removeAllObjects];
            [rowsSelected addObject:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            
            
        }
        
    }
//    
//    if (indexSelected == nil) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//        indexSelected = indexPath;   
//    }
//    else if (!((indexPath.section == indexSelected.section) && (indexPath.row == indexSelected.row))) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//        
//        if (indexSelected >= 0) {
//            UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:indexSelected];
//            [lastCell setAccessoryType:UITableViewCellAccessoryNone];
//        }
//        indexSelected = indexPath;        
//    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	//[[self tableView] reloadData];
}

#pragma mark - IBAction methods
- (IBAction)cancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)inviteAction:(id)sender {
    NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in rowsSelected) {
        XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [selectedUsers addObject:user];
    }
    if ([delegate respondsToSelector:@selector(didSelectUsers:)]) {
        [delegate didSelectUsers:selectedUsers];
    }
}

#pragma mark - Private methods
- (BOOL)rowAtIndexPathSelected:(NSIndexPath *)indexPath {
    BOOL result = NO;
    for (NSIndexPath *selectedIndex in rowsSelected) {
        if (((indexPath.section == selectedIndex.section) && (indexPath.row == selectedIndex.row))) {
            result = YES;
            break;
        }
    }
    return result;
}

- (void)removeSelectedRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *indexPathTmp;
    for (NSIndexPath *selectedIndex in rowsSelected) {
        if (((indexPath.section == selectedIndex.section) && (indexPath.row == selectedIndex.row))) {
            indexPathTmp = selectedIndex;
            break;
        }
    }
    if (indexPathTmp) {
        [rowsSelected removeObject:indexPathTmp];
    }
}
@end
