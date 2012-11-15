//
//  ChatViewCell.h
//  FileTransfer
//
//  Created by Admin on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ChatViewCell : UITableViewCell {
    UIButton *avatarButton;
    UILabel *userLabel;
    UILabel *timeLabel;
    UILabel *textLabel;
    
    BOOL isMe;
    BOOL isShowAvatar;
}
@property (nonatomic, strong) NSManagedObject *message;

+ (CGFloat)heightForCellWithText:(NSString *)text;

@end
