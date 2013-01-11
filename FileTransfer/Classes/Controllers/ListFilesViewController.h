//
//  ListFilesViewController.h
//  FileTransfer
//
//  Created by Admin on 12/1/12.
//
//

#import <UIKit/UIKit.h>

@protocol ListFilesViewControllerDelegate <NSObject>

- (void)didSelectFileURL:(NSURL *)fileURL;

@end

@interface ListFilesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSFetchedResultsController *fileFetchedResultController;
}
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<ListFilesViewControllerDelegate> delegate;

- (IBAction)cancelAction:(id)sender;
- (IBAction)selectAction:(id)sender;
@end
