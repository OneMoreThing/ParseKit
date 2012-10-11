//
//  PFImageView.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFImageView.h"

@implementation PFImageView

- (void)loadInBackground{
    [self loadInBackground:^(UIImage *image, NSError *error){
        if(error)
            NSLog(@"fetch image error");
    }];
}

- (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion{
    [self.file urlInBackgroundWithBlock:^(NSURL *publicURL, NSError *error){
        [self setImageURL:publicURL];
        completion(self.image, error);        
    }];
}

@end
