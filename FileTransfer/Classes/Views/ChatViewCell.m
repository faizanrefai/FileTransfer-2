//
//  ChatViewCell.m
//  FileTransfer
//
//  Created by Admin on 11/12/12.
//
//

#import "ChatViewCell.h"
#import "XMPPMessageOneToOneChat.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "XMPPHandler.h"
#import "AppConstants.h"
#import "XMPPUtil.h"

#define PADDING 50
#define MARGIN 5
#define AVATAR_SIZE 25
#define MESSAGE_FONT_SIZE 14
#define TIME_FONT_SIZE 12
#define USER_FONT_SIZE 13
#define MESSAGE_WIDTH 250

@interface ChatViewCell ()
- (void)layoutSubviewsForOneToOneChat:(XMPPMessageOneToOneChat *)oneToOneMessage;
- (void)layoutSubviewsForMUCChat:(XMPPRoomMessageCoreDataStorageObject *)mucMesasge;
- (CGRect)frameForTextLabel:(NSString *)text;

- (void)layoutSubviewsWithUserJID:(XMPPJID *)userJID text:(NSString *)text time:(NSDate *)time fromMe:(BOOL)fromMe;
- (void)avatarForJID:(XMPPJID *)jid;
@end

@implementation ChatViewCell
@synthesize message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect avatarButtonFrame = CGRectMake(MARGIN, MARGIN, AVATAR_SIZE, AVATAR_SIZE);
        avatarButton.frame = avatarButtonFrame;
        [[self contentView] addSubview:avatarButton];
        
        //Add user label
        userLabel = [[UILabel alloc] init];
        [userLabel setBackgroundColor:[UIColor clearColor]];
        [userLabel setFont:[UIFont systemFontOfSize:USER_FONT_SIZE]];
        [userLabel setTextAlignment:UITextAlignmentLeft];
        [userLabel setLineBreakMode:UILineBreakModeWordWrap];
        [userLabel setNumberOfLines:0];
        [userLabel setTextColor:[UIColor grayColor]];
        CGRect userLabelFrame = CGRectMake(60, 0, 130, 20);
        userLabel.frame = userLabelFrame;
        [[self contentView] addSubview:userLabel];
        
        //Add time lael
        timeLabel = [[UILabel alloc] init];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:TIME_FONT_SIZE]];
        [timeLabel setTextAlignment:UITextAlignmentRight];
        [timeLabel setLineBreakMode:UILineBreakModeWordWrap];
        [timeLabel setNumberOfLines:0];
        CGRect timeLabelFrame = CGRectMake(220, 0, 90, 20);
        timeLabel.frame = timeLabelFrame;
        [timeLabel setTextColor:[UIColor grayColor]];
        [[self contentView] addSubview:timeLabel];
        
        //Add text label
        textLabel = [[UILabel alloc] init];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE]];
        [textLabel setTextAlignment:UITextAlignmentLeft];
        [textLabel setLineBreakMode:UILineBreakModeWordWrap];
        [textLabel setNumberOfLines:0];
        CGRect textLabelFrame = CGRectMake(60, 20, MESSAGE_WIDTH, 0);
        textLabel.frame = textLabelFrame;
        [[self contentView] addSubview:textLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Override methods
- (void)layoutSubviews {
    [super layoutSubviews];
    if ([message isKindOfClass:[XMPPMessageOneToOneChat class]]) {
        [self layoutSubviewsForOneToOneChat:(XMPPMessageOneToOneChat *)message];
    }
    else if ([message isKindOfClass:[XMPPRoomMessageCoreDataStorageObject class]]){
        [self layoutSubviewsForMUCChat:(XMPPRoomMessageCoreDataStorageObject *)message];
    }
    else {
        [self layoutSubviewsForMUCChat:(XMPPRoomMessageCoreDataStorageObject *)message];    
    }
}

- (void)setMessage:(NSManagedObject *)chatMessage {
    message = chatMessage;
    [self layoutIfNeeded];
}

#pragma mark - Public methods
+ (CGFloat)heightForCellWithText:(NSString *)text {
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE] constrainedToSize:CGSizeMake(MESSAGE_WIDTH, 480) lineBreakMode:UILineBreakModeWordWrap ];
    CGFloat result = size.height + 25;
    return result;
}

#pragma mark - Private methods
- (void)layoutSubviewsForOneToOneChat:(XMPPMessageOneToOneChat *)oneToOneMessage {
    NSString *text = oneToOneMessage.body;
    NSDate *time = oneToOneMessage.localTimestamp;
    BOOL fromMe = [oneToOneMessage.fromMe boolValue];
    if (fromMe) {
        [self layoutSubviewsWithUserJID:[XMPPUtil myBareJID] text:text time:time fromMe:fromMe];        
    }
    else {
        [self layoutSubviewsWithUserJID:oneToOneMessage.jid text:text time:time fromMe:fromMe];
    }
}

- (void)layoutSubviewsForMUCChat:(XMPPRoomMessageCoreDataStorageObject *)mucMessage {
    NSString *text = mucMessage.body;
    NSDate *time = mucMessage.localTimestamp;
    BOOL fromMe = [mucMessage.fromMe boolValue];
    if (fromMe) {
        [self layoutSubviewsWithUserJID:[XMPPUtil myBareJID] text:text time:time fromMe:fromMe];
    }
    else {
        [self layoutSubviewsWithUserJID:mucMessage.jid text:text time:time fromMe:fromMe];        
    }
}

- (CGRect)frameForTextLabel:(NSString *)text {
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE] constrainedToSize:CGSizeMake(textLabel.frame.size.width, 480) lineBreakMode:UILineBreakModeWordWrap ];
    CGRect frame = textLabel.frame;
    frame.size.height = size.height;
    return frame;
}

- (void)layoutSubviewsWithUserJID:(XMPPJID *)jid text:(NSString *)text time:(NSDate *)time fromMe:(BOOL)fromMe {
    XMPPJID *userJid = nil;
    if (fromMe) {
        userLabel.text = jid.user;
        userJid = jid;
    }
    else {
        userLabel.text = jid.resource;
        userJid = [XMPPJID jidWithUser:jid.resource domain:xmppHostName resource:nil];
    }

    textLabel.text = text;
    textLabel.frame = [self frameForTextLabel:text];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"mm/dd/yy hh:mm"];
    NSString *dateString = [dateFormatter stringFromDate:time];
    timeLabel.text = dateString;

    [self avatarForJID:userJid];
}

- (void)avatarForJID:(XMPPJID *)jid {
    NSData *photoData = [[[XMPPHandler sharedInstance] xmppvCardAvatarModule] photoDataForJID:jid];
    
    UIImage *avatarImage = [UIImage imageNamed:@"defaultPerson.png"];
    if (photoData != nil)
        avatarImage = [UIImage imageWithData:photoData];
    [avatarButton setBackgroundImage:avatarImage forState:UIControlStateNormal];
}
@end
