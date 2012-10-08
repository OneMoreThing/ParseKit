//
//  PFQuery.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFQuery.h"

@interface PFQuery ()
      @property (strong, nonatomic) NSArray * orSubqueries;
@end

@implementation PFQuery

@synthesize dkQuery;

-(void) setLimit:(NSInteger)limit{
    self.dkQuery.limit = limit;
}
-(NSInteger) getLimit{
    return self.dkQuery.limit;
}
-(void) setCachePolicy:(PFCachePolicy)cachePolicy{
    DKCachePolicy policy = DKCachePolicyIgnoreCache;
    switch (cachePolicy)
    {
        case kPFCachePolicyIgnoreCache:
            policy = DKCachePolicyIgnoreCache;
            break;
        case kPFCachePolicyCacheOnly:
            policy = DKCachePolicyUseCacheDontLoad;
            break;
        case kPFCachePolicyNetworkOnly:
            policy = DKCachePolicyIgnoreCache;
            break;
        case kPFCachePolicyCacheElseNetwork:
            policy = DKCachePolicyUseCacheElseLoad;
            break;
        case kPFCachePolicyNetworkElseCache:
            policy = DKCachePolicyIgnoreCache;
            break;
        case kPFCachePolicyCacheThenNetwork:
            policy = DKCachePolicyUseCacheElseLoad;
            break;
    }    
    self.dkQuery.cachePolicy = policy;
}
-(PFCachePolicy) getCachePolicy{
    DKCachePolicy policy = self.dkQuery.cachePolicy;
    PFCachePolicy mappedPolicy = kPFCachePolicyIgnoreCache;
    switch (policy)
    {
        case DKCachePolicyIgnoreCache:
            mappedPolicy = kPFCachePolicyIgnoreCache;
            break;
        case DKCachePolicyUseCacheElseLoad:
            mappedPolicy = kPFCachePolicyCacheElseNetwork;
            break;
        case DKCachePolicyUseCacheDontLoad:
            mappedPolicy = kPFCachePolicyCacheOnly;
            break;
    }
    return mappedPolicy;
}

- (id)initWithName:(NSString *)entityName {
    self = [super init];
    if (self) {
        self.dkQuery = [DKQuery queryWithEntityName:entityName];
    }
    return self;
}

+ (PFQuery *)queryWithClassName:(NSString *)className{
    return [[self alloc] initWithName:className];
}

- (void)includeKey:(NSString *)key{
    //[self.dkQuery includeKeys: [NSArray arrayWithObject:key]];
}

- (void)whereKeyExists:(NSString *)key{
    [self.dkQuery whereKeyExists:key];
}

- (void)whereKey:(NSString *)key equalTo:(id)object{
    [self.dkQuery whereKey:key equalTo:[PFAdapterUtils convertObjToDK: object]];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object{
    [self.dkQuery whereKey:key notEqualTo:[PFAdapterUtils convertObjToDK: object]];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array{
    [self.dkQuery whereKey:key containedIn: [PFAdapterUtils convertArrayToDK:array]];
}

+ (PFQuery *)orQueryWithSubqueries:(NSArray *)queries{
    PFQuery * q = [[self alloc] initWithName:@""];
    q.orSubqueries = queries;
    return q;
}

NSInteger comparator(id id1, id id2, void *context)
{
    DKEntity* entity1 = (DKEntity*)id1;
    DKEntity* entity2 = (DKEntity*)id2;
    return ([entity2.createdAt compare:entity1.createdAt]);
}

//Inefficient method for simple orSubqueries
- (NSArray *)findAll:(NSError **)error {
    if(self.orSubqueries){
        NSMutableArray* newArray = [[NSMutableArray alloc] init];
        for (id el in self.orSubqueries) {
            DKQuery* q = ((PFQuery*)el).dkQuery;
           [newArray addObjectsFromArray:[q findAll:error]];
        }
        //hard-coded [query orderByDescending:@"createdAt"]; with sortedArrayUsingFunction   
        return [newArray sortedArrayUsingFunction:comparator context:nil];
    }
    return [self.dkQuery findAll:error];
}

- (void)whereKey:(NSString *)key matchesKey:(NSString *)otherKey inQuery:(PFQuery *)query{
    NSMutableArray* newArray = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray *ar= [query.dkQuery findAll:&error];
    for (id el in ar) {
        DKEntity* e = nil;
        if(![el isKindOfClass:[DKEntity class]])
          e = ((PFObject*)el).dkEntity;
        else
          e = (DKEntity*)el;
        [newArray addObject: [e objectForKey:otherKey]];
    }
    [self.dkQuery whereKey:key containedIn:newArray];
}

- (void)orderByAscending:(NSString *)key{
    if([key isEqualToString:@"createdAt"])
        [self.dkQuery orderAscendingByCreationDate];
    else
        [self.dkQuery orderAscendingByKey:key];
}

- (void)orderByDescending:(NSString *)key{
    if([key isEqualToString:@"createdAt"])
        [self.dkQuery orderDescendingByCreationDate];
    else
        [self.dkQuery orderDescendingByKey:key];
}

- (void)getObjectInBackgroundWithId:(NSString *)objectId
                              block:(PFObjectResultBlock)block{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSArray *array = [self findObjects:&error];
        if([array count] > 0){
            PFObject *object = [array objectAtIndex:0];
            if (block != NULL) {
                dispatch_async(q, ^{
                    block(object, error);
                });
            }
        }
    });
}

