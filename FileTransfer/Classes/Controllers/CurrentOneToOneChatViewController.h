//
//  CurrentOneToOneChatViewController.h
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import <UIKit/UIKit.h>

@interface CurrentOneToOneChatViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>{
//    NSFetchedResultsController *fetchedResultController;
//    NSFetchedResultsController *messageFetchedResultController;
    NSMutableDictionary *lastMessages;
}

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

- (IBAction)logoutAction:(id)sender;
@end
