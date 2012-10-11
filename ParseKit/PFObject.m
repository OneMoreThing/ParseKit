//
//  PFObject.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//


#import "PFObject.h"

@interface PFObject ()
    @property (nonatomic, strong) NSMutableDictionary *pfCache;
@end

@implementation PFObject

@synthesize dkEntity;
@synthesize hasBeenFetched;

- (NSDate *)createdAt {
    return self.dkEntity.createdAt;
}
- (NSString *)objectId {
    return self.dkEntity.entityId;
}
- (NSString *)className {
    return self.dkEntity.entityName;
}

- (id)initWithName:(NSString *)entityName {
    self = [super init];
    if (self) {
        self.dkEntity = [DKEntity entityWithName:entityName];
		self.hasBeenFetched = NO;
        self.pfCache = [NSMutableDictionary new];        
    }
    return self;
}

+ (PFObject *)objectWithClassName:(NSString *)className{
    return [[self alloc] initWithName:className];
}

+ (PFObject *)objectWithoutDataWithClassName:(NSString *)className
                                    objectId:(NSString *)objectId{
    PFObject *obj = [[self alloc] initWithName:className];
    //Change entityId property in DKEntity.h from readonly to strong
    obj.dkEntity.entityId = objectId;
    return obj;
}

- (id)objectForKey:(NSString *)key{
   id obj = [self.pfCache objectForKey:key];
   if (obj != nil)
        return obj;
        
   if([PFAdapterUtils isPFFileKey:key]){
      NSString *fileName= [self.dkEntity objectForKey:key];
       if(fileName){ //&& [DKFile fileExists:fileName]){
           PFFile *file = [PFFile fileWithData:nil];
           file.dkFile = [DKFile fileWithName:fileName];
           [self.pfCache setObject:file forKey:key];
           return file;
       }
       return nil;
   }
   else if([PFAdapterUtils isPFUserKey:key]){
	   NSString* userId = [self.dkEntity objectForKey:key];
	   
	   PFUser* current = [PFUser currentUser];
	   if(current && [current.objectId isEqualToString: userId])
		   return current;
	   
       PFQuery *query = [PFUser query];
       [query whereKey:@"_id" equalTo:userId];
       NSError *error = nil;
       NSArray *array = [query findObjects:&error];
       if([array count] > 0){
           PFUser* user = (PFUser*)[array objectAtIndex:0];
           [self.pfCache setObject:user forKey:key];
           return user;
       }
   }
   else if([PFAdapterUtils isPFGeoPointKey:key]){
	   NSArray* arr = [self.dkEntity objectForKey:key];
	   PFGeoPoint* point = [PFAdapterUtils convertObjToPF:arr];
       [self.pfCache setObject:point forKey:key];
	   return point;
   }
   return [self.dkEntity objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key{
    [self.dkEntity setObject:[PFAdapterUtils convertObjToDK:object] forKey:key];
	self.hasBeenFetched = NO;
}

- (void)removeObjectForKey:(NSString *)key{
    if([PFAdapterUtils isPFFileKey:key]){
        NSString *fileName= [self.dkEntity objectForKey:key];
        if(fileName && [DKFile fileExists:fileName]){
            NSError *error = nil;
            [DKFile deleteFile:fileName error:&error];
        }
    }
    [self.pfCache removeObjectForKey:key];
    [self.dkEntity removeObjectForKey:key];
	self.hasBeenFetched = NO;
}

- (void)addUniqueObject:(id)object forKey:(NSString *)key{
    [self.dkEntity addObjectToSet:[PFAdapterUtils convertObjToDK:object] forKey:key];
	self.hasBeenFetched = NO;
}

- (void)removeObject:(id)object forKey:(NSString *)key{
    [self.dkEntity pullObject:[PFAdapterUtils convertObjToDK:object] forKey: key];
    [self.pfCache removeObjectForKey:key];
	self.hasBeenFetched = NO;
}

- (void)saveInBackground{
    [self.dkEntity saveInBackground];
	self.hasBeenFetched = YES;
}

- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block{
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        BOOL ret = [self.dkEntity save:&error];
		self.hasBeenFetched = ret;
        if (block != NULL) {
            dispatch_async(q, ^{
                block(ret, error);
            });
        }
    });
}

- (void)saveEventually{
    [self.dkEntity saveInBackground];
	self.hasBeenFetched = YES;
}
- (void)saveEventually:(PFBooleanResultBlock)callback{
    [self saveInBackgroundWithBlock:callback];
}

- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        [self.dkEntity refresh:&error];
		self.hasBeenFetched = YES;
        [self.pfCache removeAllObjects];
        if (selector != NULL) {
            dispatch_async(q, ^{
                if([target respondsToSelector:selector]){
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:self withObject:error];
                    #pragma clang diagnostic pop
                }
            });
        }
    });
}

- (void)fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block{
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
		if(!self.hasBeenFetched){
			[self.dkEntity refresh:&error];
			self.hasBeenFetched = YES;
            [self.pfCache removeAllObjects];
		}
        if (block != NULL) {
            dispatch_async(q, ^{
                block(self, error);
            });
        }
    });
}

- (BOOL)delete{
    return [self.dkEntity delete];
}

- (void)deleteEventually{
    [self.dkEntity deleteInBackground];
}

- (void)setValue:(id)value forKey:(NSString *)key{
  [self.dkEntity setObject:[PFAdapterUtils convertObjToDK:value] forKey:key];
  self.hasBeenFetched = NO;
}

- (PFObject *)fetchIfNeeded{
	if(!self.hasBeenFetched){
        NSError *error = nil;
        [self.dkEntity refresh:&error];
        [self.pfCache removeAllObjects];
		self.hasBeenFetched = YES;
	}
    return self;
}

@end
