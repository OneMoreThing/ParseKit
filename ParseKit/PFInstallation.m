//
//  PFInstallation.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFInstallation.h"

@implementation PFInstallation

static PFInstallation* current = nil;

+(PFInstallation *)currentInstallation{
    if(!current){
        current = [[self alloc]init];
        //current = [[self alloc] initWithName:kInstallationClassName];
    }
    return current;
}

@end
