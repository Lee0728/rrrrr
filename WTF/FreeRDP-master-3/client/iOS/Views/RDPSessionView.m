/*
 RDP Session View
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "RDPSessionView.h"

@implementation RDPSessionView

- (void)setSession:(RDPSession*)session
{
    _session = session;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _session = nil;
}

- (void)setdelegate:(id)_delegate
{
    delegate = _delegate;
}
- (void)drawRect:(CGRect)rect 
{
	if(_session != nil && [_session bitmapContext])
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGImageRef cgImage = CGBitmapContextCreateImage([_session bitmapContext]);

        CGContextTranslateCTM(context, 0, [self bounds].size.height);
        CGContextScaleCTM(context, 1.0, -1.0);      
        CGContextClipToRect(context, CGRectMake(rect.origin.x, [self bounds].size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height));
        CGContextDrawImage(context, CGRectMake(0, 0, [self bounds].size.width, [self bounds].size.height), cgImage);        
		
        CGImageRelease(cgImage);
	}
    else
    {
        // just clear the screen with black
        [[UIColor blackColor] set];
        UIRectFill([self bounds]);        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *theseTouches = [touches allObjects];
    int i =0;
    for (i = 0 ; i < theseTouches.count ; i++)
	{
        UITouch *thisTouch = [theseTouches objectAtIndex:i];
		CGPoint thisTouchPoint = [thisTouch locationInView:self];
		NSValue *pointValue = [NSValue value:&thisTouchPoint withObjCType:@encode(CGPoint)];
        CGPoint touchPoint;
        [pointValue getValue:&touchPoint];
        int xposition = lrintf(touchPoint.x);
        int yposition = lrintf(touchPoint.y);
        beginx=xposition;
        beginy=yposition;
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   	UITouch *thisTouch = [touches anyObject];
	CGPoint dragPoint = [thisTouch locationInView:self];
    dragx=lrintf(dragPoint.x)-beginx;
    dragy=lrintf(dragPoint.y)-beginy;
    //NSLog(@"the dragy is %d",dragy);
   // NSLog(@"the dragx is %d",dragx);
    int mousex = lrintf(dragPoint.x);
    int mousey = lrintf(dragPoint.y);
    NSLog(@"the mousex is %d",mousex);
    NSLog(@"the mousey is %d",mousey);
	   
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"the dragy is %d",dragy);
    NSLog(@"the dragx is %d",dragx);

    if(abs(dragy)<100)
    {
        if(abs(dragx)>100)
        {
            if(dragx >0)
            {
                for(int i = 0;i<abs(dragx)/100;i++)
                {
                [delegate sendctrlleft];
                }
            }
            else
            {
                for(int i = 0;i<abs(dragx)/100;i++)
                {
                [delegate sendctrlright];
                }
            }
        }
    }
    dragy=0;
    dragx=0;
}
- (void)dealloc {
    [super dealloc];
}

@end
