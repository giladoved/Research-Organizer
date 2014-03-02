//
//  CitationViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 8/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "CitationViewController.h"

@interface CitationViewController (){
    UIBarButtonItem *_exportBarButton;
}

@end

@implementation CitationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.citation = [NSMutableString string];
        self.cards = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.citation = [NSMutableString string];
    [self formulateCitation];
        
    _exportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action: @selector(pop:)];
    self.navigationItem.rightBarButtonItem = _exportBarButton;
    self.navigationItem.title = @"Citation";
}

-(void) formulateCitation {
    self.citation = [NSMutableString new];
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
    self.cards = [[[self managedObjectContext] executeFetchRequest:fetchRequest2 error:nil] mutableCopy];
    
    for (int i = 0; i < self.cards.count; i++) {
        NSString *currentCitation = [[self.cards objectAtIndex:i] valueForKey:@"citation"];
        currentCitation = [currentCitation stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (![currentCitation isEqualToString:@"-999"]) {
            [self.citation appendFormat:@"%@\n", currentCitation];
        }
    } 
    self.citationTV.text = [self.citation copy];
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
        [[UIPasteboard generalPasteboard] setString:_citationTV.text];
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
        controller.body = _citationTV.text;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendEmail {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setMessageBody:_citationTV.text isHTML:NO];
    
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
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


@end
