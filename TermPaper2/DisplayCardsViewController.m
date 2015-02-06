//
//  DisplayCardsViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 6/24/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "DisplayCardsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Card.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

#define kCardCheck @"-999"

@interface DisplayCardsViewController () {
    UIButton *chooseColorBtn;
    NSArray *colorOptions;
    NSString *colorChoice;
    int currentColorIndex;
    UIPickerView *pickerView;
    UIImageView *quoteIV;
    NSString *writtenPoint;
    BOOL isTopic;
    UIScrollView *scrollview;
    UIButton *saveButton;
    NSDictionary *colorReferences;
    PFUser *currentUser;
    
    UITextView *point;
    UITextView *quote;
    UITextView *citation;
    UITextView *explanation;
    
    BOOL isCardBeingDragged;
    BOOL isCardBeingMoved;
    float lastXLocation, lastYLocation;
    int indexOfChosenCard;
    
    UIViewController *displayCardViewController;
    BOOL isNewCard;
    BOOL isNewCardaTopicCard;
    
    UIView *movieFrame;
    //YTPlayerView *playerView;
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
}
@end

@implementation DisplayCardsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    colorOptions = @[@"Gray", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown"];
    colorReferences = @{@"Gray":[UIColor grayColor], @"Red":[UIColor redColor], @"Green":[UIColor greenColor], @"Blue" : [UIColor blueColor], @"Cyan" : [UIColor cyanColor], @"Yellow": [UIColor yellowColor], @"Magenta" : [UIColor magentaColor], @"Orange" : [UIColor orangeColor], @"Purple" : [UIColor purpleColor], @"Brown" : [UIColor brownColor]};
    
    chooseColorBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    displayCardViewController = [UIViewController new];
    
    //[self clearCards];
    
    self.cards = [NSMutableArray new];
    self.parseCards = [NSMutableArray new];
    self.cardViews = [NSMutableArray new];
    self.retrievedViewLocations = [NSMutableArray new];
    self.points = [NSMutableArray new];
    self.quotes = [NSMutableArray new];
    self.citations = [NSMutableArray new];
    self.explanations = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    currentUser = [PFUser currentUser];
    
    //have the user login / register
    if (!currentUser) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    else {
        self.points = [NSMutableArray new];
        self.quotes = [NSMutableArray new];
        self.citations = [NSMutableArray new];
        self.explanations = [NSMutableArray new];
        
        UIImage *backImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"WhiteBackground" ofType:@"png"]];
        UIImageView *backIV = [[UIImageView alloc] initWithFrame:self.view.bounds];
        backIV.image = backImage;
        backIV.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:backIV];
        
        //playerView = [[YTPlayerView alloc] initWithFrame:CGRectMake(50, 50, 250, 250)];
        //[playerView loadWithVideoId:@"M7lc1UVf-VE"];
        //[self.view addSubview:playerView];
        
        
        //remove all cards from the screen
        for (UIView *view in self.view.subviews)
        {
            if ([view isKindOfClass:[Card class]])
                [view removeFromSuperview];
        }
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
        self.cards = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        self.cardViews = [NSMutableArray new];
        
        UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Export"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action:@selector(exportCards:)];
        UIBarButtonItem *resetBtn = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Restore Data"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(resetData:)];
        UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Logout"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(logOut:)];
        
        self.navigationItem.rightBarButtonItems =  @[self.navigationItem.rightBarButtonItem, resetBtn, logoutBtn, exportBtn];
        
        if (self.cards.count > 0) {
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [exportBtn setEnabled:YES];
            for (int i = 0; i < [self.cards count]; i++) {
                NSManagedObject *card = [self.cards objectAtIndex:i];
                
                float x = [[card valueForKey:@"locationX"] floatValue];
                float y = [[card valueForKey:@"locationY"] floatValue];
                Card *currentCard;
                if (![[card valueForKey:@"explanation"] isEqualToString:kCardCheck])
                    currentCard = [[Card alloc] initWithFrame:CGRectMake(x, y, 200.0,120.0)];
                else
                    currentCard = [[Card alloc] initWithFrame:CGRectMake(x, y, 250.0,75.0)];
                
                currentCard.text = [NSString stringWithString:[card valueForKey:@"point"]];
                currentCard.color = colorReferences[[card valueForKey:@"color"]];
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
                if (![[card valueForKey:@"explanation"] isEqualToString:kCardCheck]) {
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
                
                
                //coming soon
                /*UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]
                   initWithTarget:self action:@selector(deleteCard)];
                longpress.minimumPressDuration = 1;
                longpress.delegate = self;
                longpress.delaysTouchesBegan = YES;
                indexOfChosenCard = currentCard.index;
                [currentCard addGestureRecognizer:longpress];*/
                
                [self.cardViews addObject:currentCard];
            }
        } else {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [exportBtn setEnabled:NO];
        }
    }
    
}

