//
//  ParseKit.h
//  ParseKit
//
//  Created by Denis Berton on 20/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <DataKit/DataKit.h>
#import "PFConstants.h"
#import "PFACL.h"
#import "PFObject.h"
#import "PFGeoPoint.h"
#import "PFQuery.h"
#import "PFUser.h"
#import "PFFile.h"
#import "PFPush.h"
#import "PFInstallation.h"
#import "PFImageView.h"
#import "PFLoginView.h"
#import "PFTableViewCell.h"
#import "PFQueryTableViewController.h"
#import "PFAdapterUtils.h"
#import "PFApplicationKey.h"
#import "Facebook.h"
#import "PFFacebookUtils.h"
#import "PFLoginViewController.h"

@interface Parse : NSObject
    + (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey;
    + (void)setRequestLogEnabled:(BOOL)flag;
@end
