//
//  RoomChatViewController.h
//  FileTransfer
//
//  Created by Admin on 11/11/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPJID.h"
#import "XMPPRoom.h"
#import "SelectUserViewController.h"
#import "OccupantsViewController.h"

typedef enum {
    kSelectTypeNone,
    kSelectTypeInvite,
    kSelectTypeBan,
    kSelectTypeMute
}UserSelectType;

@interface RoomChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, SelectUserDelegate, XMPPRoomDelegate, OccupantsViewControllerDelegate> {
    XMPPJID *roomJID;
    XMPPRoom *room;
    NSFetchedResultsController *messageFetchedResultsController;
    BOOL keyboardVisible;
    UIActionSheet *actionSheet;
    UserSelectType selectType;
    NSArray *currentSelectedUsers;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic) IBOutlet UIView *inputTextView;
@property (nonatomic, strong) XMPPJID *roomJID;

- (IBAction)sendAction:(id)sender;

- (id)initWithRoomJID:(XMPPJID *)roomJID;
@end
