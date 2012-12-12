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
- (void)didSelectUsers:(NSArray *)users;
@end

@interface SelectUserViewController : UsersViewBaseController {
    NSIndexPath *indexSelected;
    NSMutableArray *rowsSelected;
}

@property (nonatomic, assign) id<SelectUserDelegate> delegate;
@property (nonatomic, strong) NSArray *usersSelected;
@property (nonatomic) BOOL multiSelect;

- (IBAction)cancelAction:(id)sender;
- (IBAction)inviteAction:(id)sender;
@end
