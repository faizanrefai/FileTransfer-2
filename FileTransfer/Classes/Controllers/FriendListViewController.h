//
//  FriendList.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AccountsViewController.h"
#import "ListFilesViewController.h"

@interface FriendListViewController : UIViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate ,AccoutViewDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    UIAlertView *inviteAlertView;
    UIAlertView *declineAlertView;
    UIActionSheet *actionSheet;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
