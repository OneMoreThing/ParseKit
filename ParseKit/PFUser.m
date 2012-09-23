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

@end
