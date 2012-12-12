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

@interface FriendListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, AccoutViewDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    UIAlertView *inviteAlertView;
    UIAlertView *declineAlertView;
    UIActionSheet *actionSheet;
}

@end
