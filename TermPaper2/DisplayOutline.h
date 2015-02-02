//
//  DisplayOutline.h
//  TermPaper2
//
//  Created by Gilad Oved on 7/15/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayOutline : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *quotes;
@property (nonatomic, strong) NSMutableArray *citations;
@property (nonatomic, strong) NSMutableArray *explanations;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *xs;
@property (nonatomic, strong) NSMutableArray *ys;

@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UINavigationController *navCon;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction) EditTable:(id)sender;

@end
