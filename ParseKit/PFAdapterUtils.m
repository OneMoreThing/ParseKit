//
//  PFAdapterUtils.m
//  ParseKit
//
//  Created by Denis Berton on 02/09/12.
//
//

#import "PFAdapterUtils.h"

@implementation PFAdapterUtils


+(id)castObject:(id) obj{
    if([obj isKindOfClass:[PFFile class]])
        return ((PFFile*)obj).dkFile.name;
    if([obj isKindOfClass:[PFUser class]] || [obj isKindOfClass:[PFObject class]])
        return [((PFObject*)obj).dkEntity entityId];
    return obj;
}

+(NSArray*)convertArray:(NSArray*) array{
    NSMutableArray* newArray = [[NSMutableArray alloc] init];
    for (id el in array) {
        if([el isKindOfClass:[DKEntity class]]){
            DKEntity* entity = (DKEntity*)el;
            PFObject * obj = nil;
            if([entity.entityName isEqualToString: kUserClassName])
                obj = [PFUser objectWithoutDataWithClassName:entity.entityName
                                                    objectId:entity.entityId];
            else
                obj = [PFObject objectWithoutDataWithClassName:entity.entityName
                                                      objectId:entity.entityId];
        
            obj.dkEntity = entity;
            [newArray addObject:obj];
        }
        else if([el isKindOfClass:[PFUser class]]){
            [newArray addObject:((PFUser*)el).dkEntity.entityId];
        }
        else{
            return array;
        }
    }
    return newArray;
}

+ (BOOL) checkFileKey:(NSString *)key{
    return [key isEqualToString: kPAPUserProfilePicSmallKey]||
           [key isEqualToString: kPAPUserProfilePicMediumKey] ||
           [key isEqualToString: kPAPActivityPhotoKey] ||
           [key isEqualToString: kPAPPhotoPictureKey] ||
           [key isEqualToString: kPAPPhotoThumbnailKey];
}

+ (BOOL) checkUserKey:(NSString *)key{
    return [key isEqualToString: kPAPPhotoUserKey] ||
           [key isEqualToString: kPAPActivityFromUserKey] ||
           [key isEqualToString: kPAPActivityToUserKey];
}

@end
