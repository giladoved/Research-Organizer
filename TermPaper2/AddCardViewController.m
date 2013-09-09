//
//  AddCardViewController.m
//  TermPaper2
//
//  Created by Gilad Oved on 6/24/13.
//  Copyright (c) 2013 Gilad Oved. All rights reserved.
//

#import "AddCardViewController.h"
#import "Card.h"
#import <QuartzCore/QuartzCore.h>

@interface AddCardViewController () 
{
    NSArray *colorOptions;
    NSString *colorChoice;
        
    int currentColorIndex;
}
@end

@implementation AddCardViewController

- (IBAction)addCard:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"Flashcards" inManagedObjectContext:context];
    
    if ([self.pointTxt.text isEqualToString:@""])
        self.pointTxt.text = @" ";
    if ([self.quoteTxt.text isEqualToString:@""])
        self.quoteTxt.text = @" ";
    if ([self.citationTxt.text isEqualToString:@""])
        self.citationTxt.text = @" ";
    if ([self.explanationTxt.text isEqualToString:@""])
        self.explanationTxt.text = @" ";
    
    float xPos = [self currentScreenBoundsBasedOnOrientation].size.width / 2 - 100;
    float yPos = [self currentScreenBoundsBasedOnOrientation].size.height / 2 - 60;
    
    [newCard setValue:self.pointTxt.text forKey:@"point"];
    [newCard setValue:self.quoteTxt.text forKey:@"quote"];
    [newCard setValue:self.citationTxt.text forKey:@"citation"];
    [newCard setValue:self.explanationTxt.text forKey:@"explanation"];
    [newCard setValue:colorChoice forKey:@"color"];
    [newCard setValue:[NSNumber numberWithFloat:xPos] forKey:@"locationX"];
    [newCard setValue:[NSNumber numberWithFloat:yPos] forKey:@"locationY"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Added"
                                                    message:@"Card was successfully added!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseColor:(id)sender {
    colorChoice = [colorOptions objectAtIndex:0];
    currentColorIndex = 0;
    self.colorPickerButton.layer.borderColor = [self getColorWithString:colorChoice].CGColor;
    self.colorPickerButton.layer.borderWidth = 3.0f;
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
    
    [pickerView selectRow:0 inComponent:0 animated:NO];
    
    [popover presentPopoverFromRect:self.colorPickerButton.bounds inView:self.colorPickerButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
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
    self.colorPickerButton.layer.borderColor = [self getColorWithString:colorChoice].CGColor;
    self.colorPickerButton.layer.borderWidth = 3.0f;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    colorOptions = [NSArray arrayWithObjects:@"Gray", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown", nil];
    colorChoice = [NSString new];
    self.colorPickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scrollView setContentSize:CGSizeMake(1024,1100.0)];
    colorChoice = [colorOptions objectAtIndex:0];
    currentColorIndex = 0;
    self.colorPickerButton.layer.borderColor = [self getColorWithString:colorChoice].CGColor;
    self.colorPickerButton.layer.borderWidth = 3.0f;
    NSLog(@"colorchoice: %@", colorChoice);
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
    
    return [UIColor grayColor];
}


@end
