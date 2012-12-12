//
//  NewRoomViewController.h
//  FileTransfer
//
//  Created by Admin on 11/11/12.
//
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"

@protocol NewRoomDelegate <NSObject>
- (void)didJointRoom:(XMPPRoom *)room;
@end

@interface NewRoomViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    XMPPRoom *room;
    NSArray *roomList;
}
@property (nonatomic, strong) IBOutlet UITextField *roomNameTextField;
@property (nonatomic, strong) IBOutlet UIButton *createButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<NewRoomDelegate>delegate;

- (IBAction)joinRoomAction:(id)sender;
- (IBAction)joinRoomAction:(id)sender;
@end
