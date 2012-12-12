//
//  DirectoryHelper.h
//  VideoBrowser
//
//  Created by HTK INC on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface DirectoryHelper : NSObject {
    
}


+ (BOOL)directoryExistAtPath:(NSString *)path;
+ (BOOL)createDirectoryAtPaht:(NSString *)path;
+ (BOOL)createFileAtPath:(NSString *)path;
+ (BOOL)copyDirectoryAtPath:(NSString *)path toDirectoryAtPath:(NSString *)destinationPath;
+ (BOOL)copyAllItemsAtPath:(NSString *)path toDirectoryAtPath:(NSString *)destinationPath;
+ (BOOL)removeDirectoryAtPath:(NSString *)path;
+ (BOOL)fileExistAtPath:(NSString *)path isDir:(BOOL)isDir;
+ (NSString *)documentDirectory;

/**
 * Get Temp directory, file .bin will be store there when download
 * After download we will extract .bin file and then move data to
 * resource folder
 */
//+ (NSString *)tempDirectory;

+ (NSArray *)filesAtPath:(NSString *)path;
+ (NSString *)savedFilesDirectory;
+ (NSString *)sentFilesDirectory;
+ (BOOL)createSaveFilesDirectory;
+ (BOOL)createSentFilesDirectory;
@end
