//
//  OccupantsViewController.m
//  FileTransfer
//
//  Created by Admin on 11/30/12.
//
//

#import "OccupantsViewController.h"

@interface OccupantsViewController ()
- (BOOL)rowAtIndexPathSelected:(NSIndexPath *)indexPath;
- (void)removeSelectedRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation OccupantsViewController
@synthesize currentOccupantsSelected;
@synthesize delegate;
@synthesize tableView;
@synthesize occupants;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (rowsSelected == nil) {
        rowsSelected = [[NSMutableArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Override methods
#pragma mark -
#pragma mark - Override methods
- (void)setUsersSelected:(NSArray *)selectedOccupants {
    currentOccupantsSelected = selectedOccupants;
    
    if (rowsSelected == nil) {
        rowsSelected = [[NSMutableArray alloc] init];
    }
    
    for (RoomOccupant *selectedOccupant in selectedOccupants) {
        for (RoomOccupant *occupant in occupants) {
            if ([selectedOccupant.realJidStr isEqualToString:occupant.realJidStr]) {
                NSInteger index = [occupants indexOfObject:occupant];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [rowsSelected addObject:indexPath];
            }
        }
    }
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
    return occupants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([self rowAtIndexPathSelected:indexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    RoomOccupant *occupant = [occupants objectAtIndex:indexPath.row];
    cell.textLabel.text = occupant.nickname;    
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
}

#pragma mark -
#pragma mark - IBAction methods
- (IBAction)cancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)inviteAction:(id)sender {
    NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in rowsSelected) {
        RoomOccupant *occupant = [occupants objectAtIndex:indexPath.row];
        [selectedUsers addObject:occupant];
    }
    if ([delegate respondsToSelector:@selector(occupantsSelected:)]) {
        [delegate occupantsSelected:selectedUsers];
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
