//
//  AccoutViewController.m
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import "AccountsViewController.h"
#import "AppConstants.h"
#import "XMPPHandler.h"
#import "AddAccountViewController.h"
#import "EnumTypes.h"
#import "KeychainUtil.h"

@interface AccountsViewController ()
- (UIBarButtonItem *)createLogoutButton;
- (void)logoutAction;
- (void)configUITableViewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation AccountsViewController
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
    
    self.title = @"Accounts";
    //Add logout button
    UIBarButtonItem *logoutButton = [self createLogoutButton];
    self.navigationItem.rightBarButtonItem = logoutButton;    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITaleView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"CellIdentify";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    
    [self configUITableViewCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddAccountViewController *addAccountViewController = [[AddAccountViewController alloc] init];
    //Yahoo account
    if (indexPath.row == 0) {
        addAccountViewController.accountType = yahooAccountType;
    }
    //MSN accout
    else if (indexPath.row == 1) {
        addAccountViewController.accountType = msnAccountType;
    }
    [self.navigationController pushViewController:addAccountViewController animated:YES];
}

#pragma mark - Private methods
- (UIBarButtonItem *)createLogoutButton {
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutAction)];
    return logoutButton;
}

- (void)logoutAction {
    [[XMPPHandler sharedInstance] logout];
    [self.navigationController popViewControllerAnimated:YES];
    if ([delegate respondsToSelector:@selector(didXMPPLogOut)]) {
        [delegate didXMPPLogOut];
    }
}

- (void)configUITableViewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSString *username = @"";
    NSString *keychainString = nil;
    
    //Yahoo account
    if (indexPath.row == 0) {
        keychainString = kYahooPasswordKeychainIdentify;
        cell.imageView.image = [UIImage imageNamed:@"yahoo-icon.png"];
        
    }
    //MSN accout
    else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"msn-icon.png"];
        keychainString = kMSNPasswordKeychainIdentify;
    }
    
    
    if (keychainString) {
        username = [KeychainUtil attrAccountForKeychainWithKey:keychainString];
    }
    cell.textLabel.text = username;
}
@end

