//
//  PGToast.m
//  iToastDemo
//
//  Created by gong Pill on 12-5-21.
//  Copyright (c) 2012年 ceo softcenters. All rights reserved.
//

#import "PGToast.h"
#import <QuartzCore/QuartzCore.h>
#define bottomPadding 50
#define startDisappearSecond 3
#define disappeartDurationSecond 1.5

const CGFloat pgToastTextPadding     = 5;
const CGFloat pgToastLabelWidth      = 200;
const CGFloat pgToastLabelHeight     = 60;
const CGFloat pgToastLabelWidth_PAD      = 360;
const CGFloat pgToastLabelHeight_PAD     = 100;

@interface PGToast() {
    BOOL showInNormal;
}

@property (nonatomic, retain) UILabel *pgLabel;
@property (nonatomic, copy) NSString *pgLabelText;
- (id)initWithText:(NSString *)text;    
- (void)deviceOrientationChange;

@end

@implementation PGToast

@synthesize pgLabel;
@synthesize pgLabelText;

- (id)initWithText:(NSString *)text {

    if (self = [super init]) {
        self.pgLabelText = text;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }    
    return self;
}

- (void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [pgLabel release];
    [pgLabelText release];
    [super dealloc];
}

+ (PGToast *)makeToast:(NSString *)text {
    PGToast *pgToast = [[PGToast alloc] initWithText:text];
    return pgToast;
}


- (void)show {
    UIFont *font;
    CGSize textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        font = [UIFont systemFontOfSize:10];
        textSize = [pgLabelText sizeWithFont:font constrainedToSize:CGSizeMake(pgToastLabelWidth, pgToastLabelHeight)];
    }else{
        font = [UIFont systemFontOfSize:18];
        textSize = [pgLabelText sizeWithFont:font constrainedToSize:CGSizeMake(pgToastLabelWidth_PAD, pgToastLabelHeight_PAD)];
    }
    
    self.pgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textSize.width + 2 * pgToastTextPadding, textSize.height + 2 * pgToastTextPadding)];
    
    //pgLabel.backgroundColor = [UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:0.9];
     pgLabel.backgroundColor = [UIColor blackColor];
    pgLabel.textColor = [UIColor whiteColor];
    pgLabel.layer.cornerRadius = 10;
    pgLabel.layer.borderWidth = 2;
    pgLabel.numberOfLines = 2;
    pgLabel.font = font;
    pgLabel.textAlignment = UITextAlignmentCenter;
    pgLabel.text = self.pgLabelText;
    
    [NSTimer scheduledTimerWithTimeInterval:startDisappearSecond target:self selector:@selector(toastDisappear:) userInfo:nil repeats:NO];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];

    [window addSubview:self.pgLabel];
    [self deviceOrientationChange];
}

- (void)deviceOrientationChange {
    
    //UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    //NSLog(@"%f, %f, %f, %f", window.transform.a, window.transform.b, window.transform.c, window.transform.d);
    //NSLog(@"%f, %f", window.transform.tx, window.transform.ty);
//    CGPoint point = window.center;    
//    NSLog(@"point %f, %f", point.x, point.y);
    CGFloat centerX, centerY;
    CGFloat windowCenterX = [[UIScreen mainScreen] bounds].size.width * 0.5; //window.center.x;
    CGFloat windowCenterY = [[UIScreen mainScreen] bounds].size.height * 0.5; //window.center.y;
    CGFloat windowWidth = [[UIScreen mainScreen] bounds].size.width; //window.frame.size.width;
    CGFloat windowHeight = [[UIScreen mainScreen] bounds].size.height;  //window.frame.size.height;
    
    
    UIInterfaceOrientation currentOrient= [UIApplication sharedApplication].statusBarOrientation;

    //UIDeviceOrientation currentOrient = [[UIDevice currentDevice] orientation];
    
    if (currentOrient == UIInterfaceOrientationLandscapeRight) //UIDeviceOrientationLandscapeRight
    {
        NSLog(@"right ...");       
        CGAffineTransform rightTransform = CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, 0.0, 0.0);
        self.pgLabel.transform = rightTransform;
        centerX = bottomPadding;        
        centerY = windowCenterY;
        self.pgLabel.center = CGPointMake(centerX, centerY);
    }
    else if(currentOrient == UIInterfaceOrientationLandscapeLeft)//UIDeviceOrientationLandscapeLeft
    {
        NSLog(@"left ...");
        CGAffineTransform leftTransform = CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, 0.0, 0.0);
        pgLabel.transform = leftTransform;
        centerX = windowWidth - bottomPadding;
        centerY = windowCenterY;
        self.pgLabel.center = CGPointMake(centerX, centerY);
    }
    else if(currentOrient == UIInterfaceOrientationPortraitUpsideDown)//UIDeviceOrientationPortraitUpsideDown
    {
        NSLog(@"down ...");
        //lastOrientation = currentOrient;
        CGAffineTransform upsideDownTransform = CGAffineTransformMake(-1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
        pgLabel.transform = upsideDownTransform;
        
        centerX = windowCenterX;
        centerY = bottomPadding;
        self.pgLabel.center = CGPointMake(centerX, centerY);
    }
    else if(currentOrient == UIInterfaceOrientationPortrait)//UIDeviceOrientationPortrait
    {
        NSLog(@"up ...");
        CGAffineTransform portraitTransform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
        pgLabel.transform = portraitTransform;
        centerX = windowCenterX;
        centerY = windowHeight - bottomPadding;
        self.pgLabel.center = CGPointMake(centerX, centerY);
    } else {
        NSLog(@"FACE UP...");
    }
    
    showInNormal = YES;
}

- (void)toastDisappear:(NSTimer *)timer {
    [timer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(startDisappear:) userInfo:nil repeats:YES];
}

- (void)startDisappear:(NSTimer *)timer {
    static int timeCount = 60 * disappeartDurationSecond;
    if (timeCount >= 0) {
        [self.pgLabel setAlpha:timeCount/60.0];
        if (timeCount == 0) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self release];
            self = nil;
        }
        timeCount--;
    } else {
        [timer invalidate];
        timeCount = 60 * disappeartDurationSecond;
    }
}

@end
