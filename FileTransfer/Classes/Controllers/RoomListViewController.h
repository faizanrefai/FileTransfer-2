//
//  RoomListViewController.h
//  FileTransfer
//
//  Created by Admin on 11/11/12.
//
//

#import <UIKit/UIKit.h>
#import "NewRoomViewController.h"

@interface RoomListViewController : UIViewController <NewRoomDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSArray __strong *roomList;
    NewRoomViewController *newRoomViewController;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
