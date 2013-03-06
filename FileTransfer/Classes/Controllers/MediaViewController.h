//
//  MediaViewController.h
//  FileTransfer
//
//  Created by Admin on 1/2/13.
//
//

#import <UIKit/UIKit.h>

@interface MediaViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fileFetchedResultController;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
