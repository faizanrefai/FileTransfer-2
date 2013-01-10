//
//  FileTransferCell.m
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import "OneToOneFileTransferCell.h"
#import "DirectoryHelper.h"
#import "FileTransferController.h"
#import "EnumTypes.h"

@interface FileTransferMessage ()
- (void)layoutViews;
@end

@implementation OneToOneFileTransferCell
@synthesize message;
@synthesize progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        
        //
        fileNameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:fileNameLabel];
        [fileNameLabel setBackgroundColor:[UIColor clearColor]];
        
        //
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.contentView addSubview:progressView];
        
        //
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:indicatorView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Override methods
- (void)setMessage:(FileTransferMessage *)aMessage {
    message = aMessage;
    [self layoutViews];
}

#pragma mark - Private methods
- (void)layoutViews {
    [imageView setFrame:CGRectMake(5, 5, 60, 60)];
    [fileNameLabel setFrame:CGRectMake(70, 14, 206, 41)];
    [progressView setFrame:CGRectMake(105, 77, 205, 9)];
    [indicatorView setFrame:CGRectMake(32, 32, 37, 37)];
    
    //
    NSString *text;
    
    if (message.status.integerValue == kFileTransferStatusSending) {
        text = @"Sending ";
        NSString *path = [DirectoryHelper sentFilesDirectory];
        path = [path stringByAppendingPathComponent:message.fileName];
        
        
    }
    else if (message.status.integerValue == kFileTransferStatusReceiving) {
        text = @"Receiving ";
        [indicatorView startAnimating];
    }
    else if (message.status.integerValue == kFileTransferStatusSuccess) {
        progressView.hidden = YES;
        if (message.fromMe.boolValue) {
            text = @"Sent ";
            
        }
        else {
            text = @"Received ";
        }
        [indicatorView stopAnimating];
    }
    else if (message.status.integerValue == kFileTransferStatusFail) {
        if (message.fromMe.boolValue) {
            text = @"Send fail ";
        }
        else {
            text = @"Received fail";
        }
        [indicatorView stopAnimating];
    }
    else {
        progressView.hidden = NO;
    }
    text = [text stringByAppendingString:message.fileName];
    
    fileNameLabel.text = text;
    
    //Add image
    if (message.url) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:message.url]];
        UIImage *image = [UIImage imageWithData:data];
        imageView.image = image;
    }
    else {
        imageView.image = nil;
    }
    
    //
    [[FileTransferController sharedInstance] addProgressView:progressView forMessage:message];

}

@end
