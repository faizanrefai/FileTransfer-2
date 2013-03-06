//
//  ContactsViewController.h
//  FileTransfer
//
//  Created by i Tech Coders Pvt Ltd. on 12/12/12.
//
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface ContactsViewController : UITableViewController<ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic, retain) NSMutableArray *contactsArray;

// The contacts object will allow us to access the device contacts.
@property (nonatomic, retain) ABPeoplePickerNavigationController *contacts;
@end
