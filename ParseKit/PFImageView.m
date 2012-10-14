//
//  PFImageView.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFImageView.h"


@implementation PFImageView


@synthesize file = _file;

-(void) setFile:(PFFile *)file{
    if(_file && _file.isDataAvailable){
        [_file.dkFile abort];
        //[[AsyncImageLoader sharedLoader] cancelLoadingURL:self.imageURL target:self];
    }
    _file = file;
}

- (void)loadInBackground{
    [self loadInBackground:^(UIImage *image, NSError *error){
        if(error)
            NSLog(@"fetch image error");
    }];
}

- (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion{
    [self.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if(!error)
            [self setImage: [UIImage imageWithData:data]];
        completion(self.image, error);
    }];
}

/*
- (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion{
    [self.file urlInBackgroundWithBlock:^(NSURL *publicURL, NSError *error){
        if(!error)
            [self setImageURL:publicURL];
        completion(self.image, error);
    }];
}
*/

@end
