//
//  SettingsViewController.m
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import "SettingsViewController.h"
#import "XMPPHandler.h"
#import "XMPPUtil.h"
#import "UIImage+Scale.h"

@interface SettingsViewController ()
- (void)configureTabBarItem;
- (void)showAvatar;
- (void)updateAvatar:(UIImage *)avatar;
@end

@implementation SettingsViewController
@synthesize avatarImageView;

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
    [self showAvatar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [imagePickerController setAllowsEditing:YES];
    //Check Camera available or not
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    //Check PhotoLibrary available or not
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentModalViewController:imagePickerController animated:YES];
    //Check front Camera available or not

}

#pragma mark -
#pragma mark - UIImagePickerController delegate
//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //Show OriginalImage size
    avatarImageView.image = originalImage;
    [self updateAvatar:[originalImage scaleToSize:CGSizeMake(60.0, 60.0)]];
    [self dismissModalViewControllerAnimated:YES];
    
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

//Tells the delegate that the user picked an image. (Deprecated in iOS 3.0. Use imagePickerController:didFinishPickingMediaWithInfo: instead.)
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
}


#pragma mark - private methods
- (void)configureTabBarItem {
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:0];
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"settings_icon_green.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"settings_icon_gray.png"]];
    
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               nil] forState:UIControlStateNormal];
    
    UIColor *selectedColor = [UIColor colorWithRed: (float)71/255 green: (float)156/255 blue: (float)63/255 alpha:1.0];
    [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               selectedColor, UITextAttributeTextColor,
                                               nil] forState:UIControlStateSelected];
}

- (void)showAvatar {
    NSData *photoData = [[[XMPPHandler sharedInstance] xmppvCardAvatarModule] photoDataForJID:[XMPPUtil myBareJID]];
    avatarImageView.image = [UIImage imageWithData:photoData];
    
}

- (void)updateAvatar:(UIImage *)avatar {
    NSData *imageData = UIImagePNGRepresentation(avatar);
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        XMPPvCardTempModule *vCardTempModule = [[XMPPHandler sharedInstance] xmppvCardTempModule];
        XMPPvCardTemp *myVcardTemp = [vCardTempModule myvCardTemp];
        
        [myVcardTemp setPhoto:imageData];
        [vCardTempModule updateMyvCardTemp:myVcardTemp];
    });
}
@end
