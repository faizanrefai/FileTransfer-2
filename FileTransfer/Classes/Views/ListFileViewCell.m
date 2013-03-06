//
//  ListFileViewCell.m
//  FileTransfer
//
//  Created by Admin on 1/11/13.
//
//

#import "ListFileViewCell.h"
#import "FileTransferMessage.h"

#define CELL_HEIGH 70
#define MARGIN 16
#define IMAGE_HEIGH 60

@interface ListFileViewCell ()
- (void)createImageViews;
- (void)layoutImageViews;
@end

@implementation ListFileViewCell
@synthesize fileMessages;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createImageViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFileMessages:(NSArray *)array {
    fileMessages = array;
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutImageViews];
}

#pragma mark - Private methods
- (void)createImageViews {
    CGFloat index = 1;
    CGFloat x = 0;
    CGFloat y = 5;
    CGRect frame;
    
    //Imageview1
    imageView1 = [[UIImageView alloc] init];
    imageView2 = [[UIImageView alloc] init];
    imageView3 = [[UIImageView alloc] init];
    imageView4 = [[UIImageView alloc] init];
    
    imageViews = [NSArray arrayWithObjects:imageView1, imageView2, imageView3, imageView4, nil];
    
    
    //Create image views
    for (UIImageView  *imageView in imageViews) {
        x = index*MARGIN + (index - 1)*IMAGE_HEIGH;
        frame = CGRectMake(x, y, IMAGE_HEIGH, IMAGE_HEIGH);
        imageView.frame = frame;
        [[self contentView] addSubview:imageView];
        index ++;
    }
}

- (void)layoutImageViews {
    for (int index=0; index < fileMessages.count; index++) {
        //Add iamge to UIImage view
        FileTransferMessage *message = [fileMessages objectAtIndex:index];
        NSString *filePath = message.url;
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        //Add image to imageView or hide image view.
        UIImageView *imageView = [imageViews objectAtIndex:index];
        if (image) {
            [imageView setImage:image];
        }
        else {
            [imageView setHidden:YES];
        }
    }
    
    //Hide image views have no image.
    for (int index = 0; index<imageViews.count; index++) {
        UIImageView *imageView = [imageViews objectAtIndex:index];
        if (index < fileMessages.count) {
            [imageView setHidden:NO];
        }
        else {
            [imageView setHidden:YES];
        }    
    }
}
@end
