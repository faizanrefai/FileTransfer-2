//
//  DirectoryHelper.m
//  VideoBrowser
//
//  Created by HTK INC on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DirectoryHelper.h"
#import "AppConstants.h"

@implementation DirectoryHelper



+ (BOOL)directoryExistAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (!([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir)) {
        return NO;
    }
    return YES;
}

+ (BOOL)createDirectoryAtPaht:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if (error != nil) {
        return NO;
    }
    return YES;
}

+ (BOOL)createFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSError *error;
    [fileManager createFileAtPath:path contents:nil attributes:nil];
    //[fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    return YES;
}

+ (BOOL)copyDirectoryAtPath:(NSString *)path toDirectoryAtPath:(NSString *)destinationPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fileManager copyItemAtPath:path toPath:destinationPath error:&error];
    //[fileManager copyItemAtPath:[path stringByAppendingString:@"/"] toPath:[destinationPath stringByAppendingString:@"/"] error:&error];
    if (!result) {
        return NO;
    }
    return YES;
}

+ (BOOL)copyAllItemsAtPath:(NSString *)path 
         toDirectoryAtPath:(NSString *)destinationPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];  
    //NSEnumerator *e = [contents objectEnumerator];
    for (NSString *fileName in contents) {
        NSString *sourcePath = [path stringByAppendingPathComponent:fileName];
        NSString *desPath = [destinationPath stringByAppendingPathComponent:fileName];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&isDir] &&isDir) {
            [self copyAllItemsAtPath:sourcePath toDirectoryAtPath:desPath];
        }
        else {
            [fileManager copyItemAtPath:[path stringByAppendingPathComponent:fileName] toPath:[destinationPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
    
    /*
    while ((filename = [e nextObject])) {
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDir] &&isDir) {
            [directoriesOfFolder addObject:aPath];
        }
        
        [fileManager copyItemAtPath:[path stringByAppendingPathComponent:filename] toPath:[destinationPath stringByAppendingPathComponent:filename] error:nil];
    }*/
    return YES;

}


+ (BOOL)removeDirectoryAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

+ (BOOL)fileExistAtPath:(NSString *)path isDir:(BOOL)isDir {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] &&isDir) {
        return YES;
    }
    return NO;
}

+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    return documentsDirectory;
}


#pragma mark -
/**
 * Get file url in directory
 * @param path: directory to list
 * @param return NSURL array of files
**/
+ (NSArray *)filesAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:url includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    
    NSMutableArray *urlArray = [[NSMutableArray alloc] init];
    
    for (NSURL *theURL in dirEnumerator) {
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue] == NO) {
            [urlArray addObject:theURL];
        }
    }
    
    return urlArray;
}

+ (NSString *)savedFilesDirectory {
    NSString *documentPath = [self documentDirectory];
    NSString *filesPath = [documentPath stringByAppendingPathComponent:kFileFolderName];
    return filesPath;
}

+ (NSString *)sentFilesDirectory {
    NSString *documentPath = [self documentDirectory];
    NSString *filesPath = [documentPath stringByAppendingPathComponent:kSentFileFolderName];
    return filesPath;
    
}

+ (BOOL)createSaveFilesDirectory {
    NSString *filesPath = [self savedFilesDirectory];
    BOOL result = NO;
    if (![self directoryExistAtPath:filesPath]) {
        if ([self createDirectoryAtPaht:filesPath]) {
            result = YES;
        }
        else {
            result = NO;
        }
    }
    else {
        result = YES;
    }
    return result;
}

+ (BOOL)createSentFilesDirectory {
    NSString *filesPath = [self sentFilesDirectory];
    BOOL result = NO;
    if (![self directoryExistAtPath:filesPath]) {
        if ([self createDirectoryAtPaht:filesPath]) {
            result = YES;
        }
        else {
            result = NO;
        }
    }
    else {
        result = YES;
    }
    return result;
}

@end
