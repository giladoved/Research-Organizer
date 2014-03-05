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
#import "TopicCell.h"
#import "CreateEssayViewController.h"

@implementation DisplayOutline
{
    BOOL editing;
    UITableView *tableview;
    NSIndexPath *indexpath;
    int footnoteCount;
    NSMutableArray *footnotes;
}

-(void) viewDidLoad
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditTable:)];
    
    UIBarButtonItem *goBack = [[UIBarButtonItem alloc]
                               initWithTitle:@"Back"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(goBack:)];
    
    NSArray *arrBtns = [[NSArray alloc]initWithObjects:goBack,editButton, nil];
    self.navigationItem.leftBarButtonItems = arrBtns;
    self.navigationItem.title = @"Outline";
    
    UIBarButtonItem *createEssay = [[UIBarButtonItem alloc]
                               initWithTitle:@"Create Essay"
                               style:UIBarButtonItemStyleBordered
                               target:self
                                    action:@selector(goEssay:)];
    self.navigationItem.rightBarButtonItem = createEssay;

    self.points = [NSMutableArray new];
    self.quotes = [NSMutableArray new];
    self.citations = [NSMutableArray new];
    self.explanations = [NSMutableArray new];
    self.colors = [NSMutableArray new];
    self.xs = [NSMutableArray new];
    self.ys = [NSMutableArray new];
    footnotes = [NSMutableArray new];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequestF = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
    self.cards = [[managedObjectContext executeFetchRequest:fetchRequestF error:nil] mutableCopy];
    
    footnoteCount = 1;
    for (int i = 0; i < self.cards.count; i++) {
        [self.points addObject:[[self.cards objectAtIndex:i] valueForKey:@"point"]];
        [self.quotes addObject:[[self.cards objectAtIndex:i] valueForKey:@"quote"]];
        if (![[self.quotes objectAtIndex:i] isEqualToString:@"-999"]) {
            [footnotes addObject:[NSNumber numberWithInt:footnoteCount]];
            footnoteCount++;
        }else {
            [footnotes addObject:[NSNumber numberWithInt:0]];
        }
        [self.citations addObject:[[self.cards objectAtIndex:i] valueForKey:@"citation"]];
        [self.explanations addObject:[[self.cards objectAtIndex:i] valueForKey:@"explanation"]];
        [self.colors addObject:[[self.cards objectAtIndex:i] valueForKey:@"color"]];
        [self.xs addObject:[[self.cards objectAtIndex:i] valueForKey:@"locationX"]];
        [self.ys addObject:[[self.cards objectAtIndex:i] valueForKey:@"locationY"]];
    }
    NSLog(@"%@", footnotes);
    NSLog(@"citation: %@", self.citations);
}

-(IBAction)goEssay:(id)sender {
    UIStoryboard *storyboard = [self storyboard];
    CreateEssayViewController *createEssayVC = (CreateEssayViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CreateEssayViewController"];
    createEssayVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createEssayVC animated:YES];
}

-(IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cards count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[self.quotes objectAtIndex:indexPath.row] isEqualToString:@"-999"])
        return 330;
    return 120;
}

