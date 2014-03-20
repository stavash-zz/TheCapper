//
//  ViewController.m
//  TheCapper
//
//  Created by Stav Ashuri on 9/6/13.
//  Copyright (c) 2013 Stav Ashuri. All rights reserved.
//

#import "TheCapperViewController.h"
#import "Configuration.h"

#define kTheCapperViewControllerControlAreaHeight 150.0f

typedef enum {
    kCapDirectionLeft,
    kCapDirectionTop,
    kCapDirectionRight,
    kCapDirectionBottom,
} CapDirection;

typedef enum {
    kStretchDirectionHorizontal,
    kStretchDirectionVertical,
} StretchDirection;

@interface TheCapperViewController ()

@property (assign, nonatomic) CGFloat leftCap;
@property (assign, nonatomic) CGFloat topCap;
@property (assign, nonatomic) CGFloat rightCap;
@property (assign, nonatomic) CGFloat bottomCap;

@property (assign, nonatomic) CGSize originalImageSize;

@property (weak, nonatomic) IBOutlet UIStepper *stpLeftCap;
@property (weak, nonatomic) IBOutlet UIStepper *stpTopCap;
@property (weak, nonatomic) IBOutlet UIStepper *stpRightCap;
@property (weak, nonatomic) IBOutlet UIStepper *stpBottomCap;
@property (weak, nonatomic) IBOutlet UIStepper *stpHorizontalStretch;
@property (weak, nonatomic) IBOutlet UIStepper *stpVerticalStretch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segResizeMode;

@property (weak, nonatomic) IBOutlet UILabel *lblLeftCap;
@property (weak, nonatomic) IBOutlet UILabel *lblTopCap;
@property (weak, nonatomic) IBOutlet UILabel *lblRightCap;
@property (weak, nonatomic) IBOutlet UILabel *lblBottomCap;
@property (weak, nonatomic) IBOutlet UILabel *lblCode;

@property (weak, nonatomic) IBOutlet UIImageView *ivMain;

@end

@implementation TheCapperViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stpLeftCap.stepValue = kConfigurationCapStepperSensitivity;
    self.stpTopCap.stepValue = kConfigurationCapStepperSensitivity;
    self.stpRightCap.stepValue = kConfigurationCapStepperSensitivity;
    self.stpBottomCap.stepValue = kConfigurationCapStepperSensitivity;
    self.stpHorizontalStretch.stepValue = kConfigurationStretchStepperSensitivity;
    self.stpVerticalStretch.stepValue = kConfigurationStretchStepperSensitivity;
    
    self.leftCap = self.topCap = self.rightCap = self.bottomCap = 0.0f;
    
    [self loadMainImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)loadMainImageView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIImage *theImage = [[UIImage imageNamed:kConfigurationImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) resizingMode:UIImageResizingModeTile];
    self.originalImageSize = theImage.size;
    self.ivMain.image = theImage;
    self.ivMain.frame = CGRectMake(screenSize.width / 2.0f - theImage.size.width / 2.0f, screenSize.height / 2.0f - theImage.size.height / 2.0f - kTheCapperViewControllerControlAreaHeight, theImage.size.width, theImage.size.height);
    [self updateInterface];
}

- (void)updateInterface
{
    UIImageResizingMode selectedMode = UIImageResizingModeTile;
    NSString *selectedModeName = nil;
    switch (self.segResizeMode.selectedSegmentIndex) {
        case 0:
            selectedMode = UIImageResizingModeTile;
            selectedModeName = @"UIImageResizingModeTile";
            break;
        case 1:
            selectedMode = UIImageResizingModeStretch;
            selectedModeName = @"UIImageResizingModeStretch";
            break;
        default:
            break;
    }
    
    UIImage *newImage = [[UIImage imageNamed:kConfigurationImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(self.topCap, self.leftCap, self.bottomCap, self.rightCap) resizingMode:selectedMode];

    
    self.ivMain.image = newImage;
    
    NSString *strInitialCode = @"UIImage *resizeableImage = [self.myImage resizableImageWithCapInsets:UIEdgeInsetsMake";
    NSString *strEdgeInsetCode = [NSString stringWithFormat:@"(%2.1ff, %2.1ff, %2.1ff, %2.1ff)",self.topCap,self.leftCap,self.bottomCap,self.rightCap];
    NSString *strResizeModeCode = [NSString stringWithFormat:@" resizingMode:%@];",selectedModeName];
    NSString *strUnified = [NSString stringWithFormat:@"%@%@%@",strInitialCode,strEdgeInsetCode,strResizeModeCode];
    
    NSString *strTop = [NSString stringWithFormat:@"%2.1ff",self.topCap];
    NSString *strLeft = [NSString stringWithFormat:@"%2.1ff",self.leftCap];
    NSString *strBottom = [NSString stringWithFormat:@"%2.1ff",self.bottomCap];
    NSString *strRight = [NSString stringWithFormat:@"%2.1ff",self.rightCap];

    NSRange rangeOfTopCap = NSMakeRange(strInitialCode.length + 1, strTop.length);
    NSRange rangeOfLeftCap = NSMakeRange(rangeOfTopCap.location + rangeOfTopCap.length + 2, strLeft.length);
    NSRange rangeOfBottomCap = NSMakeRange(rangeOfLeftCap.location + rangeOfLeftCap.length + 2, strBottom.length);
    NSRange rangeOfRightCap = NSMakeRange(rangeOfBottomCap.location + rangeOfBottomCap.length + 2, strRight.length);
    NSRange rangeOfResizeMode = [strUnified rangeOfString:selectedModeName];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:strUnified];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rangeOfTopCap];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rangeOfLeftCap];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rangeOfBottomCap];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rangeOfRightCap];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:rangeOfResizeMode];
    self.lblCode.attributedText = attrStr;
}

