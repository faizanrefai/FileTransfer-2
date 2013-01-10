//
//  OneToOneChatViewCell.m
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OneToOneChatViewCell.h"
#import "UIImage+Scale.h"
#import "XMPPHandler.h"

#define AVARTA_HEIGHT 55
#define PADDING 50
#define MARGIN 5
#define MESSAGE_FONT 14
#define TIME_FONT 10
#define MIN_WIDTH 211
#define MIN_HEIGH 55

@interface OneToOneChatViewCell ()
- (void)configureAvatar;

@end

@implementation OneToOneChatViewCell
@synthesize chatMessage = chatMessage_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {                                                                                                                                                                                                                                                                                                                                                                               
        // Initialization code
        
        //avartaButton = [[EGOImageButton alloc] initWithPlaceholderImage:[UIImage imageNamed:kDefaultUserThumbnail]];        
        messageButton = [[UIButton alloc]init];
        messageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [[self contentView] addSubview:messageButton];
        
        messageLabel = [[UILabel alloc] init];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setFont:[UIFont systemFontOfSize:MESSAGE_FONT]];
        [messageLabel setTextAlignment:UITextAlignmentLeft];
        [messageLabel setLineBreakMode:UILineBreakModeWordWrap];
        [messageLabel setNumberOfLines:0];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [[self contentView] addSubview:messageLabel];
        
        
        inCommingChatImage = [[UIImage imageNamed:@"chat_box_left.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:17];
        
        
        outGoingChatImage = [[UIImage imageNamed:@"chat_box_right.png"] 
                              stretchableImageWithLeftCapWidth:20 topCapHeight:17];
        
        timeLabel = [[UILabel alloc] init];
        [timeLabel setFont:[UIFont systemFontOfSize:TIME_FONT]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [[self contentView] addSubview:timeLabel];
        
        //Avatar
        avartar = [[UIImageView alloc] init];
        [[self contentView] addSubview:avartar];
        [avartar setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark -
#pragma mark - Override methods
- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{

}

#pragma -
#pragma mark - Override methods
- (void)setChatMessage:(XMPPMessageOneToOneChat *)chatMessage {
    chatMessage_ = chatMessage;
    [self layoutViews:[self.chatMessage body]];
}

#pragma mark - Public methods
+ (CGFloat)heightForCellWithText:(NSString *)text {
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT] constrainedToSize:CGSizeMake(320 - AVARTA_HEIGHT - PADDING - 2*MARGIN, 480) lineBreakMode:UILineBreakModeWordWrap ];
    
    CGFloat height = MAX(size.height + 2*MARGIN, MIN_HEIGH + 2*MARGIN);
    
    
    return height;
}

#pragma -
#pragma mark - Private methods
- (void)initValues {
    if ([[self.chatMessage fromMe] boolValue]) {
        isMe = YES;
    }
    else {
        isMe = NO;
    }
}

- (void)layoutViews:(NSString *)message {
    CGFloat cellWidth = 320.0;
    CGFloat cellHeight = [OneToOneChatViewCell heightForCellWithText:message];
    
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT] constrainedToSize:CGSizeMake(cellWidth - AVARTA_HEIGHT - PADDING - 2*MARGIN, 480) lineBreakMode:UILineBreakModeWordWrap ];
    
    CGFloat width = MAX(size.width + 25, MIN_WIDTH);
    CGFloat height = MAX(size.height + MARGIN, MIN_HEIGH);
    UIImage *chatImage;
    
    //CGRect avartaFrame;
    
    if ([[self.chatMessage fromMe] boolValue]) {
        CGFloat x = 0;
        CGFloat y = 0;
        
        x = cellWidth - MARGIN*2 - AVARTA_HEIGHT;
        y = cellHeight - MARGIN - height;
        
        //Avatar image
        CGRect avartarFrame = CGRectMake(x, 5, AVARTA_HEIGHT, AVARTA_HEIGHT);
        avartar.frame = avartarFrame;
        //[avartar setImage:[UIImage imageNamed:@"defaultPerson.png"]];
        

        x -= (width + 10);
        //Set frame for message button
        CGRect frame = CGRectMake(x, y, width, height);
        messageButton.frame = frame;
        
        chatImage = [outGoingChatImage scaleToSize:CGSizeMake(width, height)];
        [messageButton setImage:chatImage forState:UIControlStateNormal];   
        
        //set lable frame
        CGRect lableFrame = CGRectMake(x + 8, y + 1, width - 20, height - MARGIN);
        [messageLabel setText:message];
        messageLabel.frame = lableFrame;
    }
    else {
        CGFloat x = 0;
        CGFloat y = 0;

        x = MARGIN;
        y = cellHeight - MARGIN - height;
    
    
        //Avatar
        //Avatar image
        CGRect avartarFrame = CGRectMake(x, 5, AVARTA_HEIGHT, AVARTA_HEIGHT);
        avartar.frame = avartarFrame;
        //[avartar setImage:[UIImage imageNamed:@"defaultPerson.png"]];
        
        x += AVARTA_HEIGHT;
        //Sert message button frame
        CGRect frame = CGRectMake(x, y, width, height);
        messageButton.frame = frame;
        
        //User in chat room
        
        chatImage = [inCommingChatImage scaleToSize:CGSizeMake(width, height)];
        [messageButton setImage:chatImage  forState:UIControlStateNormal];
        
        //set lable frame
        CGRect lableFrame = CGRectMake(x + 15, y + 1, width - 20, height - MARGIN);
        [messageLabel setText:message];
        messageLabel.frame = lableFrame;
    }
    
    [self configureAvatar];
}


