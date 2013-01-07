//
//  OneToOneChatViewController.h
//  FileTransfer
//
//  Created by Admin on 10/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUserCoreDataStorageObject.h"
#import "TURNSocket.h"

@interface OneToOneChatViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  TURNSocketDelegate, GCDAsyncSocketDelegate>{
    
    XMPPUserCoreDataStorageObject *user_;
    NSFetchedResultsController *chatMessageFetchedResultsController;
    NSFetchedResultsController *fileTransferMessageFetchedResultsController;
    BOOL keyboardVisible;
    NSMutableArray *turnSockets;
    
    NSMutableArray *messages;
}

@property (nonatomic) XMPPUserCoreDataStorageObject *user;
@property (nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic) IBOutlet UIView *inputTextView;

- (IBAction)sendAction:(id)sender;
- (IBAction)backAction:(id)sender;
@end
