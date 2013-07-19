//
//  DisplayCardsViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 6/24/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "DisplayCardsViewController.h"
#import "AddCardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Card.h"

@interface DisplayCardsViewController () {
    UIButton *chooseColorBtn;
    NSArray *colorOptions;
    NSString *colorChoice;
    int currentColorIndex;
}
@property (nonatomic) NSMutableArray *coordinates;
@property (strong) UIViewController *cardInfo;
@end

@implementation DisplayCardsViewController

BOOL dragging;
float oldX, oldY;
CGPoint touchLoc;
int indexCard;

UITextView *point;
UITextView *quote;
UITextView *citation;
UITextView *explanation;


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequestF = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
    self.cards = [[managedObjectContext executeFetchRequest:fetchRequestF error:nil] mutableCopy];
    NSLog(@"card count: %i", self.cards.count);
    
    /*[self deleteAllObjectsForEntity:@"Flashcards" andContext:managedObjectContext];
    [self deleteAllObjectsForEntity:@"Layout" andContext:managedObjectContext];
    [self.cards removeAllObjects];
    [self.coordinates removeAllObjects];
    [self.retrievedViewLocations removeAllObjects];
    [self.cardViews removeAllObjects];*/
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[Card class]])
            [view removeFromSuperview];
    }
    
    NSFetchRequest *fetchRequestL = [[NSFetchRequest alloc] initWithEntityName:@"Layout"];
    NSMutableArray *layoutData = [[managedObjectContext executeFetchRequest:fetchRequestL error:nil] mutableCopy];
    if (layoutData.count > 0) {
        NSManagedObject *layoutObj = [layoutData objectAtIndex:0];
        NSString *layout = [NSString stringWithFormat:@"%@", [layoutObj valueForKey:@"layout"]];
        self.coordinates = [[layout componentsSeparatedByString:@";"] mutableCopy];
        if ([self.coordinates containsObject:@""]) {
            [self.coordinates removeLastObject];
        }
    }
    
    Card *theLabel = nil;
        
    for (int i = 0; i < [self.cards count]; i++) {
        NSManagedObject *card = [self.cards objectAtIndex:i];
        
        theLabel = [[Card alloc] initWithFrame:CGRectMake(
            self.view.frame.size.width / 2, self.view.frame.size.height / 2,
                                                     200.0,120.0)];
        theLabel.text = [NSString stringWithString:[card valueForKey:@"point"]];
        theLabel.color = [self getColorWithString:[card valueForKey:@"color"]];
        theLabel.index = [NSNumber numberWithInt:i];
        theLabel.backgroundColor = theLabel.color;
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = theLabel.text;
        [titleLabel setFrame:CGRectMake(5, 5, 190, 110)];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.numberOfLines = 5;
        titleLabel.backgroundColor = [UIColor clearColor];
        [theLabel addSubview:titleLabel];
        [self.view addSubview:theLabel];
        theLabel.userInteractionEnabled = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
        [theLabel addGestureRecognizer:tap];
        
        [self.cardViews addObject:theLabel];
    }
    
    for (int i = 0; i < [self.coordinates count]; i++) {
        NSString *temp = [self.coordinates objectAtIndex:i];
        NSArray *temp2 = [temp  componentsSeparatedByString:@","];
        CGFloat x = [[temp2 objectAtIndex:0] floatValue];
        CGFloat y = [[temp2 objectAtIndex:1] floatValue];
        [[self.cardViews objectAtIndex:i] setFrame:CGRectMake(x, y, theLabel.frame.size.width, theLabel.frame.size.height)];
    }
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

