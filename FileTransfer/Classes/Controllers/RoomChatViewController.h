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

@interface RoomChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, SelectUserDelegate> {
    XMPPJID *roomJID;
    XMPPRoom *room;
    NSFetchedResultsController *messageFetchedResultsController;
    BOOL keyboardVisible;
    UIActionSheet *actionSheet;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic) IBOutlet UIView *inputTextView;
@property (nonatomic, strong) XMPPJID *roomJID;

- (IBAction)sendAction:(id)sender;

- (id)initWithRoomJID:(XMPPJID *)roomJID;
@end
