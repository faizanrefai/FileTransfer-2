//
//  AccoutViewController.h
//  FileTransfer
//
//  Created by Admin on 11/16/12.
//
//

#import <UIKit/UIKit.h>

@protocol AccoutViewDelegate <NSObject>
- (void)didXMPPLogOut;
@end

@interface AccountsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<AccoutViewDelegate> delegate;

@end
