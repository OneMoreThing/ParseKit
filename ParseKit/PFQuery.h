//
//  PFQuery.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFQuery : NSObject {
    DKQuery * dkQuery;
}
@property (strong, nonatomic) DKQuery * dkQuery;
@property (nonatomic) NSInteger limit;
@property (nonatomic,readwrite, assign) PFCachePolicy cachePolicy;

+ (PFQuery *)queryWithClassName:(NSString *)className;
+ (PFQuery *)orQueryWithSubqueries:(NSArray *)queries;

- (void)includeKey:(NSString *)key;
- (void)whereKeyExists:(NSString *)key;
- (void)whereKey:(NSString *)key equalTo:(id)object;
- (void)whereKey:(NSString *)key notEqualTo:(id)object;
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array;
- (void)whereKey:(NSString *)key matchesKey:(NSString *)otherKey inQuery:(PFQuery *)query;
- (void)orderByAscending:(NSString *)key;
- (void)orderByDescending:(NSString *)key;
- (void)getObjectInBackgroundWithId:(NSString *)objectId
                              block:(PFObjectResultBlock)block;
- (NSArray *)findObjects:(NSError **)error;
- (void)findObjectsInBackgroundWithBlock:(PFArrayResultBlock)block;
- (void)countObjectsInBackgroundWithBlock:(PFIntegerResultBlock)block;
- (BOOL)hasCachedResult;

- (void)performMapReduce:(DKMapReduce *)mapReduce inBackgroundWithBlock:(void (^)(id result, NSError *error))block;
@end
