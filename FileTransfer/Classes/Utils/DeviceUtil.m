//
//  DeviceUtil.m
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import "DeviceUtil.h"

@implementation DeviceUtil
+ (BOOL)isSimulator {
    BOOL result = NO;
    #if TARGET_IPHONE_SIMULATOR
        result = YES;
    #endif
    return result;
}
@end
