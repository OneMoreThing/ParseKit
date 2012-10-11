//
//  PFFile.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFFile : NSObject {
    DKFile * dkFile;
}

@property (strong, nonatomic) DKFile * dkFile;
@property (readonly) NSString *url;
@property (readonly) BOOL isDataAvailable;

+ (id)fileWithData:(NSData *)data;
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;
- (void)getDataInBackgroundWithBlock:(PFDataResultBlock)block;

- (void)urlInBackgroundWithBlock:(void (^)(NSURL *publicURL, NSError *error))block;

@end