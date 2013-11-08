//
//  SimpleTableCell.h
//  TermPaper2
//
//  Created by Gilad Oved on 7/17/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *topicTxt;
@end
