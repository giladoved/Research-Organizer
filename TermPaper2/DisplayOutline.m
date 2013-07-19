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
    [self populateTable];
    [self deleteAllObjectsForEntity:@"Layout" andContext:[self managedObjectContext]];
}

-(void) populateTable {
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
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.points count];
    
    if (row < count) {
        [self.points removeObjectAtIndex:row];
        [self.quotes removeObjectAtIndex:row];
        [self.citations removeObjectAtIndex:row];
        [self.explanations removeObjectAtIndex:row];
        [self.colors removeObjectAtIndex:row];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Flashcards" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        [context deleteObject:[self.cards objectAtIndex:row]];
        [self.cards removeObjectAtIndex:row];
        if (![context save:&error]) {
            NSLog(@"Error deleting card:%@",error);
        }

    }
}

- (void)tableView:(UITableView *)tableView
didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self populateTable];
    [tableView reloadData];
}

-(BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
    
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
	// Delete the objects returned if the results weren't nil
	if (fetchResults != nil) {
		for (NSManagedObject *manObj in fetchResults) {
			[managedObjectContext deleteObject:manObj];
		}
	} else {
		NSLog(@"Couldn't delete objects for entity %@", entityName);
		return NO;
	}
    
	return YES;
}



@end
