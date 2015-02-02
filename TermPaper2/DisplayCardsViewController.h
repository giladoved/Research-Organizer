//
//  DisplayCardsViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 6/24/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddCardViewController.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>

@interface DisplayCardsViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate> {
    UIPopoverController *popover;
}
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *parseCards;
@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, strong) NSMutableArray *retrievedViewLocations;

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *quotes;
@property (nonatomic, strong) NSMutableArray *citations;
@property (nonatomic, strong) NSMutableArray *explanations;

@end