- (void)cardTapped:(UITapGestureRecognizer *)rec {
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 720)];
    scrollview.showsVerticalScrollIndicator=YES;
    scrollview.scrollEnabled=YES;
    scrollview.userInteractionEnabled=YES;
    
    Card *tappedLabel = (Card *)rec.view;
    self.cardInfo = [[UIViewController alloc] init];
    self.cardInfo.modalPresentationStyle = UIModalPresentationFormSheet;
    self.cardInfo.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.cardInfo animated:YES completion:nil];
    self.cardInfo.view.superview.frame = CGRectMake(0, 0, 540, 720); 
    self.cardInfo.view.superview.center = self.view.center;
    
    UIFont *theFont = [[UIFont alloc] init];
    theFont = [UIFont fontWithName:@"Helvetica" size:14];
    
    chooseColorBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    chooseColorBtn.frame = CGRectMake(25, 530, 78, 60);
    
    [chooseColorBtn setTitle:@"Choose Color" forState:UIControlStateNormal];
    [[chooseColorBtn titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
    [[chooseColorBtn titleLabel] setTextColor:[UIColor blackColor]];
    chooseColorBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [chooseColorBtn addTarget:self
               action:@selector(chooseColor:)
     forControlEvents:UIControlEventTouchDown];
    [self.cardInfo.view addSubview:chooseColorBtn];
    
    point = [[UITextView alloc] init];
    indexCard = [tappedLabel.index intValue];
    point.frame = CGRectMake(125, 50, 400, 50);
    point.backgroundColor = [UIColor whiteColor];
    point.tag = 0;
    point.font = theFont;
    point.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"point"]];
    
    UILabel *pointLbl = [UILabel new];
    pointLbl.text = @"Point";
    pointLbl.backgroundColor = [UIColor clearColor];
    pointLbl.frame = CGRectMake(25, 45, 100, 50);
    
    quote = [[UITextView alloc] init];
    quote.frame = CGRectMake(125, 130, 400, 200);
    quote.backgroundColor = [UIColor whiteColor];
    quote.tag = 1;
    quote.font = theFont;
    quote.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"quote"]];
    
    UILabel *quoteLbl = [UILabel new];
    quoteLbl.text = @"Quote";
    quoteLbl.backgroundColor = [UIColor clearColor];
    quoteLbl.frame = CGRectMake(25, 125, 100, 50);
    
    citation = [[UITextView alloc] init];
    citation.frame = CGRectMake(125, 365, 400, 50);
    citation.backgroundColor = [UIColor whiteColor];
    citation.tag = 2;
    citation.font = theFont;
    citation.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"citation"]];
    
    UILabel *citationLbl = [UILabel new];
    citationLbl.text = @"Citation";
    citationLbl.backgroundColor = [UIColor clearColor];
    citationLbl.frame = CGRectMake(25, 360, 100, 50);
    
    explanation = [[UITextView alloc] init];
    explanation.frame = CGRectMake(125, 450, 400, 200);
    explanation.backgroundColor = [UIColor whiteColor];
    explanation.tag = 3;
    explanation.font = theFont;
    explanation.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"explanation"]];
    
    UILabel *explanationLbl = [UILabel new];
    explanationLbl.text = @"Explanation";
    explanationLbl.backgroundColor = [UIColor clearColor];
    explanationLbl.frame = CGRectMake(25, 445, 100, 50);
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(20, 670, 150, 35);
    cancelButton.backgroundColor = [UIColor redColor];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self
                 action:@selector(cancelPopup)
       forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.frame = CGRectMake(350, 670, 150, 35);
    saveButton.backgroundColor = [UIColor blueColor];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self
                     action:@selector(savePopup)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteButton = [[UIButton alloc] init];
    deleteButton.frame = CGRectMake(185, 670, 150, 35);
    deleteButton.backgroundColor = [UIColor blackColor];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton setTitle:@"Delete Card" forState:UIControlStateNormal];
    [deleteButton addTarget:self
                   action:@selector(deleteCard)
         forControlEvents:UIControlEventTouchUpInside];

    [scrollview addSubview:point];
    [scrollview addSubview:pointLbl];
    [scrollview addSubview:quote];
    [scrollview addSubview:quoteLbl];
    [scrollview addSubview:citation];
    [scrollview addSubview:citationLbl];
    [scrollview addSubview:explanation];
    [scrollview addSubview:explanationLbl];
    [scrollview addSubview:chooseColorBtn];
    [scrollview addSubview:cancelButton];
    [scrollview addSubview:saveButton];
    [scrollview addSubview:deleteButton];
    [self.cardInfo.view addSubview:scrollview];
    scrollview.contentSize = CGSizeMake(self.cardInfo.view.frame.size.width, self.cardInfo.view.frame.size.height + 265);
}

-(IBAction)chooseColor:(id)sender {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *fixed1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixed2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems:[NSArray arrayWithObjects:fixed1, chooseButton, fixed2, nil]];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
    CGRect pickerFrame = pickerView.frame;
    pickerFrame.origin.y = toolbar.frame.size.height;
    [pickerView setFrame:pickerFrame];
    
    UIView *colorPopupView = [[UIView alloc] init];
    [colorPopupView addSubview:pickerView];
    [colorPopupView addSubview:toolbar];
    
    UIViewController *colorVC = [[UIViewController alloc] init];
    [colorVC setView:colorPopupView];
    [colorVC setContentSizeForViewInPopover:CGSizeMake(320, 260)];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:colorVC];
    
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [pickerView selectRow:currentColorIndex inComponent:0 animated:NO];
    
    NSLog(@"%@", chooseColorBtn);
    [popover presentPopoverFromRect:chooseColorBtn.bounds inView:chooseColorBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void) deleteCard {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Flashcards" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    
    [context deleteObject:[self.cards objectAtIndex:indexCard]];
    [self.cards removeObjectAtIndex:indexCard];
    if (![context save:&error]) {
    	NSLog(@"Error deleting card:%@",error);
    }
    
    NSString *layoutStr = [[NSString alloc] init];
    for (int i = 0; i < self.cards.count; i++) {
        if (i != indexCard) {
            UILabel *currentView = [self.cardViews objectAtIndex:i];
            layoutStr = [layoutStr stringByAppendingFormat:@"%f", currentView.frame.origin.x];
            layoutStr = [layoutStr stringByAppendingString:@","];
            layoutStr = [layoutStr stringByAppendingFormat:@"%f", currentView.frame.origin.y];
            layoutStr = [layoutStr stringByAppendingString:@";"];
        }
    }
        
    if ([self deleteAllObjectsForEntity:@"Layout" andContext:context]) {
        NSManagedObject *newLayout = [NSEntityDescription insertNewObjectForEntityForName:@"Layout" inManagedObjectContext:context];
        [newLayout setValue:layoutStr forKey:@"layout"];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        } else {
            NSLog(@"new layout saved!");
        }
    }
    
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Delete"
                                                    message:@"Card was successfully deleted!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.cardInfo dismissViewControllerAnimated:YES completion:nil];
    [self viewDidAppear:YES];
}

