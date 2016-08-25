//
//  AboutView.m
//  GwtClient
//
//  Created by Steve Jobs on 11-12-15.
//  Copyright 2011年 Apple inc. All rights reserved.
//

#import "AboutView.h"

@implementation AboutView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    //self.e
    [self.navigationItem setTitle:[[NSBundle mainBundle] localizedStringForKey:@"AboutTitle" value:@"" table:nil]];
    
    
    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundStriped" ofType:@"png"]];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end