//
//  UsersViewController.m
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import "SelectUserViewController.h"

@interface SelectUserViewController ()

@end

@implementation SelectUserViewController
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
    self.title = @"Invite User";
    
    //Add invite button
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    if (indexSelected == nil) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    else if (((indexPath.section == indexSelected.section) && (indexPath.row == indexSelected.row))) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];

    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexSelected == nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        indexSelected = indexPath;   
    }
    else if (!((indexPath.section == indexSelected.section) && (indexPath.row == indexSelected.row))) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        if (indexSelected >= 0) {
            UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:indexSelected];
            [lastCell setAccessoryType:UITableViewCellAccessoryNone];
        }
        indexSelected = indexPath;        
    }
}

#pragma mark - IBAction methods
- (IBAction)cancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)inviteAction:(id)sender {
    if (indexSelected >= 0) {
        XMPPUserCoreDataStorageObject *user = [[fetchedResultsController fetchedObjects] objectAtIndex:indexSelected.row];
        if ([delegate respondsToSelector:@selector(didSelectUser:)]) {
            [delegate didSelectUser:user];
        }
    }
}
@end
