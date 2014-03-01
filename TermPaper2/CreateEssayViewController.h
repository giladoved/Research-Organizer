//
//  CreateEssayViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 8/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopViewController.h"
#import "ExportPickerViewController.h"
#import "MessageUI/MessageUI.h"

@interface CreateEssayViewController : UIViewController <MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate, ExportPickerDelegate>

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *savedEssay;
@property (nonatomic, strong) NSMutableString *essay;
@property (weak, nonatomic) IBOutlet UIWebView *essayWebView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (nonatomic, strong) ExportPickerViewController *exportPicker;
@property (nonatomic, strong) UIPopoverController *exportPickerPopover;
-(IBAction)pop:(id)sender;

@end
