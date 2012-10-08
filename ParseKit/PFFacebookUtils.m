//
//  PFFacebookUtils.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFFacebookUtils.h"
#import "SCFacebook.h"

@implementation PFFacebookUtils

static NSString *applicationId = nil;

+ (void)initializeWithApplicationId:(NSString *)appId{
    [SCFacebook initWithAppId:appId];
    @synchronized([PFFacebookUtils class]) {
        if (!applicationId)
            applicationId = appId;
    }
}

+ (PF_Facebook *)facebook{
    return [SCFacebook facebook];
}

+ (BOOL)extendAccessTokenIfNeededForUser:(PFUser *)user block:(PFBooleanResultBlock)block{return NO;}

+ (BOOL)handleOpenURL:(NSURL *)url{
    return [SCFacebook handleOpenURL:url];
}
@end
