//
//  LoginViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 1/25/14.
//  Copyright (c) 2014 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
- (IBAction)login:(id)sender;
@end
