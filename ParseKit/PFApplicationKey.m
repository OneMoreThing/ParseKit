//
//  PFApplicationKey.m
//  ParseKit
//
//  Created by Denis Berton on 13/10/12.
//
//

#import "PFApplicationKey.h"

@implementation PFApplicationKey

+ (BOOL) isPFFileKey:(NSString *)key{
#ifdef ANYPIC
    return [key isEqualToString: kPAPUserProfilePicSmallKey]||
    [key isEqualToString: kPAPUserProfilePicMediumKey] ||
    [key isEqualToString: kPAPPhotoPictureKey] ||
    [key isEqualToString: kPAPPhotoThumbnailKey];
#endif
	return NO;
}

+ (BOOL) isPFUserKey:(NSString *)key{
#ifdef ANYPIC
    return [key isEqualToString: kPAPPhotoUserKey] ||
    [key isEqualToString: kPAPActivityFromUserKey] ||
    [key isEqualToString: kPAPActivityToUserKey];
#endif
#ifdef ANYWALL
	return [key isEqualToString: kPAWParseUserKey];
#endif
	return NO;
}

+ (BOOL) isPFGeoPointKey:(NSString *)key{
#ifdef ANYWALL
	return [key isEqualToString: kPAWParseLocationKey];
#endif
    return NO;
}

+ (BOOL) isPFObjectKey:(NSString *)key{
#ifdef ANYPIC
    return [key isEqualToString: kPAPActivityPhotoKey];
#endif
    return NO;
}

+ (NSString*) getPFObjectClassForKey:(NSString *)key{
#ifdef ANYPIC
    if([key isEqualToString: kPAPActivityPhotoKey]){
        return kPAPPhotoClassKey;
    }
#endif
    return nil;
}

@end
