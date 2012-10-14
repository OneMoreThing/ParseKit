//
//  PFLogInViewController.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PFLogInViewController.h"
#import "SCFacebook.h"
#import "PFQuery.h"
#import "PFUser.h"
#import "PFConstants.h"

@interface PFLogInViewController ()
    @property (strong, nonatomic) IBOutlet UIButton *button;
@end


@implementation PFLogInViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    self.logInView = [[PFLogInView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.view = self.logInView;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setBackgroundImage:[UIImage imageNamed:@"login-button-small.png"] forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [self.button setTitle:@"Login" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button setFrame:CGRectMake(94.0f, 240.0f, 133.0f, 36.0f)];
    [self.button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    self.button.alpha = 0.0f;
    [self.view addSubview:self.button];
    [UIView animateWithDuration:1.500f animations:^{
        self.button.alpha = 1.0f;
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) loginUser:(NSString*) facebookId{
    
    if(![PFUser currentUser]){
        PFQuery *query = [PFUser query];
        [query whereKey:kUserFacebookIDKey equalTo:facebookId];
    
        NSError *error = nil;
        NSArray *array = [query findObjects:&error];
        if([array count] > 0)
            [PFUser setCurrentUser:(PFUser*)[array objectAtIndex:0]];
        else{
            PFUser* newUser= [PFUser user];
            if (facebookId && facebookId != 0) {
                [newUser setObject:facebookId forKey:kUserFacebookIDKey];
                BOOL saved = [newUser.dkEntity save];
                if(!saved){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post load/save user, server error" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                    [self logout];
                    return;
                }
            }
            [PFUser setCurrentUser:newUser];
        }
    }
    
    [self.delegate logInViewController:self didLogInUser: [PFUser currentUser]];    
    [SCFacebook getUserFriendsCallBack:^(BOOL success, id result) {
        if (success) {
            [self.delegate request: nil didLoad:result];
        }
    }];
}

- (void)getUserInfo
{
    [SCFacebook getUserFQL:FQL_USER_STANDARD callBack:^(BOOL success, id result) {
        if (success) {
            NSString * facebookId = [[result objectForKey:@"uid"] stringValue];
            [self loginUser: facebookId];
  
        }else{
        }
    }];
}

- (void)login
{
    [SCFacebook setFacebookPermissions:self.facebookPermissions];
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        if (success) {
            self.button.enabled = NO;
            [self getUserInfo];
        }
    }];
}

- (void)logout
{
    [SCFacebook logoutCallBack:^(BOOL success, id result) {
        if (success) {
            [PFUser logOut];
            self.button.enabled = YES;
        }
    }];
}

@end
