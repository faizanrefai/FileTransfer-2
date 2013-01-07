//
//  CurrentOneToOneChatCell.m
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import "CurrentOneToOneChatCell.h"
#import "XMPPHandler.h"

@implementation CurrentOneToOneChatCell
@synthesize avatar;
@synthesize nameLabel;
@synthesize messageLablel;
@synthesize timeLabel;
@synthesize message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(XMPPMessageOneToOneChat *)chatMessage {
    message = chatMessage;
    nameLabel.text = message.nickname;
    messageLablel.text = message.body;
    
    //
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    NSString *timeString = [formatter stringFromDate:message.localTimestamp];
    timeLabel.text = timeString;
    
    
    NSData *photoData = [[[XMPPHandler sharedInstance] xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:message.jidStr]];
    
    if (photoData != nil)
        avatar.image = [UIImage imageWithData:photoData];
    else
        avatar.image = [UIImage imageNamed:@"defaultPerson.png"];
    
}

@end
