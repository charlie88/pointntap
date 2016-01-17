//
//  ExperienceViewController.m
//  pointntap
//
//  Created by James Hornitzky on 9/01/2016.
//  Copyright © 2016 James Hornitzky. All rights reserved.
//

#import "ExperienceViewController.h"
#import "SEDraggable.h"
#import "SEDraggableLocation.h"
#import "Experience.h"
#import "Slide.h"
#import "SlidePoint.h"
#import "PointImageView.h"

@interface ExperienceViewController ()

@property(nonatomic,weak) IBOutlet UIImageView *imageView;
@property(nonatomic,strong) UILongPressGestureRecognizer *ptLongPressRecogniser;
@property(nonatomic,strong) UITapGestureRecognizer *ptTapRecogniser;
@property(nonatomic,strong) NSMutableArray *displayPoints;

//models
@property(nonatomic,strong) NSMutableArray *slides;
@property(nonatomic,strong) Slide *currentSlide;
@property(nonatomic,strong) NSMutableArray *currentSlideIndex;

-(IBAction) takePhoto:(id)sender;
-(IBAction) handleImageDoubleTap:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation ExperienceViewController 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init holding arrays
    self.slides = [[NSMutableArray alloc] init];
    
    //add touch and gesture handlers
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    [self.imageView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    doubleTap.delegate = self;
    doubleTap.cancelsTouchesInView = NO;
    [self.imageView addGestureRecognizer:doubleTap];
    
    self.ptLongPressRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePointLongPress:)];
    self.ptLongPressRecogniser.delegate = self;
    self.ptLongPressRecogniser.cancelsTouchesInView = NO;
    
    self.ptTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePointTap:)];
    [self.ptTapRecogniser setNumberOfTapsRequired:1];
    self.ptTapRecogniser.delegate = self;
    self.ptTapRecogniser.cancelsTouchesInView = NO;
    
    //load slides
    //FIXME for testing purposes, lets create a blank slide object
    Slide *firstSlide = [[Slide alloc] init];
    firstSlide.isStart = YES;
    firstSlide.text = @"hello";
    firstSlide.uuid = [[NSUUID UUID] UUIDString];
    [self.slides addObject:firstSlide];
    
    self.currentSlideIndex = 0;
    self.currentSlide = firstSlide;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) takePhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    //Use camera if device has one otherwise use photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    //Show image picker
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Get image
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.currentSlide.img = image; //FIXME not really needed, just a quick hack
    
    //Display in ImageView object (if you want to display it]
    [self.imageView setImage:self.currentSlide.img];
    
    //Take image picker off the screen (required)
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleImageSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // cancel any currently selected item
}

- (IBAction)handleImageDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // report point
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSLog(@"add point at: %f, %f", point.x, point.y);
    
    //update the models first
    Slide *newSlide = [[Slide alloc] init];
    newSlide.uuid = [[NSUUID UUID] UUIDString];
    [self.slides addObject:newSlide];
    
    //create a new view at that point
    PointImageView *newPointImageView = [[PointImageView alloc] init];
    
    //position it
    int dimension = 44;
    //FIXME make this % based
    newPointImageView.frame = CGRectMake(point.x-dimension/2, point.y+dimension, dimension, dimension);
    newPointImageView.backgroundColor = [UIColor blackColor];
    newPointImageView.userInteractionEnabled = YES;
    
    newPointImageView.slideUUID = newSlide.uuid;
    
    //then add a recogniser for movement/extra
    [newPointImageView addGestureRecognizer:self.ptLongPressRecogniser];
    [newPointImageView addGestureRecognizer:self.ptTapRecogniser];
    
    //make it draggable
    SEDraggable *draggableView = [[SEDraggable alloc] initWithImageView:newPointImageView];
    
    //finally add it to view
    [self.view addSubview:draggableView];
    
    //record the points and their position
    [self.displayPoints addObject:draggableView]; //FIXME to turn this into an object so you can get the callbacks...
}

- (IBAction)handlePointTap:(UIGestureRecognizer *)gestureRecognizer {
    PointImageView *targetView = gestureRecognizer.view;
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSLog(@"tapped point at: %f, %f", point.x, point.y);
    
    //lets now go and find the right slide
    
    
}

- (IBAction)handlePointLongPress:(UIGestureRecognizer *)gestureRecognizer {
    PointImageView *targetView = gestureRecognizer.view;
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSLog(@"long pressed at: %f, %f", point.x, point.y);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
