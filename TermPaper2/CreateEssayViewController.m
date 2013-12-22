//
//  CreateEssayViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 8/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "CreateEssayViewController.h"
#import "CitationViewController.h"
#import "DisplayOutline.h"

@interface CreateEssayViewController (){
    UIBarButtonItem *_exportBarButton;
    UIAlertView *alertBox;
    NSString *foundEssay;
}

@end

@implementation CreateEssayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.essay = [NSMutableString string];
        self.cards = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *citationButton = [[UIBarButtonItem alloc] initWithTitle:@"Citation Page" style:UIBarButtonItemStyleBordered target:self action:@selector(goCitation:)];
    
    UIBarButtonItem *goBack = [[UIBarButtonItem alloc]
                               initWithTitle:@"Back"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(goBack:)];
    
    NSArray *arrBtns = [[NSArray alloc]initWithObjects:goBack,citationButton, nil];
    self.navigationItem.leftBarButtonItems = arrBtns;
    self.navigationItem.title = @"Essay";
    
    //_navBar = self.navigationItem
    _exportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action: @selector(pop:)];
    self.navigationItem.rightBarButtonItem = _exportBarButton;
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Results"];
    self.savedEssay = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (self.savedEssay.count > 0)
        foundEssay = [[self.savedEssay objectAtIndex:0] valueForKey:@"essay"];
    self.essay = [NSMutableString string];
    self.essayTV.delegate = self;
    if ([[foundEssay stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] || self.savedEssay.count == 0) {
        [self formulateEssay];
    }
    else {
        self.essay = [[NSString stringWithString:foundEssay] mutableCopy];
        self.essayTV.text = [foundEssay copy];
        self.essayTV.text = @"";
        alertBox = [[UIAlertView alloc] initWithTitle:@"Found Auto-Saved Version"
                                                           message:@"Would you like to bring up your last auto-saved essay?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [alertBox show];
    }
    
    //self.essayTV.text = [self.essay copy];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == alertBox)
    {
        if(buttonIndex == 0) {
            self.essayTV.text = @"";
            [self formulateEssay];
        }
        else {
            self.essayTV.text = [foundEssay copy];
        }
    }
}

-(void) formulateEssay {
    self.essay = [NSMutableString new];
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
    self.cards = [[[self managedObjectContext] executeFetchRequest:fetchRequest2 error:nil] mutableCopy];
    
    for (int i = 0; i < self.cards.count; i++) {
        NSString *currentPoint = [[self.cards objectAtIndex:i] valueForKey:@"point"];
        currentPoint = [currentPoint stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];
        if (![[currentPoint substringFromIndex:[currentPoint length] - 1] isEqualToString:@"."] || ![[currentPoint substringFromIndex:[currentPoint length] - 1] isEqualToString:@"?"] || ![[currentPoint substringFromIndex:[currentPoint length] - 1] isEqualToString:@"!"])
            currentPoint = [NSString stringWithFormat:@"%@.", currentPoint];
        
        NSString *currentQuote = [[self.cards objectAtIndex:i] valueForKey:@"quote"];
        if (![currentQuote isEqualToString:@"-999"]) {
            currentQuote = [currentQuote stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
            if (![[currentQuote substringFromIndex:[currentQuote length] - 1] isEqualToString:@"."] || ![[currentQuote substringFromIndex:[currentQuote length] - 1] isEqualToString:@"?"] || ![[currentQuote substringFromIndex:[currentQuote length] - 1] isEqualToString:@"!"])
                currentQuote = [NSString stringWithFormat:@"%@.", currentQuote];
            
            NSString *currentExplanation = [[self.cards objectAtIndex:i] valueForKey:@"explanation"];
            currentExplanation = [currentExplanation stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
            if (![[currentExplanation substringFromIndex:[currentExplanation length] - 1] isEqualToString:@"."] || ![[currentExplanation substringFromIndex:[currentExplanation length] - 1] isEqualToString:@"?"]  || ![[currentExplanation substringFromIndex:[currentExplanation length] - 1] isEqualToString:@"!"])
                currentExplanation = [NSString stringWithFormat:@"%@.", currentExplanation];
            
            [self.essay appendFormat:@"%@\n%@\n%@\n\n", currentPoint, currentQuote, currentExplanation];
        } else {
            if (i != 0)
                [self.essay appendString:@"\n"];
            [self.essay appendFormat:@"%@\n\n", currentPoint];
        }
    }
    NSManagedObject *firstEssay = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:[self managedObjectContext]];
    
    [firstEssay setValue:self.essay forKey:@"essay"];
    self.essayTV.text = [self.essay copy];
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

-(IBAction)goCitation:(id)sender {
    UIStoryboard *storyboard = [self storyboard];
    CitationViewController *citationVC = (CitationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CitationViewController"];
    citationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:citationVC animated:YES];
}

-(IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)pop:(id)sender
{
    if (_exportPicker == nil) {
        _exportPicker = [[ExportPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        _exportPicker.delegate = self;
    }
    
    if (_exportPickerPopover == nil) {
        _exportPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_exportPicker];
        [_exportPickerPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender
                                    permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [_exportPickerPopover dismissPopoverAnimated:YES];
        _exportPickerPopover = nil;
    }
}

-(void)selectedOption:(NSString *)chosenOption
{
    if ([chosenOption isEqualToString:@"Copy"]) {
        NSLog(@"Pasted!");
        [[UIPasteboard generalPasteboard] setString:_essayTV.text];
    } else if ([chosenOption isEqualToString:@"Email"]){
        [self sendEmail];
    } else if ([chosenOption isEqualToString:@"iMessage"]) {
        [self sendiMessage];
    }

    if (_exportPickerPopover) {
        [_exportPickerPopover dismissPopoverAnimated:YES];
        _exportPickerPopover = nil;
    }
}

-(void)sendiMessage {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = _essayTV.text;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendEmail {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setMessageBody:_essayTV.text isHTML:NO];
    
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

-(void)textViewDidEndEditing:(UITextView *)textView {
    [[self.savedEssay objectAtIndex:0] setValue:_essayTV.text forKey:@"essay"];
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    NSLog(@"Saved essay");
}


- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *c = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        c = [delegate managedObjectContext];
    }
    return c;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
