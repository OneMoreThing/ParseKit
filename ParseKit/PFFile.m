//
//  PFFile.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFFile.h"
#import "EGOCache.h"

@implementation PFFile

@synthesize dkFile;

- (BOOL)isDataAvailable {
    return (self.dkFile.data != nil ||  self.dkFile.name.length > 0);
}

- (NSString *)url {
    NSString* cachedUrl = [[EGOCache currentCache] stringForKey:self.dkFile.name];
    if(cachedUrl)
        return cachedUrl;
    
    NSError *error = nil;
    NSURL * url = [self.dkFile generatePublicURL:&error];
    [[EGOCache currentCache] setString:[url absoluteString] forKey:self.dkFile.name];
    return [url absoluteString];
}

/*
- (void)urlInBackgroundWithBlock:(void (^)(NSURL *publicURL, NSError *error))block {
    NSString* cachedUrl = [[EGOCache currentCache] stringForKey:self.dkFile.name];
    if(cachedUrl){
        block([NSURL URLWithString:cachedUrl],nil);
        return;
    }
    [self.dkFile generatePublicURLInBackgroundWithBlock:^(NSURL *publicURL, NSError *error){
        [[EGOCache currentCache] setString:[publicURL absoluteString] forKey:self.dkFile.name];
        block(publicURL,error);
    }];
}
*/

+ (id)fileWithData:(NSData *)data{
    PFFile *file = [[self alloc] init];
    file.dkFile = [DKFile fileWithData:data];
    return file;
}

- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block{
    [self.dkFile saveInBackgroundWithBlock: block];
}

- (void)getDataInBackgroundWithBlock:(PFDataResultBlock)block{
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSData* data = [[EGOCache currentCache] dataForKey:self.dkFile.name];
        if(!data){
            data = [self.dkFile loadData:&error];
            [[EGOCache currentCache] setData:data forKey:self.dkFile.name];
        }
        if (block != NULL) {
            dispatch_async(q, ^{
                block(data, error);
            });
        }
    });
}

@end