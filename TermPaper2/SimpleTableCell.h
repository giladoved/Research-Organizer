//
//  SimpleTableCell.h
//  TermPaper2
//
//  Created by Gilad Oved on 7/17/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pointText;
@property (weak, nonatomic) IBOutlet UILabel *quoteText;
@property (weak, nonatomic) IBOutlet UIImageView *quoteIV;
@property (weak, nonatomic) IBOutlet UIImageView *imageBack;
@property (weak, nonatomic) IBOutlet UIView *movieFrame;
@property (weak, nonatomic) IBOutlet UILabel *explanationText;
@end
