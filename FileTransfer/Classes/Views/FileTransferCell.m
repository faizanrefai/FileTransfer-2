//
//  FileTransferCell.m
//  FileTransfer
//
//  Created by Admin on 12/10/12.
//
//

#import "FileTransferCell.h"

@interface FileTransferMessage ()
- (void)layoutViews;
@end

@implementation FileTransferCell
@synthesize message;

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
        
        //
        statusLabel = [[UILabel alloc] init];
        [self.contentView addSubview:statusLabel];
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
    [imageView setFrame:CGRectMake(5, 5, 65, 65)];
    [fileNameLabel setFrame:CGRectMake(94, 29, 221, 21)];
    [statusLabel setFrame:CGRectMake(2, 76, 72, 21)];
    
    fileNameLabel.text = message.fileName;    
    //Add image
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:message.url]];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        imageView.image = image;
    }
    else {
        imageView.image = nil;
    }
    
    //Add text for status label
    if ([message.fromMe boolValue]) {
        statusLabel.text = @"Sent";
    }
    else {
        statusLabel.text = @"Received";
    }
    
}

@end
