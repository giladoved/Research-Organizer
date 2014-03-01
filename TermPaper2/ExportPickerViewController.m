//
//  ExportPickerViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 8/4/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "ExportPickerViewController.h"

@interface ExportPickerViewController ()

@end

@implementation ExportPickerViewController

-(id)initWithStyle:(UITableViewStyle)style
{
    if ([super initWithStyle:style] != nil) {
        
        _array = [NSMutableArray array];
        
        //Set up the array of colors.
        [_array addObject:@"Copy"];
        [_array addObject:@"Email"];
        [_array addObject:@"iMessage"];
        
        //Make row selections persist.
        //self.clearsSelectionOnViewWillAppear = NO;
        
        NSInteger rowsCount = [_array count];
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView
                                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSInteger totalRowsHeight = rowsCount * singleRowHeight;
        
        //Calculate how wide the view should be by finding how
        //wide each string is expected to be
        CGFloat largestLabelWidth = 0;
        for (NSString *option in _array) {
            //Checks size of text using the default font for UITableViewCell's textLabel.
            CGSize labelSize = [option sizeWithFont:[UIFont fontWithName:@"Times New Roman" size:16.0f]];
            if (labelSize.width > largestLabelWidth) {
                largestLabelWidth = labelSize.width;
            }
        }
        
        //Add a little padding to the width
        CGFloat popoverWidth = largestLabelWidth + 100;
        
        //Set the property to tell the popover container how big this view will be.
        self.preferredContentSize = CGSizeMake(popoverWidth, totalRowsHeight);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_array objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedColorName = [_array objectAtIndex:indexPath.row];
    
    //Create a variable to hold the color, making its default
    //color something annoying and obvious so you can see if
    //you've missed a case here.
    
    //Set the color object based on the selected color name.
    
    //Notify the delegate if it exists.
    if (_delegate != nil) {
        [_delegate selectedOption:selectedColorName];
    }
}

@end
