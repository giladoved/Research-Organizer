//
//  DisplayOutline.m
//  TermPaper2
//
//  Created by Gilad Oved on 7/15/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "DisplayOutline.h"
#import "DisplayCardsViewController.h"
#import "SimpleTableCell.h"

@implementation DisplayOutline


-(void) viewDidLoad
{
    self.points = [NSMutableArray new];
    self.quotes = [NSMutableArray new];
    self.citations = [NSMutableArray new];
    self.explanations = [NSMutableArray new];
    self.colors = [NSMutableArray new];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequestF = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
    self.cards = [[managedObjectContext executeFetchRequest:fetchRequestF error:nil] mutableCopy];
    
    for (int i = 0; i < self.cards.count; i++) {
        [self.points addObject:[[self.cards objectAtIndex:i] valueForKey:@"point"]];
        [self.quotes addObject:[[self.cards objectAtIndex:i] valueForKey:@"quote"]];
        [self.citations addObject:[[self.cards objectAtIndex:i] valueForKey:@"citation"]];
        [self.explanations addObject:[[self.cards objectAtIndex:i] valueForKey:@"explanation"]];
        [self.colors addObject:[[self.cards objectAtIndex:i] valueForKey:@"color"]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.points count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 330;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";

    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.backView.backgroundColor = [self getColorWithString:[self.colors objectAtIndex:indexPath.row]];
    cell.pointText.text = [self.points objectAtIndex:indexPath.row];
    cell.quoteText.text = [self.quotes objectAtIndex:indexPath.row];
    cell.explanationText.text = [self.explanations objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(UIColor *) getColorWithString:(NSString *)colorStr {
    if ([colorStr isEqualToString:@"Red"])
        return [UIColor redColor];
    if ([colorStr isEqualToString:@"Orange"])
        return [UIColor orangeColor];
    if ([colorStr isEqualToString:@"Yellow"])
        return [UIColor yellowColor];
    if ([colorStr isEqualToString:@"Green"])
        return [UIColor greenColor];
    if ([colorStr isEqualToString:@"Cyan"])
        return [UIColor cyanColor];
    if ([colorStr isEqualToString:@"Blue"])
        return [UIColor blueColor];
    if ([colorStr isEqualToString:@"Brown"])
        return [UIColor brownColor];
    if ([colorStr isEqualToString:@"Gray"])
        return [UIColor grayColor];
    if ([colorStr isEqualToString:@"Purple"])
        return [UIColor purpleColor];
    if ([colorStr isEqualToString:@"Magenta"])
        return [UIColor magentaColor];
    
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.points count];
    
    if (row < count) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

@end
