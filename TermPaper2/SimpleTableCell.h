//
//  SimpleTableCell.h
//  TermPaper2
//
//  Created by Gilad Oved on 7/17/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *pointText;
@property (weak, nonatomic) IBOutlet UITextView *quoteText;
@property (weak, nonatomic) IBOutlet UITextView *explanationText;
@property (weak, nonatomic) IBOutlet UIView *backView;
@end
