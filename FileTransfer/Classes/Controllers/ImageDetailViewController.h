//
//  ImageDetailViewController.h
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import <UIKit/UIKit.h>

@interface ImageDetailViewController : UIViewController {
    UIImage *image;
}
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (id)initWithImage:(UIImage *)image;

- (IBAction)backAction:(id)sender;
@end
