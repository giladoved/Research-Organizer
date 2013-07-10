//
//  AddCardViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 6/24/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Card.h"

@interface AddCardViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIPopoverController *popover;
}
@property (weak, nonatomic) IBOutlet UITextField *pointTxt;
@property (weak, nonatomic) IBOutlet UITextView *quoteTxt;
@property (weak, nonatomic) IBOutlet UITextField *citationTxt;
@property (weak, nonatomic) IBOutlet UITextView *explanationTxt;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *colorPickerButton;


- (IBAction)cancel:(id)sender;
- (IBAction)addCard:(id)sender;
- (IBAction)chooseColor:(id)sender;

@end
