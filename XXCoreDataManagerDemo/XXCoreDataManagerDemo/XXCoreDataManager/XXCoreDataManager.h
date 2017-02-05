//
//  XXCoreDataManager.h
//  XXCoreDataManagerDemo
//
//  Created by 朱小亮 on 2017/2/5.
//  Copyright © 2017年 朱小亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface XXCoreDataManager : NSObject

+ (instancetype)manager;

@property (readonly,strong,nonatomic)NSURL *applicationDocumentsDirectory;

@property (readonly,strong,nonatomic)NSManagedObjectModel *managedObjectModel;

@property (strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly,strong,nonatomic)NSManagedObjectContext *managedObjectContext;

//insert obj to entity
- (void)insertEntityWithEntityName:(NSString *)entityName manageObj:(NSManagedObject *)resultObj;

//delete obj from entity with predStr
// if predStr is nil ,then clear the entity
- (void)deleteEntityWithEntityName:(NSString *)entityName withPredStr:(NSString *)predStr;

//update obj
- (void)updateNSManagedObject;

//search results frome entity with predStr
// if predStr is nil ,search the all from entity
- (void)searchEntityWithEntityName:(NSString *)entityName predStr:(NSString *)predStr;

@end
