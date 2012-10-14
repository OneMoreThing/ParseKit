//
//  PFFacebookUtils.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol PF_FBRequestDelegate;
@compatibility_alias PF_Facebook Facebook;
@compatibility_alias PF_FBRequest FBRequest;

@interface PFFacebookUtils : NSObject
    + (PF_Facebook *)facebook;
    + (void)initializeWithApplicationId:(NSString *)appId;
    + (BOOL)extendAccessTokenIfNeededForUser:(PFUser *)user block:(PFBooleanResultBlock)block;
    + (BOOL)handleOpenURL:(NSURL *)url;
@end

//Fast way, replace the only one occurrence for PF_FBRequestDelegate (in AppDelegate.h for Anypic) with FBRequestDelegate
/*
@protocol PF_FBRequestDelegate <NSObject>
 @optional
 - (void)requestLoading:(PF_FBRequest *)request;
 - (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response;
 - (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error;
 - (void)request:(PF_FBRequest *)request didLoad:(id)result;
 - (void)request:(PF_FBRequest *)request didLoadRawResponse:(NSData *)data;
@end
*/
