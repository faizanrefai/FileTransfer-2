//
//  UsersViewBaseController.h
//  FileTransfer
//
//  Created by Admin on 11/13/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface UsersViewBaseController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>{
    
    UITableView *tableView;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
