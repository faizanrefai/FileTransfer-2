//
//  HUBUtil.m
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import "HUBUtil.h"
#import "MBProgressHUD.h"

@implementation HUBUtil
+ (void)showHUBInWindow {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:window];
    [hub showAnimated:YES whileExecutingBlock:^{

    }];
}

+ (void)hideHUBInWindow {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
}

@end