- (void)updateValue:(double)val forCapDirection:(CapDirection)direction
{
    switch (direction) {
        case kCapDirectionLeft:
            self.leftCap = (CGFloat)val;
            self.lblLeftCap.text = [NSString stringWithFormat:@"%2.1f",val];
            break;
        case kCapDirectionTop:
            self.topCap = (CGFloat)val;
            self.lblTopCap.text = [NSString stringWithFormat:@"%2.1f",val];
            break;
        case kCapDirectionRight:
            self.rightCap = (CGFloat)val;
            self.lblRightCap.text = [NSString stringWithFormat:@"%2.1f",val];
            break;
        case kCapDirectionBottom:
            self.bottomCap = (CGFloat)val;
            self.lblBottomCap.text = [NSString stringWithFormat:@"%2.1f",val];
            break;
        default:
            break;
    }
    
    [self updateInterface];
}

- (void)stretchMainImageWithDirection:(StretchDirection)direction
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat totalWidth = 0.0f;
    CGFloat totalHeight = 0.0f;
    switch (direction) {
        case kStretchDirectionHorizontal:
        {
            double newVal = self.stpHorizontalStretch.value;
            totalWidth = self.originalImageSize.width + newVal;
            totalHeight = self.ivMain.frame.size.height;
        }
            break;
        case kStretchDirectionVertical:
        {
            double newVal = self.stpVerticalStretch.value;
            totalWidth = self.ivMain.frame.size.width;
            totalHeight = self.originalImageSize.height + newVal;
        }
            break;
        default:
            break;
    }
    
    self.ivMain.frame = CGRectMake(screenSize.width / 2.0f - self.ivMain.frame.size.width / 2.0f, screenSize.height / 2.0f - self.ivMain.frame.size.height / 2.0f - kTheCapperViewControllerControlAreaHeight,totalWidth,totalHeight);
}

#pragma mark - IBActions

- (IBAction)leftCapChanged:(id)sender
{
    [self updateValue:self.stpLeftCap.value forCapDirection:kCapDirectionLeft];
}

- (IBAction)rightCapChanged:(id)sender
{
    [self updateValue:self.stpRightCap.value forCapDirection:kCapDirectionRight];
}

- (IBAction)topCapChanged:(id)sender
{
    [self updateValue:self.stpTopCap.value forCapDirection:kCapDirectionTop];
}

- (IBAction)bottomCapChanged:(id)sender
{
    [self updateValue:self.stpBottomCap.value forCapDirection:kCapDirectionBottom];
}

- (IBAction)horizontalStretchChanged:(id)sender
{
    [self stretchMainImageWithDirection:kStretchDirectionHorizontal];
}

- (IBAction)verticalStretchChanged:(id)sender
{
    [self stretchMainImageWithDirection:kStretchDirectionVertical];
}

- (IBAction)resizeModeChanged:(id)sender
{
    [self updateInterface];
}

- (IBAction)resetPressed:(id)sender
{
    self.segResizeMode.selectedSegmentIndex = 0;
    self.leftCap = 0.0f;
    self.topCap = 0.0f;
    self.rightCap = 0.0f;
    self.bottomCap = 0.0f;
    
    self.lblLeftCap.text = [NSString stringWithFormat:@"%2.1f",0.0f];
    self.lblTopCap.text = [NSString stringWithFormat:@"%2.1f",0.0f];
    self.lblRightCap.text = [NSString stringWithFormat:@"%2.1f",0.0f];
    self.lblBottomCap.text = [NSString stringWithFormat:@"%2.1f",0.0f];
    
    self.stpVerticalStretch.value = 0.0;
    self.stpHorizontalStretch.value = 0.0;
    self.stpLeftCap.value = 0.0;
    self.stpTopCap.value = 0.0;
    self.stpRightCap.value = 0.0;
    self.stpBottomCap.value = 0.0;
    
    [self loadMainImageView];
    [self updateInterface];
}
- (IBAction)logPressed:(id)sender {
    NSLog(@"__Code__");
    NSLog(@"%@", self.lblCode.text);
}

@end
