//
//  ImageDetailViewController.m
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import "ImageDetailViewController.h"

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController
@synthesize imageView;

- (id)initWithImage:(UIImage *)inputImage {
    self = [super init];
    if (self) {
        image = inputImage;
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
    imageView.image = image;
    self.title = @"Image";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
