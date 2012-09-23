//
//  PFUser.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserClassName @"User"

@interface PFUser : PFObject

    + (PFUser *)currentUser;
    + (void)logOut;
    + (PFQuery *)query;
    + (void)setCurrentUser:(PFUser *)user;

@end
