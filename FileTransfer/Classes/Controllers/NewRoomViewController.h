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

- (void)roomCreated:(XMPPJID *)jid;

@end

@interface NewRoomViewController : UIViewController {
    XMPPRoom *room;
}
@property (nonatomic, strong) IBOutlet UITextField *roomNameTextField;
@property (nonatomic, strong) IBOutlet UIButton *createButton;
@property (nonatomic, assign) id<NewRoomDelegate>delegate;

- (IBAction)createRoomAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
@end
