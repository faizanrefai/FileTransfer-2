//
//  NSString+Contain.m
//  FileTransfer
//
//  Created by Admin on 11/19/12.
//
//

#import "NSString+Contain.h"

@implementation NSString (Contain)
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}
@end
