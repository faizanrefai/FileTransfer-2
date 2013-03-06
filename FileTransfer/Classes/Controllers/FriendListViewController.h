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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RegisterViewController.h"

@interface FriendListViewController : UIViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate ,AccoutViewDelegate,ABPeoplePickerNavigationControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    UIAlertView *inviteAlertView;
    UIAlertView *declineAlertView;
    UIActionSheet *actionSheet;
    NSMutableArray *tempArray;
      NSMutableArray *sortedIndexedArray;
    NSMutableDictionary *currentItem;
    NSString *UserName;
    RegisterViewController *registerObj;
}
@property (nonatomic, retain) NSMutableArray *contactsArray;

// The contacts object will allow us to access the device contacts.
@property (nonatomic, retain) ABPeoplePickerNavigationController *contacts;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (IBAction)viewYatoAction:(id)sender;
@end
