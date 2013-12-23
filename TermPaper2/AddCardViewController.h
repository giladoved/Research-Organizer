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

@interface AddCardViewController : UIViewController <UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
    UIPopoverController *popover;
}
@property (weak, nonatomic) IBOutlet UITextField *pointTxt;
@property (weak, nonatomic) IBOutlet UITextView *quoteTxt;
@property (weak, nonatomic) IBOutlet UITextField *citationTxt;
@property (weak, nonatomic) IBOutlet UITextView *explanationTxt;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *colorPickerButtonPIE;
@property (weak, nonatomic) IBOutlet UIButton *colorPickerButtonTopic;

@property (weak, nonatomic) IBOutlet UISegmentedControl *cardChooser;
- (IBAction)chooseMedia:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *pieForm;
@property (weak, nonatomic) IBOutlet UIView *topicForm;

@property (weak, nonatomic) IBOutlet UITextField *topicTxt;
@property (weak, nonatomic) IBOutlet UIButton *topicColorBtn;

- (IBAction)cancel:(id)sender;
- (IBAction)addCard:(id)sender;
- (IBAction)chooseColor:(id)sender;
- (IBAction)changeCardType:(id)sender;

@end
