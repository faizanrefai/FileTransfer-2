//
//  NSString+Contain.h
//  FileTransfer
//
//  Created by Admin on 11/19/12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Contain)
- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions) options;
@end
