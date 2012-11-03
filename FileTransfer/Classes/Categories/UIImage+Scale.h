//
//  UIImage+Scale.h
//  iVNmob
//
//  Created by HTK INC on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (Scale)
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)scaleToMax:(CGFloat)value;
@end



