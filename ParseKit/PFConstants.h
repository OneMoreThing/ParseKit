//
//  PFConstants.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;
@class PFUser;

typedef enum {
    PFLogInFieldsFacebook = 1 << 3,
} PFLogInFields;

typedef enum {
    kPFCachePolicyIgnoreCache = 0,
    kPFCachePolicyCacheOnly,
    kPFCachePolicyNetworkOnly,
    kPFCachePolicyCacheElseNetwork,
    kPFCachePolicyNetworkElseCache,
    kPFCachePolicyCacheThenNetwork
} PFCachePolicy;

extern NSInteger const kPFErrorObjectNotFound;
extern NSInteger const kPFErrorCacheMiss;

typedef void (^PFBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^PFIntegerResultBlock)(int number, NSError *error);
typedef void (^PFArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^PFObjectResultBlock)(PFObject *object, NSError *error);
typedef void (^PFSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^PFUserResultBlock)(PFUser *user, NSError *error);
typedef void (^PFDataResultBlock)(NSData *data, NSError *error);
typedef void (^PFDataStreamResultBlock)(NSInputStream *stream, NSError *error);
typedef void (^PFProgressBlock)(int percentDone);

//Field keys
extern NSString *const kUserClassName;
extern NSString *const kUserNameKey;
extern NSString *const kUserPasswordKey;
extern NSString *const kUserFacebookIDKey;


