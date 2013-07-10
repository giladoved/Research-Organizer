//
//  DisplayCardsViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 6/24/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddCardViewController.h"

@interface DisplayCardsViewController : UIViewController
@property (strong) NSMutableArray *cards;
@property (strong) NSMutableArray *cardViews;
@property (strong) NSMutableArray *retrievedViewLocations;
@end