- (NSArray *)findObjects:(NSError **)error{
    NSArray* array = [self findAll:error];
    return [PFAdapterUtils convertArrayToPF:array];
}

- (void)findObjectsInBackgroundWithBlock:(PFArrayResultBlock)block{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
		NSArray* array = [self findAll:&error];
		NSArray* newArray = [PFAdapterUtils convertArrayToPF:array];
        if (block != NULL) {
            dispatch_async(q, ^{
                block(newArray, error);
            });
        }
    });
}

- (void)findObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSArray* array = [self findAll:&error];
		NSArray* newArray = [PFAdapterUtils convertArrayToPF:array];
        if (selector != NULL) {
            dispatch_async(q, ^{
                if([target respondsToSelector:selector]){
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:newArray withObject:error];
                    #pragma clang diagnostic pop
                }
            });
        }
    });
}

- (void)countObjectsInBackgroundWithBlock:(PFIntegerResultBlock)block{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSInteger count = [self.dkQuery countAll:&error];
        if (block != NULL) {
            dispatch_async(q, ^{
                block(count, error);
            });
        }
    });        
}

- (BOOL)hasCachedResult{
    BOOL cached = NO;
    DKCachePolicy policy = self.dkQuery.cachePolicy;
    switch (policy)
    {
        case DKCachePolicyIgnoreCache:
            cached = NO;
            break;
        case DKCachePolicyUseCacheElseLoad:
            cached = YES;
            break;
        case DKCachePolicyUseCacheDontLoad:
            cached = YES;
            break;
    }
    if(cached && [self.dkQuery countAll] > 0){
        return YES;
    }
    return NO;
}

- (void)performMapReduce:(DKMapReduce *)mapReduce inBackgroundWithBlock:(void (^)(id result, NSError *error))block {
    [self.dkQuery performMapReduce:mapReduce inBackgroundWithBlock:block];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(PFGeoPoint *)geopoint withinKilometers:(double)maxDistance{
	double earthRadius = 6378; // km  
	double radians = maxDistance/earthRadius; //to radians
    [self.dkQuery whereKey:key nearPoint:[PFAdapterUtils convertObjToDK: geopoint] withinDistance:[NSNumber numberWithDouble:radians]];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(PFGeoPoint *)geopoint withinMiles:(double)maxDistance{
	double earthRadius = 3959; // miles
	double radians = maxDistance/earthRadius; //to radians
    [self.dkQuery whereKey:key nearPoint:[PFAdapterUtils convertObjToDK: geopoint] withinDistance:[NSNumber numberWithDouble:radians]];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(PFGeoPoint *)geopoint withinRadians:(double)maxDistance{
    [self.dkQuery whereKey:key nearPoint:[PFAdapterUtils convertObjToDK: geopoint] withinDistance:[NSNumber numberWithDouble:maxDistance]];
}
@end
