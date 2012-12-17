//
//  FileTransferViewCell.m
//  FileTransfer
//
//  Created by Admin on 12/14/12.
//
//

#import "FileTransferViewCell.h"
#import "XMPPRoomFileTransferMessageCoreDataStorageObject.h"
#import "DirectoryHelper.h"
#import "XMPPUtil.h"

#define IMAGE_HEIGH 90

@interface FileTransferViewCell ()

@end

@implementation FileTransferViewCell
@synthesize progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        //File image view
        fileImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:fileImageView];

        
        //Indicator view
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:indicatorView];
        //
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        [self.contentView addSubview:progressView];

        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForCellWithText:(NSString *)text {
    return [super heightForCellWithText:text] + IMAGE_HEIGH + 19;
}
#pragma mark - Override methods
//- (void)setMessage:(XMPPRoomFileTransferMessageCoreDataStorageObject *)aMessage {
//    [super setMessage:message];
//    [self layoutIfNeeded];
//}

#pragma mark - Private methods
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heigh = [ChatViewCell heightForCellWithText:[(XMPPRoomFileTransferMessageCoreDataStorageObject *)self.message body]];
    
    [fileImageView setFrame:CGRectMake(115, heigh, IMAGE_HEIGH, IMAGE_HEIGH)];
    [indicatorView setFrame:CGRectMake(142, heigh + 26, 37, 37)];
    [progressView setFrame:CGRectMake(115, heigh + IMAGE_HEIGH + 5, IMAGE_HEIGH, 9)];
    
    //Add image
    NSString *fileName = [(XMPPRoomFileTransferMessageCoreDataStorageObject *)self.message fileName];
    
    NSString *path = [DirectoryHelper savedFilesDirectory];
    if ([[[(XMPPRoomFileTransferMessageCoreDataStorageObject *)self.message jid] resource] isEqualToString:[XMPPUtil myUsername]]) {
        path = [DirectoryHelper sentFilesDirectory];
    }

    path = [path stringByAppendingPathComponent:fileName];
    NSData *data = nil;
    if ([DirectoryHelper fileExistAtPath:path isDir:NO]) {
        data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        fileImageView.image = image;
        [indicatorView stopAnimating];
        progressView.hidden= YES;
    }
    else {
        fileImageView.image = nil;
        [indicatorView startAnimating];
        progressView.hidden= NO;
    }
}

@end
