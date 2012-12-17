//
//  FileTransferCell.h
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import <UIKit/UIKit.h>
#import "FileTransferMessage.h"

@interface OneToOneFileTransferCell : UITableViewCell {
    UIImageView *imageView;
    UILabel *fileNameLabel;
    UIProgressView *progressView;
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, strong) FileTransferMessage *message;
@property (nonatomic, strong) UIProgressView *progressView;

@end
