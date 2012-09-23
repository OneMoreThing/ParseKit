//
//  PFImageView.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncImageView.h"

@interface PFImageView : AsyncImageView

    @property (nonatomic, retain) PFFile *file;
    - (void)loadInBackground;
    - (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion;

@end