//- (void)layoutViews:(NSString *)message {
//    CGFloat cellWidth = 320.0;
//    CGFloat cellHeight = [OneToOneChatViewCell heightForCellWithText:message];
//    
//    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT] constrainedToSize:CGSizeMake(cellWidth - AVARTA_HEIGHT - PADDING - 2*MARGIN, 480) lineBreakMode:UILineBreakModeWordWrap ];
//    
//    CGFloat width = MAX(size.width + 25, MIN_WIDTH);
//    CGFloat height = MAX(size.height + 2*MARGIN, 35);
//    UIImage *chatImage;
//    
//    //CGRect avartaFrame;
//    
//    if ([[self.chatMessage fromMe] boolValue]) {
//        CGFloat x = 0;
//        CGFloat y = 0;
//        
//        
//        x = cellWidth - MARGIN - width;
//        y = cellHeight - MARGIN - height;
//        
//        
//        //Set frame for message button
//        CGRect frame = CGRectMake(x, y, width, height);
//        messageButton.frame = frame;
//        
//        chatImage = [outGoingChatImage scaleToSize:CGSizeMake(width, height)];
//        [messageButton setImage:chatImage forState:UIControlStateNormal];
//        
//        //set lable frame
//        CGRect lableFrame = CGRectMake(x + 8, y + 1, width - 20, height - MARGIN);
//        [messageLabel setText:message];
//        messageLabel.frame = lableFrame;
//    }
//    else {
//        CGFloat x = 0;
//        CGFloat y = 0;
//        
//        x = MARGIN;
//        y = cellHeight - MARGIN - height;
//        
//        
//        //Sert message button frame
//        CGRect frame = CGRectMake(x, y, width, height);
//        messageButton.frame = frame;
//        
//        //User in chat room
//        
//        chatImage = [inCommingChatImage scaleToSize:CGSizeMake(width, height)];
//        [messageButton setImage:chatImage  forState:UIControlStateNormal];
//        
//        //set lable frame
//        CGRect lableFrame = CGRectMake(x + 10, y + 1, width - 20, height - MARGIN);
//        [messageLabel setText:message];
//        messageLabel.frame = lableFrame;
//    }
//    //set frame for time label
//    //CGRect timeFrame = CGRectMake(avartaFrame.origin.x, avartaFrame.origin.y - timeStampSize.height, timeStampSize.width, timeStampSize.height);
//    //timeLabel.frame = timeFrame;
//    
//}

#pragma mark - Private methods
- (void)configureAvatar {
    NSData *photoData = [[[XMPPHandler sharedInstance] xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:chatMessage_.jidStr]];
    
    if (photoData != nil)
        avartar.image = [UIImage imageWithData:photoData];
    else
        avartar.image = [UIImage imageNamed:@"defaultPerson.png"];
}
@end
