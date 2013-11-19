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
    UIAlertView *alertBox;
    NSString *foundCitation;
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Results"];
    self.savedCitation = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (self.savedCitation.count > 0)
        foundCitation = [[self.savedCitation objectAtIndex:0] valueForKey:@"citation"];
    self.citation = [NSMutableString string];
    self.citationTV.delegate = self;
    if ([[foundCitation stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] || self.savedCitation.count == 0) {
        NSLog(@"not found");
        self.citation = [[NSString stringWithString:foundCitation] mutableCopy];
    }
    else {
        NSLog(@"found");
        alertBox = [[UIAlertView alloc] initWithTitle:@"Found Auto-Saved Version"
                                              message:@"Would you like to bring up your last auto-saved citation page?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [alertBox show];
    }
    
    self.citationTV.text = [self.citation copy];
    
    _exportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action: @selector(pop:)];
    _navBar.rightBarButtonItem = _exportBarButton;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == alertBox)
    {
        if(buttonIndex == 0) {
            //create new one
            NSLog(@"he chose no");
            NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] initWithEntityName:@"Flashcards"];
            self.cards = [[[self managedObjectContext] executeFetchRequest:fetchRequest2 error:nil] mutableCopy];
            
            for (int i = 0; i < self.cards.count; i++) {
                NSString *currentCitation = [[self.cards objectAtIndex:i] valueForKey:@"citation"];
                currentCitation = [currentCitation stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if (![currentCitation isEqualToString:@"-999"]) {
                    [self.citation appendFormat:@"%@ \n", currentCitation];
                }
            }
            NSManagedObject *firstCitation = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:[self managedObjectContext]];
            
            [firstCitation setValue:self.citation forKey:@"citation"];
            self.citationTV.text = [self.citation copy];
            
            NSError *error = nil;
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
        }
        else {
            //would like to get saved copy
            NSLog(@"he chose yes");
            self.citationTV.text = [foundCitation copy];
        }
    }
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

-(void)textViewDidEndEditing:(UITextView *)textView {
    self.citation = [[NSString stringWithString:_citationTV.text] mutableCopy];
    [[self.savedCitation objectAtIndex:0] setValue:_citationTV.text forKey:@"citation"];
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    NSLog(@"Saved Citation");
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
