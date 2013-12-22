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
    UIPickerView *pickerView;
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
    
    self.points = [NSMutableArray new];
    self.quotes = [NSMutableArray new];
    self.citations = [NSMutableArray new];
    self.explanations = [NSMutableArray new];
    
    colorOptions = [NSArray arrayWithObjects:@"Gray", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown", nil];
    
    UIImage *backImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"WhiteBackground" ofType:@"png"]];
    UIImageView *backIV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backIV.image = backImage;
    backIV.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backIV];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[Card class]])
            [view removeFromSuperview];
    }
        
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
    self.cards = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.cardViews = [NSMutableArray new];
    
     /*[self deleteAllObjectsForEntity:@"Flashcards" andContext:managedObjectContext];
     [self deleteAllObjectsForEntity:@"Results" andContext:managedObjectContext];
     [self.cards removeAllObjects];
     [self.coordinates removeAllObjects];
     [self.retrievedViewLocations removeAllObjects];
     [self.cardViews removeAllObjects];*/
    
    UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]
                               initWithTitle:@"Export"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(exportCards:)];

    self.navigationItem.rightBarButtonItems =  @[self.navigationItem.rightBarButtonItem, exportBtn];
    
    NSLog(@"%@", self.quotes);
    if (self.cards.count > 0) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        for (int i = 0; i < [self.cards count]; i++) {
            NSManagedObject *card = [self.cards objectAtIndex:i];
            
            float x = [[card valueForKey:@"locationX"] floatValue];
            float y = [[card valueForKey:@"locationY"] floatValue];
            Card *currentCard;
            if (![[card valueForKey:@"explanation"] isEqualToString:@"-999"])
                currentCard = [[Card alloc] initWithFrame:CGRectMake(x, y, 200.0,120.0)];
            else
                currentCard = [[Card alloc] initWithFrame:CGRectMake(x, y, 250.0,75.0)];

            currentCard.text = [NSString stringWithString:[card valueForKey:@"point"]];
            NSLog(@"%@: %f by %f", currentCard.text, x, y);
            currentCard.color = [self getColorWithString:[card valueForKey:@"color"]];
            currentCard.index = i;
            
            NSString *chosenColor = [card valueForKey:@"color"];
            UIImage *colorImage;
            if ([chosenColor isEqualToString:@"Brown"] || [chosenColor isEqualToString:@"Green"]) {
                colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Card", chosenColor] ofType:@"jpg"]];
            } else {
                colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Card", chosenColor] ofType:@"png"]];
            }
            
            UIImageView *colorIV = [[UIImageView alloc] initWithFrame:currentCard.bounds];
            colorIV.image = colorImage;
            colorIV.contentMode = UIViewContentModeScaleToFill;
            [currentCard addSubview:colorIV];
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = currentCard.text;
            if (![[card valueForKey:@"explanation"] isEqualToString:@"-999"]) {
                titleLabel.numberOfLines = 5;
                [titleLabel setFrame:CGRectMake(30, 10, 150, 95)];
            }
            else {
                [titleLabel setFrame:CGRectMake(35, 10, 195, 55)];
                titleLabel.numberOfLines = 3;
            }
            titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            titleLabel.backgroundColor = [UIColor clearColor];
            [currentCard addSubview:titleLabel];
            [self.view addSubview:currentCard];
            currentCard.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
            [currentCard addGestureRecognizer:tap];
            
            [self.cardViews addObject:currentCard];
        }
    } else {
        self.navigationItem.leftBarButtonItem.enabled = NO;
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


-(IBAction)exportCards:(id)sender {
    NSLog(@"exporting cards");
    
    for (int i = 0; i < self.cards.count; i++) {
        NSManagedObject *card = [self.cards objectAtIndex:i];
        [self.points addObject:[card valueForKey:@"point"]];
        [self.quotes addObject:[card valueForKey:@"quote"]];
        [self.explanations addObject:[card valueForKey:@"explanation"]];
        [self.citations addObject:[card valueForKey:@"citation"]];
    }

    NSMutableString *emailText = [NSMutableString new];
    [emailText appendString:@"<html><body>"];
    
    BOOL withTopics = NO;
    for (int i = 0; i < self.quotes.count; i++) {
        if ([[self.quotes objectAtIndex:i] isEqualToString:@"-999"]) {
            withTopics = YES;
            [emailText appendString:@"<h3>Topic Sentences</h3>"];
            break;
        }
    }
    if (withTopics) {
        for (int i = 0; i < self.quotes.count; i++) {
            Card *currentCard = [self.cards objectAtIndex:i];
            if ([[self.quotes objectAtIndex:i] isEqualToString:@"-999"]){
                [emailText appendFormat:@"<p style=\"color:%@\">%@</p>", [currentCard valueForKey:@"color"], self.points[i]];
            }
        }
        [emailText appendString:@"</br>"];
    }

    [emailText appendString:@"<h3>PIE Cards</h3>"];
    for (int i = 0; i < self.quotes.count; i++) {
        Card *currentCard = [self.cards objectAtIndex:i];
        if (![[self.quotes objectAtIndex:i] isEqualToString:@"-999"]){
            [emailText appendFormat:@"<p style=\"color:%@\">Point: %@</p>", [currentCard valueForKey:@"color"], self.points[i]];
            [emailText appendFormat:@"<p style=\"color:%@\">Illustration: %@</p>", [currentCard valueForKey:@"color"], self.quotes[i]];
            [emailText appendFormat:@"<p style=\"color:%@\">Explanation: %@</p>", [currentCard valueForKey:@"color"], self.explanations[i]];
            [emailText appendFormat:@"<p style=\"color:%@\">Citation: %@</p>", [currentCard valueForKey:@"color"], self.citations[i]];
        }
        [emailText appendString:@"</br>"];
    }
    
    [emailText appendString:@"</body></html>"];
    NSLog(@"emailText : %@", emailText);
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Note Cards"];
    [mc setMessageBody:[emailText copy] isHTML:YES];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Email sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
}


- (void)cardTapped:(UITapGestureRecognizer *)rec {
    Card *tappedLabel = (Card *)rec.view;
    indexCard = tappedLabel.index;
    self.cardInfo = [[UIViewController alloc] init];
    self.cardInfo.modalPresentationStyle = UIModalPresentationFormSheet;
    self.cardInfo.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.cardInfo animated:YES completion:nil];
    self.cardInfo.view.superview.center = self.view.center;
    
    UIScrollView *scrollview;
    if (![[[self.cards objectAtIndex:indexCard] valueForKey:@"quote"] isEqualToString:@"-999"]) {
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 720)];
        scrollview.showsVerticalScrollIndicator=YES;
        scrollview.scrollEnabled=YES;
        self.cardInfo.view.superview.frame = CGRectMake(0, 0, 540, 720);
    }
    else {
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 320)];
        scrollview.showsVerticalScrollIndicator=NO;
        scrollview.scrollEnabled=NO;
        self.cardInfo.view.superview.frame = CGRectMake(0, 0, 540, 320);
    }
    
    UIImage *colorImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"EditCardBackground" ofType:@"png"]];
    
    UIImageView *colorIV = [[UIImageView alloc] initWithFrame:self.cardInfo.view.bounds];
    colorIV.image = colorImage;
    colorIV.contentMode = UIViewContentModeScaleToFill;
    [self.cardInfo.view addSubview:colorIV];
    
    scrollview.userInteractionEnabled=YES;
    
    UIFont *theFont = [[UIFont alloc] init];
    theFont = [UIFont fontWithName:@"Helvetica" size:14];
    
    chooseColorBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    chooseColorBtn.frame = CGRectMake(25, 100, 78, 60);
    chooseColorBtn.backgroundColor = [UIColor lightGrayColor];
    [chooseColorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chooseColorBtn setTitle:@"Choose Color" forState:UIControlStateNormal];
    [[chooseColorBtn titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
    [[chooseColorBtn titleLabel] setTextColor:[UIColor blackColor]];
    chooseColorBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [chooseColorBtn addTarget:self
               action:@selector(chooseColor:)
     forControlEvents:UIControlEventTouchDown];
    [self.cardInfo.view addSubview:chooseColorBtn];
    
    point = [[UITextView alloc] init];
    point.frame = CGRectMake(125, 10, 400, 50);
    point.backgroundColor = [UIColor whiteColor];
    point.tag = 0;
    point.font = theFont;
    point.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"point"]];
    
    UILabel *pointLbl = [UILabel new];
    pointLbl.text = @"Point";
    pointLbl.backgroundColor = [UIColor clearColor];
    pointLbl.textColor = [UIColor whiteColor];
    pointLbl.frame = CGRectMake(25, 5, 100, 50);
    
    UILabel *quoteLbl;
    UILabel *citationLbl;
    UILabel *explanationLbl;
    
    if (![[[self.cards objectAtIndex:indexCard] valueForKey:@"quote"] isEqualToString:@"-999"]) {
        chooseColorBtn.frame = CGRectMake(25, 530, 78, 60);

        quote = [[UITextView alloc] init];
        quote.frame = CGRectMake(125, 90, 400, 200);
        quote.backgroundColor = [UIColor whiteColor];
        quote.tag = 1;
        quote.font = theFont;
        quote.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"quote"]];
        
        quoteLbl = [UILabel new];
        quoteLbl.text = @"Quote";
        quoteLbl.textColor = [UIColor whiteColor];
        quoteLbl.backgroundColor = [UIColor clearColor];
        quoteLbl.frame = CGRectMake(25, 85, 100, 50);
        
        citation = [[UITextView alloc] init];
        citation.frame = CGRectMake(125, 325, 400, 50);
        citation.backgroundColor = [UIColor whiteColor];
        citation.tag = 2;
        citation.font = theFont;
        citation.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"citation"]];
        
        citationLbl = [UILabel new];
        citationLbl.text = @"Citation";
        citationLbl.textColor = [UIColor whiteColor];
        citationLbl.backgroundColor = [UIColor clearColor];
        citationLbl.frame = CGRectMake(25, 320, 100, 50);
        
        explanation = [[UITextView alloc] init];
        explanation.frame = CGRectMake(125, 410, 400, 200);
        explanation.backgroundColor = [UIColor whiteColor];
        explanation.tag = 3;
        explanation.font = theFont;
        explanation.text = [NSString stringWithFormat:@"%@ ", [[self.cards objectAtIndex:indexCard] valueForKey:@"explanation"]];
        
        explanationLbl = [UILabel new];
        explanationLbl.text = @"Explanation";
        explanationLbl.textColor = [UIColor whiteColor];
        explanationLbl.backgroundColor = [UIColor clearColor];
        explanationLbl.frame = CGRectMake(25, 405, 100, 50);
    }
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(20, 630, 150, 35);
    cancelButton.backgroundColor = [UIColor redColor];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self
                 action:@selector(cancelPopup)
       forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.frame = CGRectMake(350, 630, 150, 35);
    saveButton.backgroundColor = [UIColor blueColor];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self
                     action:@selector(savePopup)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteButton = [[UIButton alloc] init];
    deleteButton.frame = CGRectMake(185, 630, 150, 35);
    deleteButton.backgroundColor = [UIColor blackColor];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton setTitle:@"Delete Card" forState:UIControlStateNormal];
    [deleteButton addTarget:self
                   action:@selector(deleteCard)
         forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[self.cards objectAtIndex:indexCard] valueForKey:@"quote"] isEqualToString:@"-999"]) {
        cancelButton.frame = CGRectMake(20, 270, 150, 35);
        saveButton.frame = CGRectMake(350, 270, 150, 35);
        deleteButton.frame = CGRectMake(185, 270, 150, 35);
    }
    
    int row = [colorOptions indexOfObject:[[self.cards objectAtIndex:indexCard] valueForKey:@"color"]];
    colorChoice = [colorOptions objectAtIndex:row];
    currentColorIndex = row;
    chooseColorBtn.layer.borderColor = [self getColorWithString:colorChoice].CGColor;
    chooseColorBtn.layer.borderWidth = 3.0f;

    [scrollview addSubview:point];
    [scrollview addSubview:pointLbl];
    if (![[[self.cards objectAtIndex:indexCard] valueForKey:@"quote"] isEqualToString:@"-999"]) {
        [scrollview addSubview:quote];
        [scrollview addSubview:quoteLbl];
        [scrollview addSubview:citation];
        [scrollview addSubview:citationLbl];
        [scrollview addSubview:explanation];
        [scrollview addSubview:explanationLbl];
    }
    [scrollview addSubview:chooseColorBtn];
    [scrollview addSubview:cancelButton];
    [scrollview addSubview:saveButton];
    [scrollview addSubview:deleteButton];
    [self.cardInfo.view addSubview:scrollview];
    scrollview.contentSize = CGSizeMake(self.cardInfo.view.frame.size.width, self.cardInfo.view.frame.size.height + 265);
}

