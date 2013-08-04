//
//  CreateEssayViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 8/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "CreateEssayViewController.h"

@interface CreateEssayViewController (){
    UIBarButtonItem *_exportBarButton;
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
            
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Results"];
    self.savedEssay = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSString *foundEssay = [[self.savedEssay objectAtIndex:0] valueForKey:@"essay"];
    self.essay = [NSMutableString string];
    if (foundEssay) {
        self.essay = [NSString stringWithString:foundEssay];
    }
    else {
        NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
        self.cards = [[[self managedObjectContext] executeFetchRequest:fetchRequest2 error:nil] mutableCopy];
        
        for (int i = 0; i < self.cards.count; i++) {
            NSString *currentPoint = [[self.cards objectAtIndex:i] valueForKey:@"point"];
            currentPoint = [currentPoint stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
            if (![[currentPoint substringFromIndex:[currentPoint length] - 1] isEqualToString:@"."])
                currentPoint = [NSString stringWithFormat:@"%@.", currentPoint];
            
            NSString *currentQuote = [[self.cards objectAtIndex:i] valueForKey:@"quote"];
            currentQuote = [currentQuote stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
            if (![[currentQuote substringFromIndex:[currentQuote length] - 1] isEqualToString:@"."])
                currentQuote = [NSString stringWithFormat:@"%@.", currentQuote];
            
            NSString *currentExplanation = [[self.cards objectAtIndex:i] valueForKey:@"explanation"];
            currentExplanation = [currentExplanation stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
            if (![[currentExplanation substringFromIndex:[currentExplanation length] - 1] isEqualToString:@"."])
                currentExplanation = [NSString stringWithFormat:@"%@.", currentExplanation];
            
            [self.essay appendFormat:@"%@ %@ %@ ", currentPoint, currentQuote, currentExplanation];
        }
        NSManagedObject *firstEssay = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:[self managedObjectContext]];
        
        [firstEssay setValue:self.essay forKey:@"essay"];
        
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        self.essayTV.text = [self.essay copy];
    }

    _exportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action: @selector(pop:)];
    _navBar.rightBarButtonItem = _exportBarButton;
}

-(IBAction)pop:(id)sender
{
    NSLog(@"POPCORN");
    if (_exportPicker == nil) {
        //Create the ColorPickerViewController.
        _exportPicker = [[ExportPickerViewController alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _exportPicker.delegate = self;
    }
    
    if (_exportPickerPopover == nil) {
        //The color picker popover is not showing. Show it.
        _exportPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_exportPicker];
        [_exportPickerPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender
                                    permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_exportPickerPopover dismissPopoverAnimated:YES];
        _exportPickerPopover = nil;
    }
}

-(void)selectedOption:(NSString *)chosenOption
{
    NSLog(@"%@", chosenOption);
    if ([chosenOption isEqualToString:@"Copy"]) {
        NSLog(@"Pasted!");
        [[UIPasteboard generalPasteboard] setString:_essayTV.text];
    } else if ([chosenOption isEqualToString:@"Email"]){
        [self sendEmail];
    } else if ([chosenOption isEqualToString:@"iMessage"]) {
        [self sendiMessage];
    }
    //Dismiss the popover if it's showing.
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
    //self.essay = [NSString stringWithString:self.essayText.text];
}

-(void)setEssayText:(UITextView *)essayText {
    //edit first object to be self.essayText.text
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
