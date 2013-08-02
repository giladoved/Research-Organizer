//
//  Card.h
//  TermPaper2
//
//  Created by Gilad Oved on 7/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic) CGPoint location;

@end
