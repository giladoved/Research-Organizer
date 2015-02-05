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
    NSMutableString *htmlEssayText;
    int footnoteCount;
    int footnoteCount1;
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
    
    footnoteCount = 1;
    footnoteCount1 = 1;
    UIBarButtonItem *citationButton = [[UIBarButtonItem alloc] initWithTitle:@"Citation Page" style:UIBarButtonItemStyleBordered target:self action:@selector(goCitation:)];
    
    UIBarButtonItem *goBack = [[UIBarButtonItem alloc]
                               initWithTitle:@"Back"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(goBack:)];
    
    NSArray *arrBtns = [[NSArray alloc]initWithObjects:goBack,citationButton, nil];
    self.navigationItem.leftBarButtonItems = arrBtns;
    self.navigationItem.title = @"Essay";
    
    _exportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action: @selector(pop:)];
    self.navigationItem.rightBarButtonItem = _exportBarButton;
    
    self.essay = [NSMutableString string];
    [self formulateEssay];
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
            
            currentQuote = [NSString stringWithFormat:@"%@[%i]", currentQuote, footnoteCount];
            [self.essay appendFormat:@"%@\n%@\n%@\n\n", currentPoint, currentQuote, currentExplanation];
            footnoteCount++;
        } else {
            if (i != 0)
                [self.essay appendString:@"\n"];
            [self.essay appendFormat:@"%@\n\n", currentPoint];
        }
    }
    
    htmlEssayText = [NSMutableString new];
    [htmlEssayText appendString:@"<html><body>"];
    for (int i = 0; i < self.cards.count; i++) {
        NSString *currentPoint = [[self.cards objectAtIndex:i] valueForKey:@"point"];
        NSString *currentQuote = [[self.cards objectAtIndex:i] valueForKey:@"quote"];
        NSString *currentExplanation = [[self.cards objectAtIndex:i] valueForKey:@"explanation"];
        
        if ([currentQuote isEqualToString:@"-999"]) {
            if (i > 0)
                [htmlEssayText appendString:@"</br>"];
            [htmlEssayText appendFormat:@"<p><strong>%@</strong></p>", currentPoint];
        }
        else
            [htmlEssayText appendFormat:@"<p>%@</p>", currentPoint];
        if (![currentQuote isEqualToString:@"-999"]) {
            if ([[currentQuote substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"<"]) {
                NSString *tempQuote = [currentQuote substringWithRange:NSMakeRange(1, currentQuote.length - 2)];
                [htmlEssayText appendFormat:@"<img src=\"%@\" height=\"100\" width=\"100\"> [%i]", tempQuote, footnoteCount1];
            } else if ([[currentQuote substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"["]) {
                NSString *tempQuote = [currentQuote substringWithRange:NSMakeRange(1, currentQuote.length - 2)];
                NSRange range = [tempQuote rangeOfString:@"v="];
                NSString *identifier;
                if (range.location == NSNotFound) {
                    NSLog(@"string was not found");
                } else {
                    NSLog(@"position %lu", (unsigned long)range.location);
                    identifier = [tempQuote substringFromIndex:range.location];
                    identifier = [identifier substringFromIndex:2];
                }

                NSString *tempQuote2 = [NSString stringWithFormat:@"http://www.youtube.com/v/%@", identifier];
                
                [htmlEssayText appendFormat:@"<embed src=\"%@\" width=\"250\" height=\"125\"> [%i]", tempQuote2, footnoteCount1];
            }
            else {
                [htmlEssayText appendFormat:@"<p>%@ [%i]</p>", currentQuote, footnoteCount1];
            }
            if (![currentExplanation isEqualToString:@"-999"])
            [htmlEssayText appendFormat:@"<p>%@</p><br/>", currentExplanation];
            footnoteCount1++;
        }
        else {
            //[htmlEssayText appendString:@"</br>"];
        }
    }
    [htmlEssayText appendString:@"</body></html>"];
    NSLog(@"html is: %@", htmlEssayText);
    
    [self.essayWebView loadHTMLString:htmlEssayText baseURL:[NSURL URLWithString:@""]];
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
        [[UIPasteboard generalPasteboard] setString:self.essay];
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
        controller.body = self.essay;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendEmail {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    [mc setMessageBody:[htmlEssayText copy] isHTML:YES];
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
