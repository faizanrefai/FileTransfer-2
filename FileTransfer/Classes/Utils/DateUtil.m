//
//  DateUtil.m
//  FileTransfer
//
//  Created by Admin on 12/14/12.
//
//

#import "DateUtil.h"

@implementation DateUtil
+ (NSString *)currentDateStringWithFormat:(NSString *)formatString {
    NSDate *date = [NSDate date];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:formatString];
    NSString *string = [formater stringFromDate:date];
    return string;
}
@end
