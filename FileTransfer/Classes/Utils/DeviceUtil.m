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

+ (NSString *)generateUUID
{
	NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
	
	return result;
}
@end
