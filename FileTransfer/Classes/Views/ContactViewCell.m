//
//  ContactViewCell.m
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import "ContactViewCell.h"

@implementation ContactViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(20, 5, 22, 22);
    CGRect textFrame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(52, textFrame.origin.y, textFrame.size.width, textFrame.size.height);
}

@end
