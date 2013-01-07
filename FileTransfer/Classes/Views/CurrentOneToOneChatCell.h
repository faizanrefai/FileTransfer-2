//
//  CurrentOneToOneChatCell.h
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import <UIKit/UIKit.h>
#import "XMPPMessageOneToOneChat.h"

@interface CurrentOneToOneChatCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *avatar;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLablel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic,strong) XMPPMessageOneToOneChat *message;
@end
