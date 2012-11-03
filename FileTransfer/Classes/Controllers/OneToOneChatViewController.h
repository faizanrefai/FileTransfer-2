//
//  OneToOneChatViewController.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUserCoreDataStorageObject.h"

@interface OneToOneChatViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    XMPPUserCoreDataStorageObject *user_;
    NSFetchedResultsController *fetchedResultsController;
    BOOL keyboardVisible;
}

@property (nonatomic) XMPPUserCoreDataStorageObject *user;
@property (nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic) IBOutlet UIView *inputTextView;

- (IBAction)sendAction:(id)sender;
@end
