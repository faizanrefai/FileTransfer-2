//
//  OccupantsViewController.h
//  FileTransfer
//
//  Created by Admin on 11/30/12.
//
//

#import <UIKit/UIKit.h>
#import "RoomOccupant.h"

@protocol OccupantsViewControllerDelegate <NSObject>
- (void)occupantsSelected:(NSArray *)occupants;
@end

@interface OccupantsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *rowsSelected;
}

@property (nonatomic, strong) NSArray *occupants;
@property (nonatomic, assign) id<OccupantsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *currentOccupantsSelected;
@property (nonatomic) BOOL multiSelect;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)cancelAction:(id)sender;
- (IBAction)inviteAction:(id)sender;
@end
