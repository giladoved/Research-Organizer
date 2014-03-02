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

- (IBAction)tapBackground:(id)sender {
    [self.usernameTxt resignFirstResponder];
    [self.passwordTxt resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.usernameTxt) {
        [self.usernameTxt resignFirstResponder];
        [self.passwordTxt becomeFirstResponder];
    } else if (theTextField == self.passwordTxt) {
        [self login:nil];
    }
    return YES;
}



- (IBAction)login:(id)sender {
    NSString *username = self.usernameTxt.text;
    username = [username lowercaseString];
    NSString *password = self.passwordTxt.text;
    
    [PFUser logInWithUsernameInBackground:username password:password
        block:^(PFUser *user, NSError *error) {
            if (user) {
                UIStoryboard *storyboard = [self storyboard];
                DisplayCardsViewController *displayVC = (DisplayCardsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DisplayCardsViewController"];
                displayVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:displayVC animated:YES];
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
    self.usernameTxt.delegate = self;
    self.passwordTxt.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end