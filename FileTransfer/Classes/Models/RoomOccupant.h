//
//  RoomOccupant.h
//  FileTransfer
//
//  Created by Admin on 11/30/12.
//
//

#import <Foundation/Foundation.h>

@interface RoomOccupant : NSObject
@property (nonatomic, strong) NSString *affiliation;
@property (nonatomic, strong) NSString *realJidStr;
@property (nonatomic, strong) NSString *roomJidStr;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *nickname;
@end
