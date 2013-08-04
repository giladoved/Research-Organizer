//
//  PopViewController.h
//  TermPaper2
//
//  Created by Gilad Oved on 8/4/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol popViewControllerDelegate;
@interface PopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    id<popViewControllerDelegate> delegate;
    
    NSArray *array;
}

@property (nonatomic, assign) id<popViewControllerDelegate> delegate;


@end
@protocol popViewControllerDelegate

-(void) dismiss:(PopViewController *) controller;

@end
