//
//  FileTransferCell.h
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import <UIKit/UIKit.h>
#import "FileTransferMessage.h"

@interface FileTransferCell : UITableViewCell {
    UIImageView *imageView;
    UILabel *fileNameLabel;
    UILabel *statusLabel;
}

@property (nonatomic, strong) FileTransferMessage *message;

@end