-(void) savePopup {
    if (point.text && quote.text && citation.text && explanation.text && colorChoice) {
        [[self.cards objectAtIndex:indexCard] setValue:point.text forKey:@"point"];
        [[self.cards objectAtIndex:indexCard] setValue:quote.text forKey:@"quote"];
        [[self.cards objectAtIndex:indexCard] setValue:citation.text forKey:@"citation"];
        [[self.cards objectAtIndex:indexCard] setValue:explanation.text forKey:@"explanation"];
        [[self.cards objectAtIndex:indexCard] setValue:colorChoice forKey:@"color"];
    
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }

        [self viewDidAppear:YES];
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Modified"
                                                    message:@"Card was successfully modified!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [alert show];
        [self.cardInfo dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do not leave textboxes blank"
                                                        message:@"All properties must be filled out! No blanks are allowed!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void) cancelPopup {
    [self.cardInfo dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLoc = touchLocation;
    if ([[touch.view class] isSubclassOfClass:[Card class]]) {
        dragging = YES;
        [self.view bringSubviewToFront:touch.view];
        oldX = touchLocation.x;
        oldY = touchLocation.y;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        dragging = NO;
        
        //save layout
        NSString *layoutStr = [[NSString alloc] init];
        for (int i = 0; i < self.cards.count; i++) {
            UILabel *currentView = [self.cardViews objectAtIndex:i];
            layoutStr = [layoutStr stringByAppendingFormat:@"%f", currentView.frame.origin.x];
            layoutStr = [layoutStr stringByAppendingString:@","];
            layoutStr = [layoutStr stringByAppendingFormat:@"%f", currentView.frame.origin.y];
            layoutStr = [layoutStr stringByAppendingString:@";"];
        }
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if ([self deleteAllObjectsForEntity:@"Layout" andContext:context]) {
            NSManagedObject *newLayout = [NSEntityDescription insertNewObjectForEntityForName:@"Layout" inManagedObjectContext:context];
            [newLayout setValue:layoutStr forKey:@"layout"];
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            } else {
                NSLog(@"new layout saved!");
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    if ([[touch.view class] isSubclassOfClass:[Card class]]) {
        UILabel *label = (UILabel *)touch.view;
        [self.view bringSubviewToFront:label];
        if (dragging) {
            CGRect frame = label.frame;
            frame.origin.x = label.frame.origin.x + touchLocation.x - oldX;
            frame.origin.y = label.frame.origin.y + touchLocation.y - oldY;
            label.frame = frame;
        }
    }
}

-(void)move:(id)sender {
	NSLog(@"See a move gesture");
    
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)self.view.gestureRecognizers;
    CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
    
    panRecognizer.view.center=CGPointMake(panRecognizer.view.center.x+translation.x, panRecognizer.view.center.y+ translation.y);
    
    [panRecognizer setTranslation:CGPointMake(0, 0) inView:panRecognizer.view];
}

- (IBAction)clearAll:(id)sender {
    [self deleteAllObjectsForEntity:@"Layout" andContext:[self managedObjectContext]];
    [self deleteAllObjectsForEntity:@"Flashcards" andContext:[self managedObjectContext]];
    [self performSelectorOnMainThread:@selector(viewDidAppear:) withObject:nil waitUntilDone:YES];
    NSLog(@"CLEAARRRRED!");
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [colorOptions count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [colorOptions objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pv didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    colorChoice = [colorOptions objectAtIndex:row];
    currentColorIndex = row;
    chooseColorBtn.layer.borderColor = [self getColorWithString:colorChoice].CGColor;
    chooseColorBtn.layer.borderWidth = 3.0f;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLoad {
    [super viewDidLoad];
    colorOptions = [NSArray arrayWithObjects:@"Gray", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown", nil];
    colorChoice = [NSString new];
    chooseColorBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    self.cards = [[NSMutableArray alloc] init];
    self.cardViews = [[NSMutableArray alloc] init];
    self.retrievedViewLocations = [[NSMutableArray alloc] init];
    self.coordinates = [[NSMutableArray alloc] init];
}

@end
