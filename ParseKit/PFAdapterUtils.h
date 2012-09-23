//
//  PFAdapterUtils.h
//  ParseKit
//
//  Created by Denis Berton on 02/09/12.
//
//

#import <Foundation/Foundation.h>

@interface PFAdapterUtils : NSObject

    +(id)castObject:(id) obj;
    +(NSArray*)convertArray:(NSArray*) array;
    +(BOOL)checkFileKey:(NSString *)key;
    +(BOOL)checkUserKey:(NSString *)key;

@end
