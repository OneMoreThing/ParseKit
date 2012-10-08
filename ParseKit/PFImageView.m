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
    NSError *error = nil;
    NSURL * url =[self.file.dkFile generatePublicURL:&error];
    [self setImageURL:url];
}

- (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion{
    [self loadInBackground];
    NSError *error = nil;
    completion(self.image, error);
}

@end
