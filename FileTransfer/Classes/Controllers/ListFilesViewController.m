//
//  ListFilesViewController.m
//  FileTransfer
//
//  Created by Admin on 12/1/12.
//
//

#import "ListFilesViewController.h"
#import "ImageDetailViewController.h"

@interface ListFilesViewController ()

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
    self.title = @"List Files";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return urlArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentify = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.minimumFontSize = 10.0;
    }
    
    NSURL *url = [urlArray objectAtIndex:indexPath.row];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        cell.imageView.image = image;
    }
    else {
        cell.imageView.image = nil;
    }
    
    NSString *fileName = url.lastPathComponent;
    cell.textLabel.text = fileName;
    
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

@end
