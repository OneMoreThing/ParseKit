//
//  PFUser.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//


#import "PFUser.h"
#import "SCFacebook.h"

@implementation PFUser 

static PFUser* current = nil;

- (id)initWithName:(NSString *)entityName {
    self = [super init];
    if (self) {
        self.dkEntity = [DKEntity entityWithName:entityName];
    }
    return self;
}

+ (PFUser *)currentUser{
    return current;
}

+ (void)logOut{
    [SCFacebook logoutCallBack:^(BOOL success, id result) {
        if (success) {
                current = nil; 
        }
    }];
}

+ (PFQuery *)query{
    return  [PFQuery queryWithClassName:kUserClassName];
}

+ (void)setCurrentUser:(PFUser *)user{
    current = user;
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
		
		PFQuery *query = [PFUser query];
		[query whereKey:kUserNameKey equalTo:username];
		DKQuery *andQuery = [query.dkQuery and];
		[andQuery whereKey:kUserPasswordKey equalTo:password];
		NSArray *array = [query findObjects:&error];
		if([array count] > 0)
			[PFUser setCurrentUser:(PFUser*)[array objectAtIndex:0]];
		else
			[PFUser setCurrentUser: nil];

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
			//return;
		}
		else{
			current = self;
		}
        if (block != NULL) {
            dispatch_async(q, ^{
                block(saved, error);
            });
        }
    });
}
@end