-(IBAction)logOut:(id)sender {
    [PFUser logOut];
    [self viewDidAppear:YES];
}

-(IBAction)resetData:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Reset Data"
                                                      message:@"Are you sure you want to reset all of your data? This will delete all of the data and work you have done on your ipad and will restore the data saved for you on the cloud?"
                                                     delegate:self
                                            cancelButtonTitle:@"Yes"
                                            otherButtonTitles:@"No", nil];
    [message show];
}


- (IBAction)addNewCardPressed:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Reset Data"
                                                      message:@"What kind of card do you want to make?"
                                                     delegate:self
                                            cancelButtonTitle:@"Topic Sentence Card"
                                            otherButtonTitles:@"Information Card", nil];
    [message show];
}


-(IBAction)exportCards:(id)sender {
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
        if ([[self.quotes objectAtIndex:i] isEqualToString:kCardCheck]) {
            withTopics = YES;
            [emailText appendString:@"<h3>Topic Sentences</h3>"];
            break;
        }
    }
    
    if (withTopics) {
        for (int i = 0; i < self.quotes.count; i++) {
            Card *currentCard = [self.cards objectAtIndex:i];
            if ([[self.quotes objectAtIndex:i] isEqualToString:kCardCheck]){
                [emailText appendFormat:@"<p style=\"color:%@\">%@</p>", [currentCard valueForKey:@"color"], self.points[i]];
            }
        }
        [emailText appendString:@"</br>"];
    }

    [emailText appendString:@"<h3>PIE Cards</h3>"];
    for (int i = 0; i < self.quotes.count; i++) {
        Card *currentCard = [self.cards objectAtIndex:i];
        if (![[self.quotes objectAtIndex:i] isEqualToString:kCardCheck]){
            [emailText appendFormat:@"<p style=\"color:%@\">Point: %@</p>", [currentCard valueForKey:@"color"], self.points[i]];
            if ([self.quotes[i] characterAtIndex:0] == '<') {
                NSString *imgURL = [[self.quotes[i] substringFromIndex:1] substringToIndex:[self.quotes[i] length] - 2];
                [emailText appendFormat:@"<p style=\"color:%@\">Illustration: %@</p>", [currentCard valueForKey:@"color"], [NSString stringWithFormat:@"[%@]", imgURL]];
            } else {
                [emailText appendFormat:@"<p style=\"color:%@\">Illustration: %@</p>", [currentCard valueForKey:@"color"], self.quotes[i]];
            }
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

-(void) clearCards {
    [self deleteAllObjectsForEntity:@"Flashcards" andContext:[self managedObjectContext]];
    [self.cards removeAllObjects];
    [self.retrievedViewLocations removeAllObjects];
    [self.cardViews removeAllObjects];
    [self viewDidAppear:NO];
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

-(void) presentDetailCardController:(id)chosenCard {
    displayCardViewController = [[UIViewController alloc] init];
    displayCardViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    displayCardViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:displayCardViewController animated:YES completion:nil];
    displayCardViewController.view.superview.center = self.view.center;
    
    if ((isNewCard && !isNewCardaTopicCard) || (chosenCard && ![[chosenCard valueForKey:@"quote"] isEqualToString:kCardCheck] && !isNewCard)) {
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 720)];
        scrollview.showsVerticalScrollIndicator=YES;
        scrollview.scrollEnabled=YES;
        displayCardViewController.view.superview.frame = CGRectMake(0, 0, 540, 720);
    }
    else {
        scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 540, 320)];
        scrollview.showsVerticalScrollIndicator=NO;
        scrollview.scrollEnabled=NO;
        displayCardViewController.view.superview.frame = CGRectMake(0, 0, 540, 320);
    }
    
    UIImage *editCardBackground = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"EditCardBackground" ofType:@"png"]];
    UIImageView *editCardImageView = [[UIImageView alloc] initWithFrame:displayCardViewController.view.bounds];
    editCardImageView.image = editCardBackground;
    editCardImageView.contentMode = UIViewContentModeScaleToFill;
    [displayCardViewController.view addSubview:editCardImageView];
    
    scrollview.userInteractionEnabled=YES;
    
    UIFont *theFont = [UIFont fontWithName:@"Helvetica" size:14];
    
    chooseColorBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    chooseColorBtn.frame = CGRectMake(25, 100, 78, 60);
    chooseColorBtn.backgroundColor = [UIColor lightGrayColor];
    [chooseColorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chooseColorBtn setTitle:@"Choose Color" forState:UIControlStateNormal];
    [[chooseColorBtn titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
    [[chooseColorBtn titleLabel] setTextColor:[UIColor blackColor]];
    chooseColorBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [chooseColorBtn addTarget:self
                       action:@selector(chooseColor)
             forControlEvents:UIControlEventTouchDown];
    [displayCardViewController.view addSubview:chooseColorBtn];
    
    point = [[UITextView alloc] init];
    point.frame = CGRectMake(125, 10, 400, 50);
    point.backgroundColor = [UIColor whiteColor];
    point.tag = 0;
    point.font = theFont;
    point.returnKeyType = UIReturnKeyDefault;
    isTopic = YES;
    point.delegate = self;
    if (!isNewCard)
        point.text = [NSString stringWithFormat:@"%@", [chosenCard valueForKey:@"point"]];
    writtenPoint = point.text;
    
    UILabel *pointLbl = [UILabel new];
    pointLbl.text = @"Point/Title";
    pointLbl.backgroundColor = [UIColor clearColor];
    pointLbl.textColor = [UIColor whiteColor];
    pointLbl.frame = CGRectMake(25, 5, 100, 50);
    
    UILabel *quoteLbl;
    UILabel *citationLbl;
    UILabel *explanationLbl;
    UIButton *changeMediaBtn;
    UIButton *removeMediaBtn;
    movieFrame = [[UIView alloc] initWithFrame:CGRectMake(125, 90, 400, 200)];
    
    if ((isNewCard && !isNewCardaTopicCard) || (chosenCard && ![[chosenCard valueForKey:@"quote"] isEqualToString:kCardCheck] && !isNewCard)) {
        chooseColorBtn.frame = CGRectMake(25, 530, 78, 60);
        
        point.returnKeyType = UIReturnKeyNext;
        isTopic = NO;
        
        NSString *quoteStr = [chosenCard valueForKey:@"quote"];
        quoteStr = [quoteStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        quote = [[UITextView alloc] init];
        quote.frame = CGRectMake(125, 90, 400, 200);
        quote.backgroundColor = [UIColor whiteColor];
        quote.tag = 1;
        quote.font = theFont;
        quote.returnKeyType = UIReturnKeyNext;
        quote.delegate = self;
        if (!isNewCard)
            quote.text = [NSString stringWithFormat:@"%@", quoteStr];
        quoteIV = [[UIImageView alloc] initWithFrame:CGRectMake(125, 90, 400, 200)];
        quoteIV.contentMode = UIViewContentModeScaleAspectFit;
        
        quoteIV.hidden = YES;
        quote.hidden = YES;
        movieFrame.hidden  = NO;
        
        NSString *imageStr = [quoteStr substringWithRange:NSMakeRange(1, quoteStr.length - 2)];
        BOOL isPicture = ([quoteStr characterAtIndex:0] == '<');
        NSURL *imageURL = [NSURL URLWithString:imageStr];
        if (imageURL && !isNewCard) {
            if (isPicture) {
                quoteIV.hidden = NO;
                movieFrame.hidden  = YES;
                quote.hidden = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        quoteIV.image = [UIImage imageWithData:imageData];
                    });
                });
            } else {
                NSRange range = [imageStr rangeOfString:@"v="];
                NSString *identifier;
                if (range.location == NSNotFound) {
                    NSLog(@"string was not found");
                } else {
                    NSLog(@"position %lu", (unsigned long)range.location);
                    identifier = [imageStr substringFromIndex:range.location];
                    identifier = [identifier substringFromIndex:2];
                }
                videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:identifier];
                [videoPlayerViewController presentInView:movieFrame];
                [videoPlayerViewController.moviePlayer play];
            }
        }
        
        if ([quoteStr characterAtIndex:0] == '<' && [quoteStr characterAtIndex:quoteStr.length-1] == '>' && !isNewCard) {
            NSLog(@"show text");
            quote.hidden = YES;
            quoteIV.hidden = NO;
        } else if ([quoteStr characterAtIndex:0] == '[' && [quoteStr characterAtIndex:quoteStr.length-1] == ']') {
            NSLog(@"show video");
            quote.hidden = YES;
            quoteIV.hidden = YES;
            movieFrame.hidden  = NO;
        } else {
            NSLog(@"show image");
            quote.hidden = NO;
            quoteIV.hidden = YES;
        }
        
        quoteLbl = [UILabel new];
        quoteLbl.text = @"Illustration/\nEvidence";
        quoteLbl.numberOfLines = 2;
        quoteLbl.lineBreakMode = NSLineBreakByWordWrapping;
        quoteLbl.textColor = [UIColor whiteColor];
        quoteLbl.backgroundColor = [UIColor clearColor];
        quoteLbl.frame = CGRectMake(25, 85, 100, 50);
        
        changeMediaBtn = [[UIButton alloc] init];
        changeMediaBtn.frame = CGRectMake(15, 150, 100, 60);
        [[changeMediaBtn titleLabel] setFont:[UIFont fontWithName:@"Arial" size:14.0]];
        [[changeMediaBtn titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        changeMediaBtn.backgroundColor = [UIColor lightGrayColor];
        [changeMediaBtn setTitle:@"Add Media" forState:UIControlStateNormal];
        [changeMediaBtn addTarget:self
                           action:@selector(changeMedia)
                 forControlEvents:UIControlEventTouchUpInside];
        
        removeMediaBtn = [[UIButton alloc] init];
        removeMediaBtn.frame = CGRectMake(15, 220, 100, 60);
        removeMediaBtn.backgroundColor = [UIColor lightGrayColor];
        [[removeMediaBtn titleLabel] setFont:[UIFont fontWithName:@"Arial" size:14.0]];
        [[removeMediaBtn titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];
        [removeMediaBtn setTitle:@"Remove Illustration" forState:UIControlStateNormal];
        [removeMediaBtn addTarget:self
                           action:@selector(removeMedia)
                 forControlEvents:UIControlEventTouchUpInside];
        
        citation = [[UITextView alloc] init];
        citation.frame = CGRectMake(125, 325, 400, 50);
        citation.backgroundColor = [UIColor whiteColor];
        citation.tag = 2;
        citation.delegate = self;
        citation.font = theFont;
        citation.returnKeyType = UIReturnKeyNext;
        if (!isNewCard)
            citation.text = [NSString stringWithFormat:@"%@", [chosenCard valueForKey:@"citation"]];
        
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
        explanation.returnKeyType = UIReturnKeyDefault;
        if (!isNewCard)
            explanation.text = [NSString stringWithFormat:@"%@", [chosenCard valueForKey:@"explanation"]];
        
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
    
    saveButton = [[UIButton alloc] init];
    saveButton.frame = CGRectMake(350, 630, 150, 35);
    saveButton.backgroundColor = [UIColor blueColor];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    UIButton *deleteButton = [[UIButton alloc] init];
    
    if (!isNewCard) { //if editing the card
        [saveButton addTarget:self
                       action:@selector(savePopup)
             forControlEvents:UIControlEventTouchUpInside];
        
        deleteButton.frame = CGRectMake(185, 630, 150, 35);
        deleteButton.backgroundColor = [UIColor blackColor];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteButton setTitle:@"Delete Card" forState:UIControlStateNormal];
        [deleteButton addTarget:self
                         action:@selector(deleteCard)
            forControlEvents:UIControlEventTouchUpInside];
    } else { //new card
        [saveButton addTarget:self
                       action:@selector(addCard)
             forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if ((isNewCard && isNewCardaTopicCard) || (chosenCard && [[chosenCard valueForKey:@"quote"] isEqualToString:kCardCheck] && !isNewCard)) {
        cancelButton.frame = CGRectMake(20, 270, 150, 35);
        saveButton.frame = CGRectMake(350, 270, 150, 35);
        if (!isNewCard) {
            deleteButton.frame = CGRectMake(185, 270, 150, 35);
        }
    }
    
    int row = 0;
    if (!isNewCard)
        row = (int)[colorOptions indexOfObject:[chosenCard valueForKey:@"color"]];
    colorChoice = [colorOptions objectAtIndex:row];
    currentColorIndex = row;
    chooseColorBtn.layer.borderColor = [colorReferences[colorChoice] CGColor];
    chooseColorBtn.layer.borderWidth = 3.0f;
    
    [scrollview addSubview:point];
    [scrollview addSubview:pointLbl];
    if ((isNewCard && !isNewCardaTopicCard) || (chosenCard && ![[chosenCard valueForKey:@"quote"] isEqualToString:kCardCheck] && !isNewCard)) {
        [scrollview addSubview:quote];
        [scrollview addSubview:quoteLbl];
        [scrollview addSubview:quoteIV];
        [scrollview addSubview:movieFrame];
        [scrollview addSubview:citation];
        [scrollview addSubview:citationLbl];
        [scrollview addSubview:explanation];
        [scrollview addSubview:explanationLbl];
        [scrollview addSubview:removeMediaBtn];
        [scrollview addSubview:changeMediaBtn];
    }
    [scrollview addSubview:chooseColorBtn];
    [scrollview addSubview:cancelButton];
    [scrollview addSubview:saveButton];
    if (!isNewCard)
        [scrollview addSubview:deleteButton];
    [displayCardViewController.view addSubview:scrollview];
    scrollview.contentSize = CGSizeMake(displayCardViewController.view.frame.size.width, displayCardViewController.view.frame.size.height + 265);
}

- (void)addCard {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Flashcards" inManagedObjectContext:context];
    
    PFObject *newCardPF = [PFObject objectWithClassName:@"Flashcards"];
    
    float xPos = [self currentScreenBoundsBasedOnOrientation].size.width / 2 - 100;
    float yPos = [self currentScreenBoundsBasedOnOrientation].size.height / 2 - 60;
    
    if (!isNewCardaTopicCard) {
        if ([point.text isEqualToString:@""])
            point.text = @" ";
        if ([quote.text isEqualToString:@""])
            quote.text = @" ";
        if ([citation.text isEqualToString:@""])
            citation.text = @" ";
        if ([explanation.text isEqualToString:@""])
            explanation.text = @" ";
        
        [newCard setValue:point.text forKey:@"point"];
        newCardPF[@"point"] = point.text;
        [newCard setValue:quote.text forKey:@"quote"];
        newCardPF[@"illustration"] = quote.text;
        [newCard setValue:citation.text forKey:@"citation"];
        newCardPF[@"citation"] = citation.text;
        [newCard setValue:explanation.text forKey:@"explanation"];
        newCardPF[@"explanation"] = explanation.text;
        [newCard setValue:colorChoice forKey:@"color"];
        newCardPF[@"color"] = colorChoice;
        [newCardPF setObject:[PFUser currentUser].username forKey:@"user"];
        
    } else {
        if ([point.text isEqualToString:@""])
            point.text = @"------";
        
        [newCard setValue:point.text forKey:@"point"];
        newCardPF[@"point"] = point.text;
        [newCard setValue:@"-999" forKey:@"quote"];
        newCardPF[@"illustration"] = @"-999";
        [newCard setValue:@"-999" forKey:@"citation"];
        newCardPF[@"citation"] = @"-999";
        [newCard setValue:@"-999" forKey:@"explanation"];
        newCardPF[@"explanation"] = @"-999";
        [newCard setValue:colorChoice forKey:@"color"];
        newCardPF[@"color"] = colorChoice;
        [newCardPF setObject:[PFUser currentUser].username forKey:@"user"];
    }
    
    [newCard setValue:[NSNumber numberWithFloat:xPos] forKey:@"locationX"];
    [newCard setValue:[NSNumber numberWithFloat:yPos] forKey:@"locationY"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [newCardPF saveInBackground];
    [displayCardViewController dismissViewControllerAnimated:YES completion:nil];
    [self viewDidAppear:YES];
}


- (void)cardTapped:(UITapGestureRecognizer *)rec {
    Card *tappedCard = (Card *)rec.view;
    indexOfChosenCard = tappedCard.index;
    isNewCard = NO;
    isNewCardaTopicCard = NO;
    if (!isCardBeingMoved)
        [self presentDetailCardController:[self.cards objectAtIndex:indexOfChosenCard]];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(void)changeMedia {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Media" message:@"Enter the link to the media" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add Picture", @"Add Youtube", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)removeMedia {
    quote.text = @"";
    quote.hidden = NO;
    quoteIV.image = nil;
    quoteIV.hidden = YES;
    movieFrame.hidden  = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (textView == point) {
            if (!isTopic) {
                NSLog(@"point > quote");
                [textView resignFirstResponder];
                [quote becomeFirstResponder];
            }
            else {
                return YES;
            }
        }
        if (textView == quote) {
            NSLog(@"quote > citation");
            [textView resignFirstResponder];
            [citation becomeFirstResponder];
        }
        if (textView == citation) {
            NSLog(@"citation > explanation");
            [textView resignFirstResponder];
            [explanation becomeFirstResponder];
        }
        
        return NO;
    }

    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Add Picture"])
    {
        quote.hidden = YES;
        quoteIV.hidden = NO;
        movieFrame.hidden  = YES;
        NSString *imageStr = [[alertView textFieldAtIndex:0] text];
        imageStr = [imageStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *imageURL = [NSURL URLWithString:imageStr];
        if (imageURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    quoteIV.image = [UIImage imageWithData:imageData];
                });
            });
        }
        quote.text = [NSString stringWithFormat:@"<%@>", imageStr];
    }
    else if([title isEqualToString:@"Add Youtube"])
    {
        quote.hidden = YES;
        quoteIV.hidden = YES;
        quoteIV.hidden = NO;
        movieFrame.hidden  = NO;
        NSString *imageStr = [[alertView textFieldAtIndex:0] text];
        imageStr = [imageStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *imageURL = [NSURL URLWithString:imageStr];
        if (imageURL) {
            NSRange range = [imageStr rangeOfString:@"v="];
            NSString *identifier;
            if (range.location == NSNotFound) {
                NSLog(@"string was not found");
            } else {
                NSLog(@"position %lu", (unsigned long)range.location);
                identifier = [imageStr substringFromIndex:range.location];
                identifier = [identifier substringFromIndex:2];
            }
            videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:identifier];
            [videoPlayerViewController presentInView:movieFrame];
            [videoPlayerViewController.moviePlayer play];
        }
        quote.text = [NSString stringWithFormat:@"[%@]", imageStr];
    }
    else if([title isEqualToString:@"Yes"])
    {
        if (currentUser) {
            PFQuery *query = [PFQuery queryWithClassName:@"Flashcards"];
            [query whereKey:@"user" equalTo:[PFUser currentUser].username];
            [query findObjectsInBackgroundWithBlock:^(NSArray *foundObjects, NSError *error) {
                if (!error && foundObjects.count > 0) {
                        //clear core data
                        [self deleteAllObjectsForEntity:@"Flashcards" andContext:[self managedObjectContext]];
                        [self.cards removeAllObjects];
                        [self.retrievedViewLocations removeAllObjects];
                        [self.cardViews removeAllObjects];
  
                        //add each value
                        for (int i = 0; i < foundObjects.count; i++) {
                            NSManagedObject *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Flashcards" inManagedObjectContext:[self managedObjectContext]];
                            NSDictionary *currentObject = [foundObjects objectAtIndex:i];
                            [newCard setValue:currentObject[@"point"] forKey:@"point"];
                            [newCard setValue:currentObject[@"illustration"] forKey:@"quote"];
                            [newCard setValue:currentObject[@"citation"] forKey:@"citation"];
                            [newCard setValue:currentObject[@"explanation"] forKey:@"explanation"];
                            [newCard setValue:currentObject[@"color"] forKey:@"color"];
                            //defaults to center screen
                            float locX = [self currentScreenBoundsBasedOnOrientation].size.width/2;
                            float locY = [self currentScreenBoundsBasedOnOrientation].size.height/2;

                            [newCard setValue:[NSNumber numberWithFloat:locX] forKey:@"locationX"];
                            [newCard setValue:[NSNumber numberWithFloat:locY] forKey:@"locationY"];
                            
                            NSError *error = nil;
                            if (![[self managedObjectContext] save:&error]) {
                                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                            }
                        }
                        
                        //refresh the viewcontroler
                        [self viewDidAppear:YES];
                    
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfully restored data"
                                                                        message:@"Your data was successfully restored back to this device."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                }
            }];
            
        }
    } else if ([title isEqualToString:@"Topic Sentence Card"]) {
        isNewCard = YES;
        isNewCardaTopicCard = YES;
        [self presentDetailCardController:nil];
    } else if ([title isEqualToString:@"Information Card"]) {
        isNewCard = YES;
        isNewCardaTopicCard = NO;
        [self presentDetailCardController:nil];
    }
    
}


-(void)chooseColor {
    colorChoice = [colorOptions objectAtIndex:currentColorIndex];
    chooseColorBtn.layer.borderColor = [colorReferences[colorChoice]CGColor];
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
    [colorVC setPreferredContentSize:CGSizeMake(320, 260)];
    
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
    
    [context deleteObject:[self.cards objectAtIndex:indexOfChosenCard]];
    [self.cards removeObjectAtIndex:indexOfChosenCard];
    if (![context save:&error]) {
    	NSLog(@"Error deleting card:%@",error);
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Flashcards"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query whereKey:@"point" equalTo:writtenPoint];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *foundCard, NSError *error) {
        [foundCard deleteInBackground];
    }];


    [displayCardViewController dismissViewControllerAnimated:YES completion:nil];
    [self viewDidAppear:YES];
}

