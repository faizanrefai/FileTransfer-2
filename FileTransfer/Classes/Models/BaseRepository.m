//
//  BaseRepository.m
//  iVNmob
//
//  Created by HTK INC on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseRepository.h"
#import "AppDelegate.h"

@implementation BaseRepository



- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext_ = [delegate managedObjectContext];
    persistentStore_ = [delegate persistentStoreCoordinator];
    
    itemsStatus = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)saveContext {
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [delegate saveContext];
}

- (void)insertObject:(NSManagedObject *)object {
  [managedObjectContext_ insertObject:object];
}

- (void)removeObject:(NSManagedObject *)object {
  [managedObjectContext_ deleteObject:object];
}

//Get all entities
- (NSArray *)allEntities {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName_ inManagedObjectContext:managedObjectContext_];
  [request setEntity:entity];
  
  NSArray *items = [managedObjectContext_ executeFetchRequest:request error:nil];

  return items;

}

- (NSArray *)allEntitiesSortByDateCreation {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName_ inManagedObjectContext:managedObjectContext_];
  [request setEntity:entity];
  
  //DateCreation
  NSSortDescriptor *sortDateCreation = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
  NSArray *sortArray = [NSArray arrayWithObject:sortDateCreation];
  [request setSortDescriptors:sortArray];
  
  NSArray *items = [managedObjectContext_ executeFetchRequest:request error:nil];

  return items;
  
}

- (NSArray *)allEntitiesWithSortOption:(NSArray *)sortOptions {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName_ inManagedObjectContext:managedObjectContext_];
  [request setEntity:entity];
  
  [request setSortDescriptors:sortOptions];
  
  NSArray *items = [managedObjectContext_ executeFetchRequest:request error:nil];

  return items;

}

//Remove all entites 
- (void)removeAllEntities {
  NSArray *items = [self allEntities];  
  for (NSManagedObject *manageObject in items) {
    [self removeObject:manageObject];
  }
  

}

- (void)removeAllEntitiesInArray:(NSArray *)array {
  for (NSManagedObject *object in array) {
    [self removeObject:object];
  }
}

- (NSArray *)fetchItemsWithPredicate:(NSPredicate *)predicate 
                          sortArray:(NSArray *)sortArray {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName_ inManagedObjectContext:managedObjectContext_];
  @synchronized(entity) {
    [request setEntity:entity];
    
    if (predicate != nil) {
      [request setPredicate:predicate];
    }
    
    if (sortArray != nil) {
      [request setSortDescriptors:sortArray];
    }
    
    //Execute request
    NSError *error = nil;
    NSArray *items = [managedObjectContext_ executeFetchRequest:request error:&error];
    if (items == nil) {
      //error
    }
   
    return items;
  }  
}

- (void)reset {
  [self removeAllEntities];
  //itemsStatus = nil;
  [itemsStatus removeAllObjects];
}

@end
