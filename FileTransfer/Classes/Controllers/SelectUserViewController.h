//
//  UsersViewController.h
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import "UsersViewBaseController.h"
#import "XMPPUserCoreDataStorageObject.h"

@protocol SelectUserDelegate <NSObject>
- (void)didSelectUser:(XMPPUserCoreDataStorageObject *)user;
@end

@interface SelectUserViewController : UsersViewBaseController {
    NSIndexPath *indexSelected;
}

@property (nonatomic, assign) id<SelectUserDelegate> delegate;

- (IBAction)cancelAction:(id)sender;
- (IBAction)inviteAction:(id)sender;
@end
