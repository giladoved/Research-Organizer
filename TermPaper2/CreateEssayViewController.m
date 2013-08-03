//
//  CreateEssayViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 8/2/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "CreateEssayViewController.h"

@interface CreateEssayViewController ()

@end

@implementation CreateEssayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"worked");
        self.essay = [NSMutableString string];
        self.cards = [NSMutableArray new];
        
        self.cool.backgroundColor = [UIColor yellowColor];
        
        self.essayText = [[UITextView alloc] initWithFrame:self.view.frame];
        self.essayText.font = [UIFont fontWithName:@"Times New Roman" size:16];
        self.essayText.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:self.essayText];
        NSLog(@"added");
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
            NSString *currentQuote = [[self.cards objectAtIndex:i] valueForKey:@"quote"];
            currentQuote = [currentQuote stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
            NSString *currentExplanation = [[self.cards objectAtIndex:i] valueForKey:@"explanation"];
            currentExplanation = [currentExplanation stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
            
            [self.essay appendFormat:@"%@ %@ %@ ", currentPoint, currentQuote, currentExplanation];
        }
        self.essayText.backgroundColor = [UIColor blackColor];
        NSLog(@"essayTEXT %@", self.essayText);
        NSLog(@"essay %@", self.essay);
        self.essayText.text = [self.essay copy];
        NSLog(@"TEXT %@", self.essayText.text);


        NSManagedObject *firstEssay = [NSEntityDescription insertNewObjectForEntityForName:@"Results" inManagedObjectContext:[self managedObjectContext]];
        
        [firstEssay setValue:self.essay forKey:@"essay"];
        
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        self.essayText.text = [self.essay copy];
    }
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
