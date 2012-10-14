//
//  PFApplicationKey.h
//  ParseKit
//
//  Created by Denis Berton on 13/10/12.
//
//

#import <Foundation/Foundation.h>

@interface PFApplicationKey : NSObject
    +(BOOL)isPFFileKey:(NSString *)key;
    +(BOOL)isPFUserKey:(NSString *)key;
    +(BOOL)isPFGeoPointKey:(NSString *)key;
    +(BOOL)isPFObjectKey:(NSString *)key;
    +(NSString*)getPFObjectClassForKey:(NSString *)key;
@end
