//
//  FileTransferViewCell.h
//  FileTransfer
//
//  Created by Admin on 12/14/12.
//
//

#import <UIKit/UIKit.h>
#import "ChatViewCell.h"

@interface FileTransferViewCell : ChatViewCell {
    UIImageView *fileImageView;
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, strong) UIProgressView *progressView;

@end
