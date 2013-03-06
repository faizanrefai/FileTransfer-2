//
//  ListFileViewCell.h
//  FileTransfer
//
//  Created by Admin on 1/11/13.
//
//

#import <UIKit/UIKit.h>

@interface ListFileViewCell : UITableViewCell {
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
    
    NSArray *imageViews;
}

@property (nonatomic, strong) NSArray *fileMessages;
@end
