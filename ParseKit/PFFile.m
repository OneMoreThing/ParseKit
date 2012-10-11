//
//  PFFile.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFFile.h"

@interface PFFile()
    @property (nonatomic, strong) NSString * absoluteUrl;
@end

@implementation PFFile

@synthesize dkFile;

- (BOOL)isDataAvailable {
    if(self.absoluteUrl)
        return YES;
    else return (self.dkFile.data != nil ||  self.dkFile.name.length > 0); //[self url] != nil;
}

- (NSString *)url {
    if(self.absoluteUrl)
        return self.absoluteUrl;
    NSError *error = nil;
    NSURL * url = [self.dkFile generatePublicURL:&error];
    self.absoluteUrl = [url absoluteString];
    return self.url;
}

- (void)urlInBackgroundWithBlock:(void (^)(NSURL *publicURL, NSError *error))block {
    if(self.absoluteUrl){
        block([NSURL URLWithString:self.absoluteUrl],nil);
        return;
    }
    [self.dkFile generatePublicURLInBackgroundWithBlock:^(NSURL *publicURL, NSError *error){
        self.absoluteUrl = [publicURL absoluteString];
        block(publicURL,error);
    }];
}


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
        NSData* data = [self.dkFile loadData:&error];
        if (block != NULL) {
            dispatch_async(q, ^{
                block(data, error);
            });
        }
    });
}

@end