-(void)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest * allCards = [[NSFetchRequest alloc] init];
    [allCards setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
    [allCards setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *cards = [managedObjectContext executeFetchRequest:allCards error:&error];
    
    for (NSManagedObject *card in cards) {
        [managedObjectContext deleteObject:card];
    }
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableview = tableView;
    indexpath = indexPath;
    
    if (![[self.quotes objectAtIndex:indexPath.row] isEqualToString:@"-999"]) {
        SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:@"SimpleTableItem"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSString *currentQuote = [self.quotes objectAtIndex:indexPath.row];
        currentQuote = [currentQuote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([currentQuote characterAtIndex:0] == '<' && [currentQuote characterAtIndex:currentQuote.length-1] == '>') {
            NSLog(@"show image");
            cell.quoteText.hidden = YES;
            cell.quoteIV.hidden = NO;
            NSString *imageStr = [currentQuote substringWithRange:NSMakeRange(1, currentQuote.length - 2)];
            NSURL *imageURL = [NSURL URLWithString:imageStr];
            if (imageURL) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.quoteIV.image = [UIImage imageWithData:imageData];
                    });
                });
            }
            cell.quoteText.hidden = NO;
            if ([footnotes[indexPath.row] intValue] != 0)
            cell.quoteText.text = [NSString stringWithFormat:@"[%i]", [footnotes[indexPath.row] intValue]];
        } else {
            NSLog(@"show text");
            cell.quoteText.hidden = NO;
            cell.quoteIV.hidden = YES;
            if ([footnotes[indexPath.row] intValue] != 0)
            cell.quoteText.text = [NSString stringWithFormat:@"%@ [%i]", currentQuote, [footnotes[indexPath.row] intValue]];
        }
        
        cell.explanationText.text = [self.explanations objectAtIndex:indexPath.row];
        
        NSString *chosenColor = [self.colors objectAtIndex:indexPath.row];
        UIImage *colorImage;
        if ([chosenColor isEqualToString:@"Brown"] || [chosenColor isEqualToString:@"Green"]) {
            colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Card", chosenColor] ofType:@"jpg"]];
        } else {
            colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Card", chosenColor] ofType:@"png"]];
        }
        cell.imageBack.image = colorImage;
        cell.pointText.text = [self.points objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        TopicCell *cell = (TopicCell *)[tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TopicCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSString *chosenColor = [self.colors objectAtIndex:indexPath.row];
        UIImage *colorImage;
        if ([chosenColor isEqualToString:@"Brown"] || [chosenColor isEqualToString:@"Green"]) {
            colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Card", chosenColor] ofType:@"jpg"]];
        } else {
            colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Card", chosenColor] ofType:@"png"]];
        }
        cell.imageBack.image = colorImage;
        cell.topicTxt.text = [self.points objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
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
        [self.xs removeObjectAtIndex:row];
        [self.ys removeObjectAtIndex:row];
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
        [self deleteAllObjectsForEntity:@"Flashcards" andContext:[self managedObjectContext]];
        for (int i = 0; i < self.cards.count; i++) {
            NSManagedObject *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Flashcards" inManagedObjectContext:[self managedObjectContext]];
            NSLog(@"current point %@", self.points[i]);
            [newCard setValue:self.points[i] forKey:@"point"];
            [newCard setValue:self.quotes[i]  forKey:@"quote"];
            [newCard setValue:self.citations[i] forKey:@"citation"];
            [newCard setValue:self.explanations[i] forKey:@"explanation"];
            [newCard setValue:self.colors[i] forKey:@"color"];
            [newCard setValue:self.xs[i] forKey:@"locationX"];
            [newCard setValue:self.ys[i] forKey:@"locationY"];
            NSError *error = nil;
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        if (self.points.count > 0)
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        else
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        [self.tableView reloadData];
        [self.navigationItem.leftBarButtonItems[1] setTitle:@"Edit"];
        editing = NO;
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.tableView reloadData];
        [self.navigationItem.leftBarButtonItems[1] setTitle:@"Done"];
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
    
    id cita = [self.citations objectAtIndex:fromIndexPath.row];
    [self.citations removeObjectAtIndex:fromIndexPath.row];
    [self.citations insertObject:cita atIndex:toIndexPath.row];
    
    id color = [self.colors objectAtIndex:fromIndexPath.row];
    [self.colors removeObjectAtIndex:fromIndexPath.row];
    [self.colors insertObject:color atIndex:toIndexPath.row];
    
    id theX = [self.xs objectAtIndex:fromIndexPath.row];
    [self.xs removeObjectAtIndex:fromIndexPath.row];
    [self.xs insertObject:theX atIndex:toIndexPath.row];
    
    id theY = [self.ys objectAtIndex:fromIndexPath.row];
    [self.ys removeObjectAtIndex:fromIndexPath.row];
    [self.ys insertObject:theY atIndex:toIndexPath.row];
    
    NSLog(@"citations: %@", self.citations);

}

@end
