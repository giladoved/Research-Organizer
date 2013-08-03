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
{
    BOOL editing;
}

-(void) viewDidLoad
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
    [self.navigationItem setLeftBarButtonItem:editButton];

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

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.cards count];
    
    if (row < count) {
        [self.points removeObjectAtIndex:row];
        [self.quotes removeObjectAtIndex:row];
        [self.citations removeObjectAtIndex:row];
        [self.explanations removeObjectAtIndex:row];
        [self.colors removeObjectAtIndex:row];
        
        [self.cards removeObjectAtIndex:row];
        
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView
didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
}

- (IBAction) EditTable:(id)sender{
    if(editing)
    {
        [super setEditing:NO animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self.tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        editing = NO;
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
        editing = YES;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editing == NO || !indexPath)
        return UITableViewCellEditingStyleNone;

    if (indexPath.row != [self.cards count]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id card = [self.cards objectAtIndex:fromIndexPath.row];
    [self.cards removeObjectAtIndex:fromIndexPath.row];
    [self.cards insertObject:card atIndex:toIndexPath.row];
    
    id point = [self.points objectAtIndex:fromIndexPath.row];
    [self.points removeObjectAtIndex:fromIndexPath.row];
    [self.points insertObject:point atIndex:toIndexPath.row];
    
    id quote = [self.quotes objectAtIndex:fromIndexPath.row];
    [self.quotes removeObjectAtIndex:fromIndexPath.row];
    [self.quotes insertObject:quote atIndex:toIndexPath.row];
    
    id expl = [self.explanations objectAtIndex:fromIndexPath.row];
    [self.explanations removeObjectAtIndex:fromIndexPath.row];
    [self.explanations insertObject:expl atIndex:toIndexPath.row];
    
    id color = [self.colors objectAtIndex:fromIndexPath.row];
    [self.colors removeObjectAtIndex:fromIndexPath.row];
    [self.colors insertObject:color atIndex:toIndexPath.row];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    for (int i = 0; i < self.cards.count; i++) {
        NSManagedObject *updatedCard = [self.cards objectAtIndex:i];
    
        [updatedCard setValue:self.points[i] forKey:@"point"];
        [updatedCard setValue:self.quotes[i] forKey:@"quote"];
        [updatedCard setValue:self.citations[i] forKey:@"citation"];
        [updatedCard setValue:self.explanations[i] forKey:@"explanation"];
    
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    
        NSLog(@"%i: Layout Saved", i);
    }
}

@end
