//
//  BaseRepository.h
//  iVNmob
//
//  Created by HTK INC on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface BaseRepository : NSObject {
  NSManagedObjectContext *managedObjectContext_;
  NSPersistentStoreCoordinator * persistentStore_;
  NSString *entityName_;
  NSMutableArray *itemsStatus;
}


- (void)saveContext;
- (NSArray *)allEntities;
- (NSArray *)allEntitiesWithSortOption:(NSArray *)sortOptions;

- (void)insertObject:(NSManagedObject *)object;
- (void)removeObject:(NSManagedObject *)object;
- (void)removeAllEntities;
- (NSArray *)allEntitiesSortByDateCreation;
- (void)removeAllEntitiesInArray:(NSArray *)array;

- (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate 
                           sortArray:(NSArray *)sortArray;
- (void)reset;

#pragma mark - Addition methods
- (void)setMoreItemsValue:(BOOL)value forName:(NSString *)name;
- (void)setCurrentIndex:(NSInteger)index forName:(NSString *)name;
- (void)setDataLoaded:(BOOL)vale forName:(NSString *)name;
- (void)setRefreshValue:(BOOL)value forName:(NSString *)name;


- (BOOL)moreItemsValueForName:(NSString *)name;
- (NSInteger)currentIndexForName:(NSString *)name;
- (BOOL)dataLoadedForName:(NSString *)name;
- (BOOL)refreshValueForName:(NSString *)name;

@end
