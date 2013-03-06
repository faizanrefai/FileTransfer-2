//
//  SettingsViewController.h
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;

- (IBAction)takePicture:(id)sender;
@end