-(void) savePopup {
    [[self.cards objectAtIndex:indexOfChosenCard] setValue:point.text forKey:@"point"];
    [[self.cards objectAtIndex:indexOfChosenCard] setValue:colorChoice forKey:@"color"];
    if (citation.text && ![citation.text isEqualToString:kCardCheck]) {
        [[self.cards objectAtIndex:indexOfChosenCard] setValue:quote.text forKey:@"quote"];
        [[self.cards objectAtIndex:indexOfChosenCard] setValue:citation.text forKey:@"citation"];
        [[self.cards objectAtIndex:indexOfChosenCard] setValue:explanation.text forKey:@"explanation"];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Flashcards"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query whereKey:@"point" equalTo:writtenPoint];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *foundCard, NSError *error) {
        foundCard[@"point"] = point.text;
        if (![citation.text isEqualToString:kCardCheck] && citation) {
            foundCard[@"illustration"] = quote.text;
            foundCard[@"citation"] = citation.text;
            foundCard[@"explanation"] = explanation.text;
        }
        foundCard[@"color"] = colorChoice;
        [foundCard saveInBackground];
    }];

    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [displayCardViewController dismissViewControllerAnimated:YES completion:nil];
    [self viewDidAppear:YES];
}

-(void) cancelPopup {
    [displayCardViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    if ([[touch.view class] isSubclassOfClass:[Card class]]) {
        Card *clickedCard = (Card *)touch.view;
        indexOfChosenCard = clickedCard.index;
        isCardBeingDragged = YES;
        [self.view bringSubviewToFront:touch.view];
        lastXLocation = touchLocation.x;
        lastYLocation = touchLocation.y;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isCardBeingDragged) {
        isCardBeingDragged = NO;
        
        UITouch *touch = [[event allTouches] anyObject];
        Card *clickedCard;
        if ([[touch.view class] isSubclassOfClass:[Card class]]) {
            clickedCard = (Card *)touch.view;
        }
        
        if (self.cards.count > 0) {
            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *updatedCard = [self.cards objectAtIndex:indexOfChosenCard];
            
            [updatedCard setValue:[NSNumber numberWithFloat:clickedCard.frame.origin.x] forKey:@"locationX"];
            [updatedCard setValue:[NSNumber numberWithFloat:clickedCard.frame.origin.y] forKey:@"locationY"];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
            NSLog(@"Layout Saved");
        }
    }
    isCardBeingMoved = NO;
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    if ([[touch.view class] isSubclassOfClass:[Card class]]) {
        Card *movingCard = (Card *)touch.view;
        [self.view bringSubviewToFront:movingCard];
        if (isCardBeingDragged) {
            CGRect frame = movingCard.frame;
            frame.origin.x = movingCard.frame.origin.x + touchLocation.x - lastXLocation;
            frame.origin.y = movingCard.frame.origin.y + touchLocation.y - lastYLocation;
            movingCard.frame = frame;
        }
    }
    isCardBeingMoved = YES;
}

-(void)move:(id)sender {
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)self.view.gestureRecognizers;
    CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
    
    panRecognizer.view.center = CGPointMake(panRecognizer.view.center.x + translation.x, panRecognizer.view.center.y + translation.y);
    
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
    currentColorIndex = (int)row;
    chooseColorBtn.layer.borderColor = [colorReferences[colorChoice] CGColor];
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
        
    }
    return self;
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

//Logout
- (IBAction)logOutButtonTapAction:(id)sender {
    if ([PFUser currentUser])
    {
        [PFUser logOut];
    }
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        UIStoryboard *storyboard = [self storyboard];
        DisplayCardsViewController *displayVC = (DisplayCardsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DisplayCardsViewController"];
        displayVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:displayVC animated:YES];
        NSLog(@"logginging");
    }];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging in", nil) message:NSLocalizedString(@"Make sure you are connected to the internet and your username and password are correct", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Registering", nil) message:NSLocalizedString(@"Error creating account. Check internet connection", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end
