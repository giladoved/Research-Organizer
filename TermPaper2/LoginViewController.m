//
//  LoginViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 1/25/14.
//  Copyright (c) 2014 Gilad Oved. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "DisplayCardsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)login:(id)sender {
    NSString *username = self.usernameTxt.text;
    NSString *password = self.passwordTxt.text;
    
    [PFUser logInWithUsernameInBackground:username password:password
        block:^(PFUser *user, NSError *error) {
            if (user) {
                UIStoryboard *storyboard = [self storyboard];
                LoginViewController *loginVC = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                loginVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:loginVC animated:YES];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Account"
                                                                message:errorString
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