-(IBAction)chooseColor:(id)sender {
    colorChoice = [colorOptions objectAtIndex:currentColorIndex];
    chooseColorBtn.layer.borderColor = [self getColorWithString:colorChoice].CGColor;
    chooseColorBtn.layer.borderWidth = 3.0f;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose Color" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *fixed1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixed2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems:[NSArray arrayWithObjects:fixed1, chooseButton, fixed2, nil]];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
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
    
        
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Delete"
    //                                                message:@"Card was successfully deleted!"
    //                                               delegate:nil
    //                                      cancelButtonTitle:@"OK"
    //                                      otherButtonTitles:nil];
    //[alert show];
    [self.cardInfo dismissViewControllerAnimated:YES completion:nil];
    [self viewDidAppear:YES];
}

-(void) savePopup {
    if ([point.text isEqualToString:@""])
        point.text = @" ";
    if ([quote.text isEqualToString:@""])
        quote.text = @" ";
    if ([citation.text isEqualToString:@""])
        citation.text = @" ";
    if ([explanation.text isEqualToString:@""])
        explanation.text = @" ";

    [[self.cards objectAtIndex:indexCard] setValue:point.text forKey:@"point"];
    if (citation.text || [citation.text isEqualToString:@"-999"]) {
        [[self.cards objectAtIndex:indexCard] setValue:quote.text forKey:@"quote"];
        [[self.cards objectAtIndex:indexCard] setValue:citation.text forKey:@"citation"];
        [[self.cards objectAtIndex:indexCard] setValue:explanation.text forKey:@"explanation"];
    }
    [[self.cards objectAtIndex:indexCard] setValue:colorChoice forKey:@"color"];
    //float frameX = [[self.cardViews objectAtIndex:indexCard] frame].origin.x;
    //[[self.cards objectAtIndex:indexCard] setValue:[NSNumber numberWithFloat:frameX] forKey:@"locationX"];
    //float frameY = [[self.cardViews objectAtIndex:indexCard] frame].origin.x;
    //[[self.cards objectAtIndex:indexCard] setValue:[NSNumber numberWithFloat:frameY] forKey:@"locationY"];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self viewDidAppear:YES];
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Modified"
    //                                                message:@"Card was successfully modified!"
    //                                               delegate:nil
    //                                      cancelButtonTitle:@"OK"
    //                                      otherButtonTitles:nil];
    //[alert show];
    [self.cardInfo dismissViewControllerAnimated:YES completion:nil];
    [self viewDidAppear:YES];
}

