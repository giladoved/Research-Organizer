//
//  CreateEssayViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 8/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEssayViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) UITextView *essayText;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *savedEssay;
@property (nonatomic, strong) NSMutableString *essay;
@property (strong, nonatomic) IBOutlet UITextField *cool;

@end
