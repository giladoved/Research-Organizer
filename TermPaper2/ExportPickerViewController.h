//
//  ExportPickerViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 8/4/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExportPickerDelegate <NSObject>
@required
-(void)selectedOption:(UIColor *)newColor;
@end

@interface ExportPickerViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, weak) id<ExportPickerDelegate> delegate;
@end