-(void) cancelPopup {
    [self.cardInfo dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLoc = touchLocation;
    if ([[touch.view class] isSubclassOfClass:[Card class]]) {
        Card *clickedCard = (Card *)touch.view;
        indexCard = clickedCard.index;
        dragging = YES;
        [self.view bringSubviewToFront:touch.view];
        oldX = touchLocation.x;
        oldY = touchLocation.y;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        dragging = NO;
        
        UITouch *touch = [[event allTouches] anyObject];
        Card *clickedCard;
        if ([[touch.view class] isSubclassOfClass:[Card class]]) {
            clickedCard = (Card *)touch.view;
        }
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *updatedCard = [self.cards objectAtIndex:indexCard];
        
        [updatedCard setValue:[NSNumber numberWithFloat:clickedCard.frame.origin.x] forKey:@"locationX"];
        [updatedCard setValue:[NSNumber numberWithFloat:clickedCard.frame.origin.y] forKey:@"locationY"];

        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        NSLog(@"Layout Saved");
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    if ([[touch.view class] isSubclassOfClass:[Card class]]) {
        Card *movingCard = (Card *)touch.view;
        [self.view bringSubviewToFront:movingCard];
        if (dragging) {
            CGRect frame = movingCard.frame;
            frame.origin.x = movingCard.frame.origin.x + touchLocation.x - oldX;
            frame.origin.y = movingCard.frame.origin.y + touchLocation.y - oldY;
            movingCard.frame = frame;
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
    [self deleteAllObjectsForEntity:@"Flashcards" andContext:[self managedObjectContext]];
    [self performSelectorOnMainThread:@selector(viewDidAppear:) withObject:nil waitUntilDone:YES];
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

-(CGRect)currentScreenBoundsBasedOnOrientation
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenBounds);
    CGFloat height = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    colorOptions = [NSArray arrayWithObjects:@"Gray", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown", nil];
    chooseColorBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    self.cards = [[NSMutableArray alloc] init];
    self.cardViews = [[NSMutableArray alloc] init];
    self.retrievedViewLocations = [[NSMutableArray alloc] init];
    self.coordinates = [[NSMutableArray alloc] init];
}

@end
