//
//  XXCoreDataManager.m
//  XXCoreDataManagerDemo
//
//  Created by 朱小亮 on 2017/2/5.
//  Copyright © 2017年 朱小亮. All rights reserved.
//

#import "XXCoreDataManager.h"

@interface XXCoreDataManager()

@property (copy,nonatomic)NSString *dbName;

@end

@implementation XXCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)manager{
    static XXCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XXCoreDataManager alloc] init];
    });
    return manager;
}

- (NSString *)dbName{
    return @"dbName";
}

- (NSURL *)applicationDocumentsDirectory{
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.dbName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.dbName]];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@,current thread:%@", error, [error userInfo],[NSThread currentThread]);
        }
    }
}



//insert obj to entity
//eg:bindeddevice is entity  BindedDevice:NSManagedObject
//BindedDevice *item = [NSEntityDescription insertNewObjectForEntityForName:@"BindedDevice" inManagedObjectContext:self.managedObjectContext];
//[item setValue:name forKey:@"name"];
//[item setValue:identifier forKey:@"identifier"];
//[item setValue:[JZTPersonManager healthCount]  forKey:@"healthAccount"];
//[item setValue:@(deviceType) forKey:@"deviceType"];
- (void)insertEntityWithEntityName:(NSString *)entityName manageObj:(NSManagedObject *)resultObj {
    [self.managedObjectContext refreshObject:resultObj mergeChanges:YES];
    [self saveContext];
}

//delete obj from entity with predStr
// if predStr is nil ,then clear the entity
- (void)deleteEntityWithEntityName:(NSString *)entityName withPredStr:(NSString *)predStr{
    [self searchEntityWithEntityName:entityName predStr:predStr resultsBlock:^(NSArray *results) {
        for (id item in results) {
            [self.managedObjectContext deleteObject:item];
            [self saveContext];
        }
    }];
}

//update obj
//eg:
//ChatMessages *message = [userobjs firstObject];
//int i = 0;
//message.count = [NSNumber numberWithInt:i];
//[self updateNSManagedObject];
- (void)updateEntity{
    [self saveContext];
}

//search results frome entity with predStr
// if predStr is nil ,search the all from entity
//predStr: eg
//predStr = [NSString stringWithFormat:@"healthAccount = '%@' AND identifier = '%@'",healthAccount,identifier]
- (void)searchEntityWithEntityName:(NSString *)entityName predStr:(NSString *)predStr resultsBlock:(void(^)(NSArray *results))resultsBlock{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *frq = [[NSFetchRequest alloc] init];
    [frq setEntity:entity];
    if (predStr&&predStr.length>0) {
        NSPredicate *preds = [NSPredicate predicateWithFormat:predStr];
        [frq setPredicate:preds];
    }
    
    NSArray *userActionObjects = [self.managedObjectContext executeFetchRequest:frq error:nil];
    if (resultsBlock) {
        resultsBlock(userActionObjects);
    }
}



@end

























