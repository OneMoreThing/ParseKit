//
//  PFUser.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//


#import "PFUser.h"
#import "EGOCache.h"

@implementation PFUser 

static PFUser* current = nil;

+ (PFUser *)currentUser{
    if(current)
        return current;
    
    NSString* userId = [[EGOCache currentCache] stringForKey:@"currentUser"];
    if(userId){
        PFQuery *query = [PFUser query];
        [query.dkQuery whereEntityIdMatches: userId];
        NSError* error = nil;
        NSArray *array = [query findObjects:&error];
        if(!error && [array count] > 0)
            current = (PFUser*)[array objectAtIndex:0];    
    }
    return current;
}

+ (void)logOut{
    if(current){
        [[EGOCache currentCache] removeCacheForKey:@"currentUser"];
        current = nil;
    }
}

+ (PFQuery *)query{
    return  [PFQuery queryWithClassName:kUserClassName];
}

+ (void)setCurrentUser:(PFUser *)user{
    current = user;
    [[EGOCache currentCache] setString:user.dkEntity.entityId forKey:@"currentUser"];
}

-(NSString*)username{
	return [self objectForKey:kUserNameKey];
}

- (void)setUsername:(NSString *)username{
	[self setObject:self.username forKey:kUserNameKey];
}

-(NSString*)password{
	return [self objectForKey:kUserPasswordKey];
}

- (void)setPassword:(NSString *)password{
	[self setObject:self.password forKey:kUserPasswordKey];
}

+ (PFUser *)user{
	return (PFUser*)[PFUser objectWithClassName: kUserClassName];
}

+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                                block:(PFUserResultBlock)block{
	
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;        
        
        PFUser* c = [PFUser currentUser];
        if(!c){
            PFQuery *query = [PFUser query];
            [query whereKey:kUserNameKey equalTo:username];
            DKQuery *andQuery = [query.dkQuery and];
            [andQuery whereKey:kUserPasswordKey equalTo:password];
            NSArray *array = [query findObjects:&error];
            if(error){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            if([array count] > 0)
                [PFUser setCurrentUser:(PFUser*)[array objectAtIndex:0]];
            else
                [PFUser setCurrentUser: nil];
        }
        
        if (block != NULL) {
            dispatch_async(q, ^{
                block(current, error);
            });
        }
    });
}

- (void)signUpInBackgroundWithBlock:(PFBooleanResultBlock)block{
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;

		BOOL saved = [self.dkEntity save:&error];
		if(!saved){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post load/save user, server error" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
			[alert show];
		}
		else{
			[PFUser setCurrentUser:self];
		}
        
        if (block != NULL) {
            dispatch_async(q, ^{
                block(saved, error);
            });
        }
    });
}
@end
