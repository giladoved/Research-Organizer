//
//  CreateAccountViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 1/25/14.
//  Copyright (c) 2014 Gilad Oved. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "DisplayCardsViewController.h"
#import <Parse/Parse.h>

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

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
        [self createAccount:nil];
    }
    return YES;
}

- (IBAction)createAccount:(id)sender {
    NSString *username = self.usernameTxt.text;
    NSString *password = self.passwordTxt.text;
    NSLog(@"username: %@", username);
    NSLog(@"password: %@", password);
    
    
    if (![username isEqualToString:@""] && ![password isEqualToString:@""]) {
        PFUser *user = [PFUser user];
        user.username = [username lowercaseString];
        user.password = password;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Created Account Successfully"
                                                                message:@"Successfully created the account"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
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
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Field left blank"
                                                        message:@"Please enter a username and password. Don't leave them blank."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.usernameTxt.delegate = self;
    self.passwordTxt.delegate = self;
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        UIStoryboard *storyboard = [self storyboard];
        DisplayCardsViewController *displayCards = (DisplayCardsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DisplayCardsViewController"];
        displayCards.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:displayCards animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
