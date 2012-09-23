//
//  PFObject.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface PFObject : NSObject {
     DKEntity * dkEntity;
}

@property (strong, nonatomic) DKEntity * dkEntity;
@property (nonatomic, retain) NSString *objectId;
@property (readonly) NSDate *createdAt;
@property (readonly) NSString *className;
@property (nonatomic, retain) PFACL *ACL;

+ (PFObject *)objectWithClassName:(NSString *)className;
+ (PFObject *)objectWithoutDataWithClassName:(NSString *)className
                                    objectId:(NSString *)objectId;
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)addUniqueObject:(id)object forKey:(NSString *)key;
- (void)removeObject:(id)object forKey:(NSString *)key;
- (void)saveInBackground;
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;
- (void)saveEventually;
- (void)saveEventually:(PFBooleanResultBlock)callback;
- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector;
- (void)fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block;
- (BOOL)delete;
- (void)deleteEventually;
- (void)setValue:(id)value forKey:(NSString *)key;

@end
