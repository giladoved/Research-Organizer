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

@interface DisplayCardsViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPopoverController *popover;
}
@property (strong) NSMutableArray *cards;
@property (strong) NSMutableArray *cardViews;
@property (strong) NSMutableArray *retrievedViewLocations;

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *quotes;
@property (nonatomic, strong) NSMutableArray *citations;
@property (nonatomic, strong) NSMutableArray *explanations;

@end
