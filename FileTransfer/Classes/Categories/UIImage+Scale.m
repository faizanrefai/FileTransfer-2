//
//  UIImage+Scale.m
//  iVNmob
//
//  Created by HTK INC on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

- (UIImage *)scaleToSize:(CGSize)size {
  //Create a bitmap graphics context
  UIGraphicsBeginImageContext(size);
  
  //Draw the scaled image in the current context
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  
  //Create new image fro current context
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  
  //Pop the current context from the stack
  UIGraphicsEndImageContext();
  
  return scaledImage;
}

- (UIImage *)scaleToMax:(CGFloat)value {
  CGFloat height = self.size.height;
  CGFloat width = self.size.width;
  CGFloat scale = 1.0;
  
  if (height > width) {
    if (height < value) {
      //scale = 1.0;
    }
    scale = height/value;
  }
  else {
    if (width < value) {
       //scale = 1.0;
    }
    scale = width/value;
  }
  
  CGSize size = CGSizeMake(width/scale, height/scale);
  
  //Create a bitmap graphics context
  UIGraphicsBeginImageContext(size);
  
  //Draw the scaled image in the current context
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  
  //Create new image fro current context
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  
  //Pop the current context from the stack
  UIGraphicsEndImageContext();
  
  return scaledImage;
}

@end
