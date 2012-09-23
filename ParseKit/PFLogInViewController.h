//
//  PFLogInViewController.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFLogInViewControllerDelegate;

@interface PFLogInViewController : UIViewController <UITextFieldDelegate> 

    @property (nonatomic) PFLogInFields fields;
    @property (nonatomic, retain) PFLogInView *logInView;
    @property (nonatomic, assign) id<PFLogInViewControllerDelegate> delegate;
    @property (nonatomic, retain) NSArray *facebookPermissions;

@end


@protocol PFLogInViewControllerDelegate <NSObject>
    @optional
    - (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;
    - (void)request:(PF_FBRequest *)request didLoad:(id)result;
@end
