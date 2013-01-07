//
//  CallViewController.m
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import "CallViewController.h"

@interface CallViewController ()
- (void)configureTabBarItem;
@end

@implementation CallViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)configureTabBarItem {
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Call" image:nil tag:0];
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"call_icon_green.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"call_icon_gray.png"]];
    
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               nil] forState:UIControlStateNormal];
    
    UIColor *selectedColor = [UIColor colorWithRed: (float)71/255 green: (float)156/255 blue: (float)63/255 alpha:1.0];
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               selectedColor, UITextAttributeTextColor,
                                               nil] forState:UIControlStateSelected];
}


@end
