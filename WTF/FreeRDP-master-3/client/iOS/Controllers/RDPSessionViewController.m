/*
 RDP Session View Controller
 
 Copyright 2013 Thinstuff Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import <QuartzCore/QuartzCore.h>
#import "RDPSessionViewController.h"
#import "RDPKeyboard.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "ConnectionParams.h"
#import "CredentialsInputController.h"
#import "VerifyCertificateController.h"
#import "BlockAlertView.h"
//16.07.18
#import <sys/sysctl.h>

#define TOOLBAR_HEIGHT 30
#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7
#define AUTOSCROLLDISTANCE 20
#define AUTOSCROLLTIMEOUT 0.05
#define KEYBOARD_TOOLBAR_HEIGHT 45.0
#define ADVANCED_KEYBOARD_HEIGHT 216.0

NSString* TSXrotateactive = @"TSXrotateactive";
NSString* TSXrotatedeactive = @"TSXrotatedeactive";
FileViewController *filecontroller;


@interface RDPSessionViewController (Private)
-(void)showSessionToolbar:(BOOL)show;
-(UIToolbar*)keyboardToolbar;
-(void)initGestureRecognizers;
- (void)suspendSession;
- (NSDictionary*)eventDescriptorForMouseEvent:(int)event position:(CGPoint)position;
- (void)handleMouseMoveForPosition:(CGPoint)position;

@end

@interface  RDPSessionViewController()
//16.08.02
@property (nonatomic) BOOL isSend;
@property (nonatomic) int isSendTo;

@end

@implementation RDPSessionViewController

#pragma mark class methods


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil session:(RDPSession *)session desktopflag:(int)desktopflag
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _session = [session retain];
        textnum = 2;
        
        [_session setDelegate:self];
        [_session setDelegate1:self];
        _session_initilized = NO;
        touchextkey = NO;
        _mouse_move_events_skipped = 0;
        _mouse_move_event_timer = nil;
        
        _advanced_keyboard_view = nil;
        _advanced_keyboard_visible = NO;
        _requesting_advanced_keyboard = NO;
        _keyboard_height_delta = 0;
        deskflag = desktopflag;
        //deskflag=1;
        _session_toolbar_visible = NO;
        
        _toggle_mouse_button = NO;
        
        _autoscroll_with_touchpointer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ui.auto_scroll_touchpointer"];
        _is_autoscrolling = NO;
        rotateflag = 0;
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeInputMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationStopped:finished:context:)];
        [_session_view setdelegate:self];
        /*if (!_session_initilized)
        {
            if ([_session isSuspended])
            {
                [_session resume];
                [self sessionBitmapContextDidChange:_session];
                [_session_view setNeedsDisplay];
            }
            else
                [_session connect];
            
            _session_initilized = YES;
        }*/
    }
    
    return self;
}

-(void)keyboardWillChangeFrame:(NSNotification*)notif{
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	// load default view and set background color and resizing mask
	[super loadView];
    _dummy_textfield = [self buildTextField];
    //[[self view] addSubview:_dummy_textfield];
    chflag = 0;
    // init keyboard handling vars
    _keyboard_visible = NO;

    // init keyboard toolbar
    _keyboard_toolbar = [[self keyboardToolbar] retain];
//    [_dummy_textfield setInputAccessoryView:_keyboard_toolbar];
    [_keyboard_toolbar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, KEYBOARD_TOOLBAR_HEIGHT)];
    [self.view addSubview:_keyboard_toolbar];
    
     //[_dummy_textfield addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // init gesture recognizers
    [self initGestureRecognizers];
    
    // hide session toolbar
    [_session_toolbar setFrame:CGRectMake(0.0, -TOOLBAR_HEIGHT, [[self view] bounds].size.width, TOOLBAR_HEIGHT)];
    [[self view] addSubview:_dummy_textfield];

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    //[super viewDidLoad];

    sysversion1 = [[UIDevice currentDevice] systemVersion];
    NSLog(@"the sysversion1 is %@",sysversion1);
    sysversion1=[sysversion1 substringWithRange:NSMakeRange(0, 1)];
    NSLog(@"the sysversion is %@",sysversion1);
    

    if(IOS7)
    {
     [_dummy_textfield addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}

- (void)setDelegate:(id)object
{
    if (delegate)
    {
        [delegate release];
    }
    delegate = object;
    [object retain];
}

- (id)delegate
{
    return delegate;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
    /*if(rotateflag==0)
    {
        UIDevice *device = [UIDevice currentDevice];
        if(device.orientation==UIDeviceOrientationLandscapeLeft||device.orientation==UIDeviceOrientationLandscapeRight)
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        else
        {
        return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
        }

    }*/
    //return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)

    //return UIInterfaceOrientationMaskLandscape;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (![_touchpointer_view isHidden])
        [_touchpointer_view ensurePointerIsVisible];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

    // hide navigation bar and (if enabled) the status bar
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ui.hide_status_bar"])
    {
        if(animated == YES)
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        else
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    [[self navigationController] setNavigationBarHidden:YES animated:animated];        
	
    // if sesssion is suspended - notify that we got a new bitmap context
    if ([_session isSuspended]) 
        [self sessionBitmapContextWillChange:_session];

    // init keyboard
    [[RDPKeyboard getSharedRDPKeyboard] initWithSession:_session delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
        
    if (!_session_initilized)
    {
        if ([_session isSuspended]) 
        {
            [_session resume];
            [self sessionBitmapContextDidChange:_session];
            [_session_view setNeedsDisplay];
        }
        else
            [_session connect];
        
        _session_initilized = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];

    // show navigation and status bar again
	/*if(animated == YES)
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	else
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];*/
	[[self navigationController] setNavigationBarHidden:NO animated:animated];
	
    // reset all modifier keys on rdp keyboard
    [[RDPKeyboard getSharedRDPKeyboard] reset];
    
	// hide toolbar and keyboard
    [self showSessionToolbar:NO];
	[_dummy_textfield resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // remove any observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // the session lives on longer so set the delegate to nil
    [_session setDelegate:nil];
    
    if (_advanced_keyboard_view) {
        [_advanced_keyboard_view removeFromSuperview];
        NSLog(@"\n_advanced_keyboard_view = %d\n", [_advanced_keyboard_view retainCount]);
        _advanced_keyboard_view = nil;
    }

    [_keyboard_toolbar release];
    [_session release];
    
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark ScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	
    return _session_view;	
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    NSLog(@"New zoom scale: %f", scale);
	[_session_view setNeedsDisplay];
}
- (UITextField *)buildTextField
{
    UITextField *tv = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, .1, .1)];
	[tv setDelegate:self];
	tv.autocorrectionType = UITextAutocorrectionTypeNo;
    tv.autocapitalizationType = UITextAutocapitalizationTypeNone;
	//tv.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    //[tv addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    tv.text = @" ";
    number = 0;
	return tv;
}

#pragma mark -
#pragma mark TextField delegate methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//	_keyboard_visible = YES;
//    _advanced_keyboard_visible = NO;
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
//    NSLog(@"textField text is %@",textField.text);
//	_keyboard_visible = NO;
//    _advanced_keyboard_visible = NO;
	return YES;
}
//16.08.02
//- (void)textFieldEditChanged:(UITextField *)textField
//{
//    const char *current;
//    int textnum1;
//    chnum=0;
//    // UITextField *textField = (UITextField *)sender;
//    UITextInputMode *tim = [UITextInputMode currentInputMode];
//    NSString *imn = tim.primaryLanguage;
//    NSLog(@"type=%@",imn);
//    text = [textField text];
//    NSLog(@"the text is %@",text);
//    NSLog(@"the chflag is %d",chflag);
//    //int textnum=text.length;
//    textnumnew=text.length;
//    Cnlength = textnumnew - textnum;
//    NSLog(@"the cnlength is %d",Cnlength);
//    for(int i=textnum;i<textnumnew;i++)
//    {
//        NSString *singletext = [text substringWithRange:NSMakeRange(i,1)];
//        
//        
//        current = [[singletext dataUsingEncoding:1 allowLossyConversion:YES] bytes];
//        
//        
//        //for(int i = 0 ; i < [text length] ; i++)
//        //{
//        
//        unichar curChar = [text characterAtIndex:i];
//        //[text i]
//        NSLog(@"the text is %d",[text characterAtIndex:i]);
//        // special handling for return/enter key
//        if(curChar<97||curChar>122)
//        {
//            //textnum=textnumnew;
//            if((i!=0)&&(curChar!=8198))
//            {
//                textnum=textnumnew;
//                NSLog(@"the single text is %@",singletext);
//                //[_session Sendtext:0x1002 text:singletext];
//                for(int k=0;k<4000000;k++)
//                {
//                    ;
//                }
//                [_session Sendtext:0x1002 text:singletext];
//                //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//            }
//        }
//        //else
//        
//        // }
//        
//        
//        
//    }
//    
//}
/*- (BOOL)textField:(UITextField *)atextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextInputMode *tim = [UITextInputMode currentInputMode];
    const char *current;
    NSString *imn = tim.primaryLanguage;
    sysversion1 = [[UIDevice currentDevice] systemVersion];
    NSLog(@"the sysversion1 is %@",sysversion1);
    sysversion1=[sysversion1 substringWithRange:NSMakeRange(0, 1)];
    NSLog(@"the sysversion is %@",sysversion1);
    
    
    if([sysversion1 isEqualToString:@"7"])
    {
        if ([string length] == 0)
        {
            NSLog(@"the length is %d",range.length);
            NSLog(@"the location is %d",range.location);
            if ([imn isEqualToString:@"en-US"])
            {
                [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
                return NO;
            }
            else
            {
            if (range.length == 1 && Cnlength <= 0)
            {
                [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
                return NO;
            }
            else
            {
                return YES;
                
            }
            }
        }
    if ([imn isEqualToString:@"en-US"])
   {
    if([string length] == 0)
    {
        [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
        return NO;

    }
	//([string length] > 0)
    else
	{
		for(int i = 0 ; i < [string length] ; i++)
		{
            unichar curChar = [string characterAtIndex:i];

            // special handling for return/enter key
            if(curChar == '\n')
                [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
            else
                [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
                //[_session Sendtext:0x1002 text:string];
            return NO;

		}
	}
		
	
    }
    else
    {
        chflag = 1;
        if([string length] == 0)
        {
            [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
            return NO;

        }
        
        else
        {
            NSLog(@"the string is %@",string);
        for(int i = 0 ; i < [string length] ; i++)
		{
            unichar curChar = [string characterAtIndex:i];
            //NSString *singletext = [text substringWithRange:NSMakeRange(i,1)];
            //current = [[singletext dataUsingEncoding:1 allowLossyConversion:YES] bytes];
     
            if(curChar == '\n')
                [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
            else
            {
           if(curChar<97||(curChar>122&&curChar<10123)||curChar>10130)
           {
               

               for(int i = 0 ; i < [string length] ; i++)
               {
                   NSString *singeltext = [string substringWithRange:NSMakeRange(i,1)];
                   NSLog(@"the string is %@",singeltext);
                   for(int m=0;m<1000000;m++)
                   {
                       ;
                   }
                   [_session Sendtext:0x1002 text:singeltext];
               }
               NSLog(@"the string is %@",string);
               
               return NO;
                //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
               //}
                //return NO;
            }
           
           else
           {
               return YES;
           }
            }
		}
        }
        

    }

    }
    else
    {
        if ([string length] == 0)
        {
            NSLog(@"the length is %d",range.length);
            NSLog(@"the location is %d",range.location);

            if (range.length == 1 && range.location == 0)
            {
                [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
                return NO;
            }
            else
            {
                return YES;

            }
        }
        if([string length] > 0)
        {
            for(int i = 0 ; i < [string length] ; i++)
            {
                unichar curChar = [string characterAtIndex:i];
                
                // special handling for return/enter key
                if(curChar == '\n')
                    [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
                else
                {
                    if ([imn isEqualToString:@"en-US"])
                    {
                    [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
                    //[_session Sendtext:0x1002 text:string];
                        return NO;

                    }
 
                    else
                    {
                        //其他输入法，如果string中包含汉字或者多个字符，标点，则可以发送
                        current = [[string dataUsingEncoding:1 allowLossyConversion:YES] bytes];
                        printf("the current is %d",*current);
                        if (range.length > 0 || (int)(*current) < 97 || (int)(*current) > 122) // 'a'=92 'z'=122
                        {
                            //[rd Sendvitualtext:MSG_CLIENT_IMECHAR AppID:string];
                            [_session Sendtext:0x1002 text:string];
                            return NO;
                        }
                    }
                }
            }
        }
 

        
        return YES;
    }
}*/

//16.08.10终极版吧，单字输入还是有问题
- (void)textFieldEditChanged:(UITextField *)textField
{
    for(int i = textnum; i < textField.text.length; i++)
    {
        unichar curChar = [textField.text characterAtIndex:i];
        if((curChar < 97 || curChar > 122) && curChar != 8198)
        {
            textnum = (int)textField.text.length;
        }
    }
    if (textnum == textField.text.length && textField.text.length != 2) {
        for (int i = 1; i < textField.text.length; i++) {
            unichar curChar = [textField.text characterAtIndex:i];
            [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
        }
        textnum = 2;
        textField.text = @" ";
    }
}
//16.08.08
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *imn = textField.textInputMode.primaryLanguage;
    if (string.length == 0) {
        if ([imn isEqualToString:@"en-US"]) {
            [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
            return NO;
        }else if(range.length == 1) {//为了在中文输入的时候删除先删除拼音再删除文字
            [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
            return NO;
        }
        return YES;
    }
    
    if([string characterAtIndex:0] == '\n') {
        [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
        return NO;
    }
    if ([imn isEqualToString:@"en-US"]) {
        unichar curChar = [string characterAtIndex:0];
        [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
        return NO;
    }else {
        for (int i = 0; i < string.length; i++) {
            unichar curChar = [string characterAtIndex:i];
            if((curChar < 97 || curChar > 122) && (curChar < 10123 || curChar > 10130))
            {
                for (int i = 0; i < string.length; i++) {
                    unichar curChar = [string characterAtIndex:i];
                    [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
                }
                return NO;
            }
        }
    }
    return YES;
}



-(void)changeInputMode:(NSNotification *)notification{
        NSString *inputMethod = [[UITextInputMode currentInputMode] primaryLanguage];
        NSLog(@"inputMethod=%@",inputMethod);
        if ([inputMethod isEqualToString:@"zh-Hans"])
        {
            
        }
    }
//16.08.02
//- (BOOL)textField:(UITextField *)atextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    UITextInputMode *tim = [UITextInputMode currentInputMode];
//    const char *current;
//    NSString *imn = tim.primaryLanguage;
//    sysversion1 = [[UIDevice currentDevice] systemVersion];
//    NSLog(@"the sysversion1 is %@",sysversion1);
//    sysversion1=[sysversion1 substringWithRange:NSMakeRange(0, 1)];
//    NSLog(@"the sysversion is %@",sysversion1);
//    
//    
//    //if([sysversion1 isEqualToString:@"7"])
//    if(IOS7)
//        //if([sysversion1 isEqualToString:@"7"])
//        {
//            if ([string length] == 0)
//            {
//                NSLog(@"the length is %d",range.length);
//                NSLog(@"the location is %d",range.location);
//                if ([imn isEqualToString:@"en-US"])
//                {
//                    [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
//                    return NO;
//                }
//                else
//                {
//                    if (range.length == 1 && Cnlength <= 0)
//                    {
//                        [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
//                        return NO;
//                    }
//                    else
//                    {
//                        return YES;
//                        
//                    }
//                }
//            }
//            if ([imn isEqualToString:@"en-US"])
//            {
//                if([string length] == 0)
//                {
//                    [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
//                    return NO;
//                    
//                }
//                //([string length] > 0)
//                else
//                {
//                    for(int i = 0 ; i < [string length] ; i++)
//                    {
//                        unichar curChar = [string characterAtIndex:i];
//                        
//                        // special handling for return/enter key
//                        if(curChar == '\n')
//                            [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
//                        else
//                            [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                        //[_session Sendtext:0x1002 text:string];
//                        return NO;
//                        
//                    }
//                }
//                
//                
//            }
//            else
//            {
//                chflag = 1;
//                if([string length] == 0)
//                {
//                    [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
//                    return NO;
//                    
//                }
//                
//                else
//                {
//                    NSLog(@"the string is %@",string);
//                    for(int i = 0 ; i < [string length] ; i++)
//                    {
//                        unichar curChar = [string characterAtIndex:i];
//                        //NSString *singletext = [text substringWithRange:NSMakeRange(i,1)];
//                        //current = [[singletext dataUsingEncoding:1 allowLossyConversion:YES] bytes];
//                        
//                        if(curChar == '\n')
//                            [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
//                        else
//                        {
//                            /*if(curChar<97||(curChar>122&&curChar<10123)||curChar>10130)
//                            {
//                                
//                                NSLog(@"the curchar is %d",curChar);
//                                //if(curChar ==32)
//                                //{
//                                [_session Sendtext:0x1002 text:string];
//                                return  NO;
//                                //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                                //}
//                                //return NO;
//                            }*/
//                            //if (range.length > 0 || (int)(*current) < 97 || (int)(*current) > 122) // 'a'=92 'z'=122
//                            if(curChar<97||(curChar>122&&curChar<10123)||curChar>10130)
//                            {
//                                //[rd Sendvitualtext:MSG_CLIENT_IMECHAR AppID:string];
//                                for(int i = 0 ; i < [string length] ; i++)
//                                {
//                                    unichar curChar = [string characterAtIndex:i];
//                                    NSLog(@"the curChar is %d",curChar);
//                                    NSString *singeltext = [string substringWithRange:NSMakeRange(i,1)];
//                                    NSLog(@"the string is %@",singeltext);
//                                    for(int m=0;m<10000000;m++)
//                                    {
//                                        ;
//                                    }
//                                    [_session Sendtext:0x1002 text:singeltext];
//                                    //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                                }
//                                NSLog(@"the string is %@",string);
//                                
//                                return NO;
//                            }
//                            
//                            else
//                            {
//                                return YES;
//                            }
//                        }
//                    }
//                }
//                
//                
//            }
//            
//        }
//        else
//        {
//            if ([string length] == 0)
//            {
//                NSLog(@"the length is %d",range.length);
//                NSLog(@"the location is %d",range.location);
//                
//                if (range.length == 1 && range.location == 0)
//                {
//                    [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
//                    return NO;
//                }
//                else
//                {
//                    return YES;
//                    
//                }
//            }
//            if([string length] > 0)
//            {
//                for(int i = 0 ; i < [string length] ; i++)
//                {
//                    unichar curChar = [string characterAtIndex:i];
//                    
//                    // special handling for return/enter key
//                    if(curChar == '\n')
//                        [[RDPKeyboard getSharedRDPKeyboard] sendEnterKeyStroke];
//                    else
//                    {
//                        if ([imn isEqualToString:@"en-US"])
//                        {
//                            [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                            //[_session Sendtext:0x1002 text:string];
//                            return NO;
//                        }
//                        
//                        /* else
//                         {
//                         if(curChar<97||(curChar>122&&curChar<10123)||curChar>10130)
//                         {
//                         for(int m=0;m<10000000;m++)
//                         {
//                         ;
//                         }
//                         [_session Sendtext:0x1002 text:string];
//                         for(int i = 0 ; i < [string length] ; i++)
//                         {
//                         unichar curChar = [string characterAtIndex:i];
//                         NSLog(@"the curChar is %d",curChar);
//                         NSString *singeltext = [string substringWithRange:NSMakeRange(i,1)];
//                         NSLog(@"the string is %@",singeltext);
//                         for(int m=0;m<4000000;m++)
//                         {
//                         ;
//                         }
//                         [_session Sendtext:0x1002 text:singeltext];
//                         //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                         }
//                         
//                         //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                         }*/
//                        //return YES;
//                        //}
//                        else
//                        {
//                            //其他输入法，如果string中包含汉字或者多个字符，标点，则可以发送
//                            current = [[string dataUsingEncoding:1 allowLossyConversion:YES] bytes];
//                            printf("the current is %d",*current);
//                            if (range.length > 0 || (int)(*current) < 97 || (int)(*current) > 122) // 'a'=92 'z'=122
//                            {
//                                //[rd Sendvitualtext:MSG_CLIENT_IMECHAR AppID:string];
//                                for(int i = 0 ; i < [string length] ; i++)
//                                {
//                                    unichar curChar = [string characterAtIndex:i];
//                                    NSLog(@"the curChar is %d",curChar);
//                                    NSString *singeltext = [string substringWithRange:NSMakeRange(i,1)];
//                                    NSLog(@"the string is %@",singeltext);
//                                    for(int m=0;m<10000000;m++)
//                                    {
//                                        ;
//                                    }
//                                    [_session Sendtext:0x1002 text:singeltext];
//                                    //[[RDPKeyboard getSharedRDPKeyboard] sendUnicode:curChar];
//                                }
//                                NSLog(@"the string is %@",string);
//                                
//                                return NO;
//                                }
//                            //}
//                        }
//                    }
//                }
//            }
//            /*else
//             {
//             [[RDPKeyboard getSharedRDPKeyboard] sendBackspaceKeyStroke];
//             return NO;
//             }*/
//            
//            
//            return YES;
//        }
//    
//}

#pragma mark -
#pragma mark AdvancedKeyboardDelegate functions
-(void)advancedKeyPressedVKey:(int)key
{
    [[RDPKeyboard getSharedRDPKeyboard] sendVirtualKeyCode:key];
}

-(void)advancedKeyPressedUnicode:(int)key
{
    [[RDPKeyboard getSharedRDPKeyboard] sendUnicode:key];
}

#pragma mark - RDP keyboard handler

- (void)modifiersChangedForKeyboard:(RDPKeyboard *)keyboard
{
    UIBarButtonItem* curItem;
    
    // shift button (only on iPad)   
    int objectIdx = 0;
    if (IsPad())
    {
        objectIdx = 2;
        curItem = (UIBarButtonItem*)[[_keyboard_toolbar items] objectAtIndex:objectIdx];
        [curItem setStyle:[keyboard shiftPressed] ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered];
    }
    
    // ctrl button
    objectIdx += 2;
    curItem = (UIBarButtonItem*)[[_keyboard_toolbar items] objectAtIndex:objectIdx];
    [curItem setStyle:[keyboard ctrlPressed] ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered];
    
    // win button
    objectIdx += 2;
    curItem = (UIBarButtonItem*)[[_keyboard_toolbar items] objectAtIndex:objectIdx];
    [curItem setStyle:[keyboard winPressed] ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered];
    
    // alt button
    objectIdx += 2;
    curItem = (UIBarButtonItem*)[[_keyboard_toolbar items] objectAtIndex:objectIdx];
    [curItem setStyle:[keyboard altPressed] ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered];    
}

#pragma mark -
#pragma mark RDPSessionDelegate functions

- (void)session:(RDPSession*)session didFailToConnect:(int)reason
{
    // remove and release connecting view
    [_connecting_indicator_view stopAnimating];
    [_connecting_view removeFromSuperview];
    [_connecting_view autorelease];          

    // return to bookmark list
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)sessionLogon:(RDPSession*)session
{
    /*[[NSBundle mainBundle] loadNibNamed:@"RDPConnectingView" owner:self options:nil];
    
    // set strings
    [_lbl_connecting setText:NSLocalizedString(@"logon", @"Connecting progress view - label")];
    [_cancel_connect_button setTitle:NSLocalizedString(@"Cancel", @"Cancel Button") forState:UIControlStateNormal];
    
    // center view and give it round corners
    [_connecting_view setCenter:[[self view] center]];
    [[_connecting_view layer] setCornerRadius:10];
    
    // display connecting view and start indicator
    [[self view] addSubview:_connecting_view];*/
    [_connecting_indicator_view startAnimating];
            [_lbl_connecting setText:NSLocalizedString(@"logon", @"logon progress view - label")];
}
- (void)sessionAppstart:(RDPSession*)session
{
        [_lbl_connecting setText:NSLocalizedString(@"appstart", @"Connecting progress view - label")];
    [_connecting_indicator_view stopAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:TSXrotateactive object:self];
    //[delegate ApplistAppstart];
    [_connecting_view removeFromSuperview];
    //[_connecting_view autorelease];
    [_connecting_view release];
}
- (void)sessionShellok:(RDPSession*)session
{
        [_lbl_connecting setText:NSLocalizedString(@"shellok", @"Connecting progress view - label")];
}
- (NSString*)getMachine{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    NSLog(@"the machinename is %@",machine);
    free(name);
    
    if( [machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"] ) machine = @"ios_Simulator";
    else if( [machine isEqualToString:@"iPhone1,1"] ) machine = @"iPhone_1G";
    else if( [machine isEqualToString:@"iPhone1,2"] ) machine = @"iPhone_3G";
    else if( [machine isEqualToString:@"iPhone2,1"] ) machine = @"iPhone_3GS";
    else if( [machine isEqualToString:@"iPhone3,1"] ) machine = @"iPhone_4";
    else if( [machine isEqualToString:@"iPod1,1"] ) machine = @"iPod_Touch_1G";
    else if( [machine isEqualToString:@"iPod2,1"] ) machine = @"iPod_Touch_2G";
    else if( [machine isEqualToString:@"iPod3,1"] ) machine = @"iPod_Touch_3G";
    else if( [machine isEqualToString:@"iPod4,1"] ) machine = @"iPod_Touch_4G";
    else if( [machine isEqualToString:@"iPad1,1"] ) machine = @"iPad_1";
    else if( [machine isEqualToString:@"iPad2,1"] ) machine = @"iPad_2";
    
    return machine;
}
- (void)sessionWillConnect:(RDPSession*)session
{
    // load connecting view
        [[NSNotificationCenter defaultCenter] postNotificationName:TSXrotatedeactive object:self];
    NSString *machinename = [self getMachine];
    NSLog(@"the machinename is %@",machinename);
    machinename=[machinename substringWithRange:NSMakeRange(0, 4)];
     if([machinename isEqualToString:@"iPad"])
     {
    UIDevice *device = [UIDevice currentDevice];
   if(device.orientation==UIDeviceOrientationLandscapeLeft||device.orientation==UIDeviceOrientationLandscapeRight)
    
    [[NSBundle mainBundle] loadNibNamed:@"RDPConnectingView_ipadlandscape" owner:self options:nil];
    else
    {
       [[NSBundle mainBundle] loadNibNamed:@"RDPConnectingView_ipad" owner:self options:nil];
    }
     }
    else
    {
        UIDevice *device = [UIDevice currentDevice];
        if(device.orientation==UIDeviceOrientationLandscapeLeft||device.orientation==UIDeviceOrientationLandscapeRight)
            
            [[NSBundle mainBundle] loadNibNamed:@"RDPConnectingViewlandscape" owner:self options:nil];
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"RDPConnectingView" owner:self options:nil];
        }
    }
    // set strings
    [_lbl_connecting setText:NSLocalizedString(@"Connecting", @"Connecting progress view - label")];
    [_cancel_connect_button setTitle:NSLocalizedString(@"Cancel", @"Cancel Button") forState:UIControlStateNormal];
    
    // center view and give it round corners
    [_connecting_view setCenter:[[self view] center]];
    [[_connecting_view layer] setCornerRadius:10];

    // display connecting view and start indicator
    [[self view] addSubview:_connecting_view];
    [_connecting_indicator_view startAnimating];
}

- (void)sessionDidConnect:(RDPSession*)session
{
    // register keyboard notification handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];

    // remove and release connecting view
    if(deskflag == 1)
    {
        [_connecting_indicator_view stopAnimating];
        NSLog(@"\n_connecting_view = %d\n", [_connecting_view retainCount]);
        [_connecting_view removeFromSuperview];
        [_connecting_view autorelease];
            
        [[NSNotificationCenter defaultCenter] postNotificationName:TSXrotateactive object:self];
    }
    // check if session settings changed ...
    // The 2nd width check is to ignore changes in resolution settings due to the RDVH display bug (refer to RDPSEssion.m for more details)
    ConnectionParams* orig_params = [session params];
    rdpSettings* sess_params = [session getSessionParams];
    if (([orig_params intForKey:@"width"] != sess_params->DesktopWidth && [orig_params intForKey:@"width"] != (sess_params->DesktopWidth + 1)) ||
        [orig_params intForKey:@"height"] != sess_params->DesktopHeight || [orig_params intForKey:@"colors"] != sess_params->ColorDepth)
    {
        // display notification that the session params have been changed by the server
        //NSString* message = [NSString stringWithFormat:NSLocalizedString(@"The server changed the screen settings to %dx%dx%d", @"Screen settings not supported message with width, height and colors parameter"), sess_params->DesktopWidth, sess_params->DesktopHeight, sess_params->ColorDepth];
        //[[self view] makeToast:message duration:ToastDurationNormal position:@"bottom"];
    }
    
    if (_advanced_keyboard_view == nil) {
        _advanced_keyboard_view = [[[AdvancedKeyboardView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, ADVANCED_KEYBOARD_HEIGHT) delegate:self] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:_advanced_keyboard_view];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"\ndidFailWithError: %@\n", error);
}

- (void)sessionWillDisconnect:(RDPSession*)session
{

}

- (void)sessionSetVirtualdata:(NSString *)Vdvd Userid:(NSString *)Vdusrid vdsp:(NSString *)Vdvdsp
{
    vd = [[NSString alloc] initWithString:Vdvd];
    Userid =[[NSString alloc] initWithString:Vdusrid];
    vdsp = [[NSString alloc] initWithString:Vdvdsp];
    //vd = Vdvd;
    //Userid = Vdusrid;
    // vdsp = Vdvdsp;
    NSLog(@"the vd is %@,the Userid is %@,the vdsp is %@",vd,Userid,vdsp);
}

-(void) toolbarshow
{
    [self showSessionToolbar:[_session toolbarVisible]];
}

- (void)sessionDidDisconnect:(RDPSession*)session
{
    // return to bookmark list
    [[self navigationController] popViewControllerAnimated:YES];    
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    //scrollview.co
    //if(myscroll = 333)
    //scrollView.
    int myscroll;
    int scrollx = (int)point.x;
    int scrolly = (int)point.y;
    myscroll = scrolly;
    printf("the scrollx is %d,the scrolly is %d",scrollx,scrolly);
}
- (void)sendctrlleft
{
    [[RDPKeyboard getSharedRDPKeyboard] sendctrlleftkey];
}
- (void)sendctrlright
{
    [[RDPKeyboard getSharedRDPKeyboard] sendctrlrightkey];
}
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    //scrollview.co
    //if(myscroll = 333)
    //scrollView.
    int myscroll;
    int scrollx = (int)point.x;
    int scrolly = (int)point.y;
    myscroll = scrolly;
    printf("the scrollx is %d,the scrolly is %d",scrollx,scrolly);
}
- (void)sessionBitmapContextWillChange:(RDPSession*)session
{
    // calc new view frame
    rdpSettings* sess_params = [session getSessionParams];
    CGRect view_rect = CGRectMake(0, 0, sess_params->DesktopWidth, sess_params->DesktopHeight);
    NSLog(@"\nview_rect = %f, %f, %f, %f\n", view_rect.origin.x, view_rect.origin.y, view_rect.size.width, view_rect.size.height);
    NSLog(@"\nUIScreen = %f, %f, %f, %f\n", [UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

    // reset  zoom level and update content size
    [_session_scrollview setZoomScale:1.0];
    [_session_scrollview setContentSize:view_rect.size];
    [_session_scrollview setDelegate:self];

    // set session view size
    [_session_view setFrame:view_rect];
    [_session_view setdelegate:self];
    
    // ipd端进入虚拟化应用后，底部一段空间为黑屏，修改为全屏显示，liyongwei
    NSString *deviceType = [UIDevice currentDevice].model;
    if ([deviceType isEqualToString:@"iPad"])
    {
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if (view_rect.size.height < height) {
            CGFloat xx = height / view_rect.size.height;
            [_session_scrollview setZoomScale:xx];
        }
    }
    
    // show/hide toolbar
    [_session setToolbarVisible:![[NSUserDefaults standardUserDefaults] boolForKey:@"ui.hide_tool_bar"]];
    [self showSessionToolbar:[_session toolbarVisible]];
}

- (void)sessionBitmapContextDidChange:(RDPSession*)session
{
    // associate view with session
    [_session_view setSession:session];

    // issue an update (this might be needed in case we had a resize for instance)
    [_session_view setNeedsDisplay];
}

- (void)session:(RDPSession*)session needsRedrawInRect:(CGRect)rect
{
    [_session_view setNeedsDisplayInRect:rect];
}

- (void)session:(RDPSession *)session requestsAuthenticationWithParams:(NSMutableDictionary *)params
{
    CredentialsInputController* view_controller = [[[CredentialsInputController alloc] initWithNibName:@"CredentialsInputView" bundle:nil session:_session params:params] autorelease];
    [self presentModalViewController:view_controller animated:YES];
}

- (void)session:(RDPSession *)session verifyCertificateWithParams:(NSMutableDictionary *)params
{
    VerifyCertificateController* view_controller = [[[VerifyCertificateController alloc] initWithNibName:@"VerifyCertificateView" bundle:nil session:_session params:params] autorelease];
    //[self presentModalViewController:view_controller animated:YES];
}

- (CGSize)sizeForFitScreenForSession:(RDPSession*)session
{
    if (IsPad())
        return [self view].bounds.size;
    else
    {
        // on phones make a resolution that has a 16:10 ratio with the phone's height
        CGSize size = [self view].bounds.size;
        CGFloat maxSize = (size.width > size.height) ? size.width : size.height;
        return CGSizeMake(maxSize * 1.6f, maxSize);
    }
}

- (void)showGoProScreen:(RDPSession*)session
{
    BlockAlertView* alertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"Unlicensed Client", @"Pro version dialog title") message:NSLocalizedString(@"You are connected to Thinstuff Remote Desktop Host (RDH). Do you want to purchase an access license for this client which allows you to connect to any computer running Thinstuff RDH?", @"Pro version dialog message")];
    
    [alertView setCancelButtonWithTitle:NSLocalizedString(@"No", @"No Button title") block:nil];
    [alertView addButtonWithTitle:NSLocalizedString(@"Yes", @"Yes button title") block:^ {
    }];
    
    [alertView show];
}

#pragma mark - Keyboard Toolbar Handlers

//-(void)showAdvancedKeyboardAnimated
//{
//    // calc initial and final rect of the advanced keyboard view
//    CGRect rect = [[_keyboard_toolbar superview] bounds];
//    NSLog(@"\nsuperview-rect = %f, %f, %f, %f\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//    NSLog(@"\n_keyboard_toolbar = %f, %f, %f, %f\n", [_keyboard_toolbar bounds].origin.x, [_keyboard_toolbar bounds].origin.y, [_keyboard_toolbar bounds].size.width, [_keyboard_toolbar bounds].size.height);
//    rect.origin.y = [_keyboard_toolbar bounds].size.height;
//    rect.size.height -= rect.origin.y;
//    
//    // create new view (hidden) and add to host-view of keyboard toolbar
//    _advanced_keyboard_view = [[AdvancedKeyboardView alloc] initWithFrame:CGRectMake(rect.origin.x, 
//                                                                                     [[_keyboard_toolbar superview] bounds].size.height,
//                                                                                     rect.size.width, rect.size.height) delegate:self];
//    
//    [[_keyboard_toolbar superview] addSubview:_advanced_keyboard_view];
//    // we set autoresize to YES for the keyboard toolbar's superview so that our adv. keyboard view gets properly resized
//    [[_keyboard_toolbar superview] setAutoresizesSubviews:YES];
//    
//    // show view with animation
//    NSLog(@"\nrect = %f, %f, %f, %f\n", _advanced_keyboard_view.frame.origin.x, _advanced_keyboard_view.frame.origin.y, _advanced_keyboard_view.frame.size.width, _advanced_keyboard_view.frame.size.height);
//    [UIView beginAnimations:nil context:NULL];
//    [_advanced_keyboard_view setFrame:rect];
//    [UIView commitAnimations];
//}

// 键盘工具栏-Ext
-(IBAction)toggleKeyboardWhenOtherVisible:(id)sender
{       
//    if(_advanced_keyboard_visible == NO)
//    {
//        [self showAdvancedKeyboardAnimated];
//    }
//    else
//    {
//        // hide existing view
//        [UIView beginAnimations:@"hide_advanced_keyboard_view" context:NULL];
//        CGRect rect = [_advanced_keyboard_view frame];
//        rect.origin.y = [[_keyboard_toolbar superview] bounds].size.height;
//        [_advanced_keyboard_view setFrame:rect];
//        [UIView commitAnimations];        
//        
//        // the view is released in the animationDidStop selector registered in init
//    }
//    
//    // toggle flag
//    _advanced_keyboard_visible = !_advanced_keyboard_visible;
    
    if (_keyboard_visible) {
        [self toggleExtKeyboard:nil];
    } else{
        [self toggleKeyboard:nil];
    }
}

-(IBAction)completeKeyboard:(id)sender
{
    [_dummy_textfield resignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0.0f options:458752 animations:^{
        CGRect frame = _advanced_keyboard_view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        [_advanced_keyboard_view setFrame:frame];
        
        frame = _keyboard_toolbar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        frame.size.height = KEYBOARD_TOOLBAR_HEIGHT;
        [_keyboard_toolbar setFrame:frame];
        
        if (_advanced_keyboard_visible) {
            frame = _session_scrollview.frame;
            frame.size.height += (ADVANCED_KEYBOARD_HEIGHT + KEYBOARD_TOOLBAR_HEIGHT);
            [_session_scrollview setFrame:frame];
            [_touchpointer_view setFrame:frame];
        }
    } completion:^(BOOL finished) {
        _keyboard_visible = NO;
        _advanced_keyboard_visible = NO;
    }];
}

-(IBAction)toggleWinKey:(id)sender
{
    [[RDPKeyboard getSharedRDPKeyboard] toggleWinKey];
}

-(IBAction)toggleShiftKey:(id)sender
{
    [[RDPKeyboard getSharedRDPKeyboard] toggleShiftKey];
}

-(IBAction)toggleCtrlKey:(id)sender
{
    [[RDPKeyboard getSharedRDPKeyboard] toggleCtrlKey];
}

-(IBAction)toggleAltKey:(id)sender
{
    [[RDPKeyboard getSharedRDPKeyboard] toggleAltKey];
}

-(IBAction)pressEscKey:(id)sender
{
    [[RDPKeyboard getSharedRDPKeyboard] sendEscapeKeyStroke];
}

#pragma mark -
#pragma mark event handlers

- (void)animationStopped:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
//    if ([animationID isEqualToString:@"hide_advanced_keyboard_view"])
//    {
//        // cleanup advanced keyboard view
//        [_advanced_keyboard_view removeFromSuperview];
//        [_advanced_keyboard_view autorelease];
//        _advanced_keyboard_view = nil;        
//    }
}

- (IBAction)switchSession:(id)sender
{
    [self suspendSession];
}

- (IBAction)toggleKeyboard:(id)sender
{
    if (_advanced_keyboard_visible) {
        CGRect frame = _session_scrollview.frame;
        frame.size.height += (ADVANCED_KEYBOARD_HEIGHT + KEYBOARD_TOOLBAR_HEIGHT);
        [_session_scrollview setFrame:frame];
        [_touchpointer_view setFrame:frame];
    }
    
    if(!_keyboard_visible){
        _advanced_keyboard_visible = NO;
        _keyboard_visible = YES;
        [_dummy_textfield becomeFirstResponder];
    }
	else
    {
        _keyboard_visible = NO;
        [_dummy_textfield resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.25 delay:0.0f options:458752 animations:^{
        CGRect frame = _advanced_keyboard_view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        [_advanced_keyboard_view setFrame:frame];
        
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)toggleExtKeyboard:(id)sender
{
//    // if the sys kb is shown but not the advanced kb then toggle the advanced kb
//    if(_keyboard_visible && !_advanced_keyboard_visible)
//        [self toggleKeyboardWhenOtherVisible:nil];
//    else
//    {
//        // if not visible request the advanced keyboard view
//        if(_advanced_keyboard_visible == NO)
//        {
//            _requesting_advanced_keyboard = YES;
//        //touchextkey = YES;
//        }
//        [self toggleKeyboard:nil];
//    }
    
    /////////////////////////////
    if (!_advanced_keyboard_visible) {
        _advanced_keyboard_visible = YES;
        if (_keyboard_visible) {
            _keyboard_visible = NO;
            [_dummy_textfield resignFirstResponder];
        }
    }else{
        _advanced_keyboard_visible = NO;
    }
    
    [UIView animateWithDuration:0.25 delay:0.0f options:458752 animations:^{
        if (ABS([UIScreen mainScreen].bounds.size.height - _advanced_keyboard_view.frame.origin.y) < 0.1) {
            CGRect frame = [UIScreen mainScreen].bounds;
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - ADVANCED_KEYBOARD_HEIGHT;
            frame.size.height = ADVANCED_KEYBOARD_HEIGHT;
            [_advanced_keyboard_view setFrame:frame];
            
            frame.origin.y -= KEYBOARD_TOOLBAR_HEIGHT;
            frame.size.height = KEYBOARD_TOOLBAR_HEIGHT;
            [_keyboard_toolbar setFrame:frame];
            
            frame = _session_scrollview.frame;
            frame.size.height -= (ADVANCED_KEYBOARD_HEIGHT + KEYBOARD_TOOLBAR_HEIGHT);
            [_session_scrollview setFrame:frame];
            [_touchpointer_view setFrame:frame];
        }else{
            CGRect frame = _advanced_keyboard_view.frame;
            frame.origin.y = [UIScreen mainScreen].bounds.size.height;
            [_advanced_keyboard_view setFrame:frame];
            
            frame = _keyboard_toolbar.frame;
            frame.origin.y = [UIScreen mainScreen].bounds.size.height;
            frame.size.height = KEYBOARD_TOOLBAR_HEIGHT;
            [_keyboard_toolbar setFrame:frame];
            
            frame = _session_scrollview.frame;
            frame.size.height += (ADVANCED_KEYBOARD_HEIGHT + KEYBOARD_TOOLBAR_HEIGHT);
            [_session_scrollview setFrame:frame];
            [_touchpointer_view setFrame:frame];
        }
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)toggleTouchPointer:(id)sender
{
    BOOL toggle_visibilty = ![_touchpointer_view isHidden];
    [_touchpointer_view setHidden:toggle_visibilty];
    if(toggle_visibilty)
        [_session_scrollview setContentInset:UIEdgeInsetsZero];
    else
        [_session_scrollview setContentInset:[_touchpointer_view getEdgeInsets]];
}

- (IBAction)pagetofileview:(id)sender
{
    filecontroller = [[[FileViewController alloc] initWithNibName:@"FileTableView" bundle:nil] autorelease];
    [filecontroller setDelegate:self];
    [filecontroller setvirtualinfo:vd Userid:Userid vdsp:vdsp];
    [filecontroller gethost:[_session gethostname]];
    [filecontroller getroot];
    
    //[self.se]
    //[ctrl sessionSetVirtualdata:vd Userid:Userid vdsp:vdsp]
    UINavigationController* FileNavigationController =[[[UINavigationController alloc] initWithRootViewController:filecontroller] autorelease];
    //[self.view addSubview:FileNavigationController.view];
    //[self.view addSubview:filecontroller.view];
    //[self presentModalViewController: FileNavigationController
    //animated: NO];
    [self.navigationController pushViewController:filecontroller animated:NO];
}

- (IBAction)disconnectSession:(id)sender
{
    [_session disconnect];        
}


-(IBAction)cancelButtonPressed:(id)sender
{
    [_session disconnect];        
}

#pragma mark In-App purchase transaction notification handlers

- (void)onTransactionSuccess:(NSNotification*)notification
{
    BlockAlertView* alertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"Transaction Succeeded", @"Pro version bought dialog title")
                                                       message:NSLocalizedString(@"Thanks for buying Thinstuff RDC Pro. In order for the purchase to take effect please reconnect your current session.", @"Pro version bought dialog message")];
    [alertView setCancelButtonWithTitle:NSLocalizedString(@"OK", @"OK Button title") block:nil];
    
    [alertView show];        
}

- (void)onTransactionFailed:(NSNotification*)notification
{
    BlockAlertView* alertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"Transaction Failed", @"Pro version buy failed dialog title")
                                                       message:NSLocalizedString(@"The transaction did not complete successfully!", @"Pro version buy failed dialog message")];
    [alertView setCancelButtonWithTitle:NSLocalizedString(@"OK", @"OK Button title") block:nil];

    [alertView show];
}

#pragma mark -
#pragma mark iOS Keyboard Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
//	CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGRect keyboardFrame = [[self view] convertRect:keyboardEndFrame toView:nil];
//
//    CGFloat newHeightDelta = (keyboardFrame.size.height - _keyboard_height_delta);
//    if (newHeightDelta < 0.1 && newHeightDelta > -0.1)
//        return; // nothing changed
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
//    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//	CGRect frame = [_session_scrollview frame];
//	frame.size.height -= newHeightDelta;
//    _keyboard_height_delta += newHeightDelta;
//	[_session_scrollview setFrame:frame];
//    [_touchpointer_view setFrame:frame];    
//	[UIView commitAnimations];

    [_touchpointer_view ensurePointerIsVisible];
    
    /////////////////////////////
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"\nkeyboardWillShow = %f\n", keyboardEndFrame.size.height);
    CGFloat tmpHeight = _keyboard_height_delta;
    
    [UIView animateWithDuration:0.25 delay:0.0f options:458752 animations:^{
        CGRect frame = _keyboard_toolbar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - keyboardEndFrame.size.height - KEYBOARD_TOOLBAR_HEIGHT;
        frame.size.height = KEYBOARD_TOOLBAR_HEIGHT;
        [_keyboard_toolbar setFrame:frame];
        
        frame = _session_scrollview.frame;
        frame.size.height += tmpHeight; // 切换系统键盘时，keyboardWillShow方法会被重新触发，_session_scrollview高度需要先恢复
        frame.size.height -= (keyboardEndFrame.size.height + KEYBOARD_TOOLBAR_HEIGHT);
        [_session_scrollview setFrame:frame];
        [_touchpointer_view setFrame:frame];
    } completion:^(BOOL finished) {
    }];
    _keyboard_height_delta = keyboardEndFrame.size.height + KEYBOARD_TOOLBAR_HEIGHT;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
//    if(_requesting_advanced_keyboard)
//    {
//        [self showAdvancedKeyboardAnimated];
//        _advanced_keyboard_visible = YES;
//        _requesting_advanced_keyboard = NO;
//    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//	CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
//    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//	CGRect frame = [_session_scrollview frame];
//    frame.size.height += [[self view] convertRect:keyboardEndFrame toView:nil].size.height;
//    [_session_scrollview setFrame:frame];
//    [_touchpointer_view setFrame:frame];
//    [UIView commitAnimations];
    //    _keyboard_height_delta = 0;
    
    /////////////////////////////
//    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat tmpHeight = _keyboard_height_delta;
    _keyboard_height_delta = 0;
    
    [UIView animateWithDuration:0.25 delay:0.0f options:458752 animations:^{
        CGRect frame = _keyboard_toolbar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        [_keyboard_toolbar setFrame:frame];
        
        frame = _session_scrollview.frame;
//        frame.size.height += keyboardEndFrame.size.height;    // keyboardEndFrame.size.height有时可能变为0
//        NSLog(@"\nheiht = %f\n",keyboardEndFrame.size.height);
        frame.size.height += tmpHeight;
        NSLog(@"\nkeyboardWillHide = %f\n", tmpHeight);
        [_session_scrollview setFrame:frame];
        [_touchpointer_view setFrame:frame];
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
//    // release adanced keyboard view
//    if(_advanced_keyboard_visible == YES)
//    {
//        _advanced_keyboard_visible = NO;
//        [_advanced_keyboard_view removeFromSuperview];
//        [_advanced_keyboard_view autorelease];
//        _advanced_keyboard_view = nil;
//    }
}

#pragma mark -
#pragma mark Gesture handlers

- (void)handleSingleTap:(UITapGestureRecognizer*)gesture
{
	CGPoint pos = [gesture locationInView:_session_view];
    if (_toggle_mouse_button)
    {
        [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetRightMouseButtonClickEvent(YES) position:pos]];	
        [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetRightMouseButtonClickEvent(NO) position:pos]];
         //[_session sendInputEvent:[self eventDescriptorForMouseEvent:GetRightMouseButtonClickEvent(down) position:session_view_pos]];
    }
    else
    {
        [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(YES) position:pos]];	
        [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(NO) position:pos]];	        
    }

    _toggle_mouse_button = NO;
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)gesture
{
	CGPoint pos = [gesture locationInView:_session_view];	
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(YES) position:pos]];	
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(NO) position:pos]];	
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(YES) position:pos]];	
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(NO) position:pos]];	
    _toggle_mouse_button = NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)gesture
{    
	CGPoint pos = [gesture locationInView:_session_view];
    
	if([gesture state] == UIGestureRecognizerStateBegan) 
        [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(YES) position:pos]];	
	else if([gesture state] == UIGestureRecognizerStateChanged)
        [self handleMouseMoveForPosition:pos];
	else if([gesture state] == UIGestureRecognizerStateEnded)
        [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(NO) position:pos]];	
}


- (void)handleDoubleLongPress:(UILongPressGestureRecognizer*)gesture
{
    // this point is mapped against the scroll view because we want to have relative movement to the screen/scrollview
	CGPoint pos = [gesture locationInView:_session_scrollview];
    
	if([gesture state] == UIGestureRecognizerStateBegan) 
        _prev_long_press_position = pos;
	else if([gesture state] == UIGestureRecognizerStateChanged)
    {
        int delta = _prev_long_press_position.y - pos.y;
        
        if(delta > GetScrollGestureDelta())
        {
            [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetMouseWheelEvent(YES) position:pos]];	
            _prev_long_press_position = pos;
        }
        else if(delta < -GetScrollGestureDelta())
        {            
            [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetMouseWheelEvent(NO) position:pos]];	
            _prev_long_press_position = pos;
        }
    }
}

-(void)handleSingle2FingersTap:(UITapGestureRecognizer*)gesture
{
    _toggle_mouse_button = !_toggle_mouse_button;
}

-(void)handleSingle3FingersTap:(UITapGestureRecognizer*)gesture
{
    [_session setToolbarVisible:![_session toolbarVisible]];
    [self showSessionToolbar:[_session toolbarVisible]];
}

#pragma mark -
#pragma mark Touch Pointer delegates
// callback if touch pointer should be closed
-(void)touchPointerClose
{
    [self toggleTouchPointer:nil];
}

// callback for a left click action
-(void)touchPointerLeftClick:(CGPoint)pos down:(BOOL)down
{
    CGPoint session_view_pos = [_touchpointer_view convertPoint:pos toView:_session_view];
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetLeftMouseButtonClickEvent(down) position:session_view_pos]];	
}

// callback for a right click action
-(void)touchPointerRightClick:(CGPoint)pos down:(BOOL)down
{
    CGPoint session_view_pos = [_touchpointer_view convertPoint:pos toView:_session_view];
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetRightMouseButtonClickEvent(down) position:session_view_pos]];
}

- (void)doAutoScrolling
{
    int scrollX = 0;
    int scrollY = 0;
    CGPoint curPointerPos = [_touchpointer_view getPointerPosition];
    CGRect viewBounds = [_touchpointer_view bounds];
    CGRect scrollBounds = [_session_view bounds];

    // add content insets to scroll bounds
    scrollBounds.size.width += [_session_scrollview contentInset].right;
    scrollBounds.size.height += [_session_scrollview contentInset].bottom;
    
    // add zoom factor
    scrollBounds.size.width *= [_session_scrollview zoomScale];
    scrollBounds.size.height *= [_session_scrollview zoomScale];
    
    if (curPointerPos.x > (viewBounds.size.width - [_touchpointer_view getPointerWidth]))
        scrollX = AUTOSCROLLDISTANCE;
    else if (curPointerPos.x < 0)
        scrollX = -AUTOSCROLLDISTANCE;

    if (curPointerPos.y > (viewBounds.size.height - [_touchpointer_view getPointerHeight]))
        scrollY = AUTOSCROLLDISTANCE;
    else if (curPointerPos.y < (_session_toolbar_visible ? TOOLBAR_HEIGHT : 0))
        scrollY = -AUTOSCROLLDISTANCE;

    CGPoint newOffset = [_session_scrollview contentOffset];
    newOffset.x += scrollX;
    newOffset.y += scrollY;

    // if offset is going off screen - stop scrolling in that direction
    if (newOffset.x < 0)
    {
        scrollX = 0;
        newOffset.x = 0;
    }
    else if (newOffset.x > (scrollBounds.size.width - viewBounds.size.width))
    {
        scrollX = 0;
        newOffset.x = MAX(scrollBounds.size.width - viewBounds.size.width, 0);
    }
    if (newOffset.y < 0)
    {
        scrollY = 0;
        newOffset.y = 0;
    }
    else if (newOffset.y > (scrollBounds.size.height - viewBounds.size.height))
    {
        scrollY = 0;
        newOffset.y = MAX(scrollBounds.size.height - viewBounds.size.height, 0);
    }

    // perform scrolling
    [_session_scrollview setContentOffset:newOffset];

    // continue scrolling?
    if (scrollX != 0 || scrollY != 0)
        [self performSelector:@selector(doAutoScrolling) withObject:nil afterDelay:AUTOSCROLLTIMEOUT];
    else
        _is_autoscrolling = NO;    
}

// callback for a right click action
-(void)touchPointerMove:(CGPoint)pos
{
    CGPoint session_view_pos = [_touchpointer_view convertPoint:pos toView:_session_view];
    [self handleMouseMoveForPosition:session_view_pos];
    
    if (_autoscroll_with_touchpointer && !_is_autoscrolling)
    {
        _is_autoscrolling = YES;
        [self performSelector:@selector(doAutoScrolling) withObject:nil afterDelay:AUTOSCROLLTIMEOUT];
    }
}

// callback if scrolling is performed
-(void)touchPointerScrollDown:(BOOL)down
{   
    [_session sendInputEvent:[self eventDescriptorForMouseEvent:GetMouseWheelEvent(down) position:CGPointZero]];
}

// callback for toggling the standard keyboard
-(void)touchPointerToggleKeyboard
{
    if(_advanced_keyboard_visible)
        [self toggleKeyboardWhenOtherVisible:nil];
    else
        [self toggleKeyboard:nil];
}

// callback for toggling the extended keyboard
-(void)touchPointerToggleExtendedKeyboard
{
    [self toggleExtKeyboard:nil];
}

// callback for reset view
-(void)touchPointerResetSessionView
{
    [_session_scrollview setZoomScale:1.0 animated:YES];
}

@end


@implementation RDPSessionViewController (Private)

#pragma mark -
#pragma mark Helper functions

-(void)showSessionToolbar:(BOOL)show
{
    // already shown or hidden?
    if (_session_toolbar_visible == show)
        return;
    
    if(show)
    {
        [UIView beginAnimations:@"showToolbar" context:nil];
        [UIView setAnimationDuration:.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [_session_toolbar setFrame:CGRectMake(0.0, 0.0, [[self view] bounds].size.width, TOOLBAR_HEIGHT)];
        [UIView commitAnimations];		
        _session_toolbar_visible = YES;        
    }
    else
    {
        [UIView beginAnimations:@"hideToolbar" context:nil];
        [UIView setAnimationDuration:.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [_session_toolbar setFrame:CGRectMake(0.0, -TOOLBAR_HEIGHT, [[self view] bounds].size.width, TOOLBAR_HEIGHT)];
        [UIView commitAnimations];		
        _session_toolbar_visible = NO;
    }
}

-(UIToolbar*)keyboardToolbar
{
	UIToolbar* keyboard_toolbar = [[[UIToolbar alloc] initWithFrame:CGRectNull] autorelease];
	[keyboard_toolbar setBarStyle:UIBarStyleBlackOpaque];
    
	UIBarButtonItem* esc_btn = [[[UIBarButtonItem alloc] initWithTitle:@"Esc" style:UIBarButtonItemStyleBordered target:self action:@selector(pressEscKey:)] autorelease];
    UIImage* win_icon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toolbar_icon_win" ofType:@"png"]];
	UIBarButtonItem* win_btn = [[[UIBarButtonItem alloc] initWithImage:win_icon style:UIBarButtonItemStyleBordered target:self action:@selector(toggleWinKey:)] autorelease];
	UIBarButtonItem* ctrl_btn = [[[UIBarButtonItem alloc] initWithTitle:@"Ctrl" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCtrlKey:)] autorelease];
	UIBarButtonItem* alt_btn = [[[UIBarButtonItem alloc] initWithTitle:@"Alt" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleAltKey:)] autorelease];
	UIBarButtonItem* ext_btn = [[[UIBarButtonItem alloc] initWithTitle:@"Ext" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleKeyboardWhenOtherVisible:)] autorelease];
	UIBarButtonItem* done_btn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(completeKeyboard:)] autorelease];
	UIBarButtonItem* flex_spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    // iPad gets a shift button, iphone doesn't (there's just not enough space ...)
    NSArray* items;
    if(IsPad())
    {
        UIBarButtonItem* shift_btn = [[[UIBarButtonItem alloc] initWithTitle:@"Shift" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleShiftKey:)] autorelease];
        items = [NSArray arrayWithObjects:esc_btn, flex_spacer, 
                 shift_btn, flex_spacer, 
                 ctrl_btn, flex_spacer, 
                 win_btn, flex_spacer, 
                 alt_btn, flex_spacer, 
                 ext_btn, flex_spacer, done_btn, nil];
    }
    else
    {
        items = [NSArray arrayWithObjects:esc_btn, flex_spacer, ctrl_btn, flex_spacer, win_btn, flex_spacer, alt_btn, flex_spacer, ext_btn, flex_spacer, done_btn, nil];        
    }
    
	[keyboard_toolbar setItems:items];
    [keyboard_toolbar sizeToFit];
    return keyboard_toolbar;
}

- (void)initGestureRecognizers
{        
	// single and double tap recognizer 
    UITapGestureRecognizer* doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)] autorelease];
    [doubleTapRecognizer setNumberOfTouchesRequired:1];
	[doubleTapRecognizer setNumberOfTapsRequired:2];	
    
	UITapGestureRecognizer* singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
	[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];	
    [singleTapRecognizer setNumberOfTouchesRequired:1];
	[singleTapRecognizer setNumberOfTapsRequired:1];
    
    // 2 fingers - tap recognizer 
	UITapGestureRecognizer* single2FingersTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingle2FingersTap:)] autorelease];
    [single2FingersTapRecognizer setNumberOfTouchesRequired:2];
	[single2FingersTapRecognizer setNumberOfTapsRequired:1];
    
	// long press gesture recognizer
	UILongPressGestureRecognizer* longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
	[longPressRecognizer setMinimumPressDuration:0.5];
    
    // double long press gesture recognizer
	UILongPressGestureRecognizer* doubleLongPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleLongPress:)] autorelease];
    [doubleLongPressRecognizer setNumberOfTouchesRequired:2];
	[doubleLongPressRecognizer setMinimumPressDuration:0.5];
    
    // 3 finger, single tap gesture for showing/hiding the toolbar
    UITapGestureRecognizer* single3FingersTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingle3FingersTap:)] autorelease];
    [single3FingersTapRecognizer setNumberOfTapsRequired:1];
    [single3FingersTapRecognizer setNumberOfTouchesRequired:3];
    
    // add gestures to scroll view
	[_session_scrollview addGestureRecognizer:singleTapRecognizer];
	[_session_scrollview addGestureRecognizer:doubleTapRecognizer];
	[_session_scrollview addGestureRecognizer:single2FingersTapRecognizer];
	[_session_scrollview addGestureRecognizer:longPressRecognizer];
	[_session_scrollview addGestureRecognizer:doubleLongPressRecognizer];
    [_session_scrollview addGestureRecognizer:single3FingersTapRecognizer];
}

- (void)suspendSession
{
	// suspend session and pop navigation controller
    [_session suspend];
    
    // pop current view controller
    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSDictionary*)eventDescriptorForMouseEvent:(int)event position:(CGPoint)position
{
    return [NSDictionary dictionaryWithObjectsAndKeys:	
                        @"mouse", @"type",
                        [NSNumber numberWithUnsignedShort:event], @"flags",
                        [NSNumber numberWithUnsignedShort:lrintf(position.x)], @"coord_x",
                        [NSNumber numberWithUnsignedShort:lrintf(position.y)], @"coord_y",
                        nil];
}

- (void)sendDelayedMouseEventWithTimer:(NSTimer*)timer
{
    _mouse_move_event_timer = nil;
    NSDictionary* event = [timer userInfo];
    [_session sendInputEvent:event];
    [timer autorelease];
}

- (void)handleMouseMoveForPosition:(CGPoint)position
{
    NSDictionary* event = [self eventDescriptorForMouseEvent:PTR_FLAGS_MOVE position:position];
    
    // cancel pending mouse move events
    [_mouse_move_event_timer invalidate];
    _mouse_move_events_skipped++;
    
    if (_mouse_move_events_skipped >= 5)
    {
        [_session sendInputEvent:event];
        _mouse_move_events_skipped = 0;
    }
    else
    {
        [_mouse_move_event_timer autorelease];
        _mouse_move_event_timer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(sendDelayedMouseEventWithTimer:) userInfo:event repeats:NO] retain];        
    }    
}

//这个方法发生在翻转的过程中，一般用来定制翻转后各个控件的位置、大小等。
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat width=[[UIScreen mainScreen]bounds].size.width;
    CGFloat height=[[UIScreen mainScreen]bounds].size.height;
    
    CGRect frame = _keyboard_toolbar.frame;
    frame.size.width = width;
    if (!_keyboard_visible || !_advanced_keyboard_visible) {
        frame.origin.y = height;
    }
    [_keyboard_toolbar setFrame:frame];
    
    if (_advanced_keyboard_view) {
        [_advanced_keyboard_view removeFromSuperview];
        _advanced_keyboard_view = nil;
        _advanced_keyboard_view = [[[AdvancedKeyboardView alloc] initWithFrame:CGRectMake(0, height, width, ADVANCED_KEYBOARD_HEIGHT) delegate:self] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:_advanced_keyboard_view];
        if (_advanced_keyboard_visible) {
            [_session_scrollview setFrame:[UIScreen mainScreen].bounds];
            _advanced_keyboard_visible = NO;
            [self toggleExtKeyboard:nil];
        }
    }
    
//    switch (interfaceOrientation) {
//        case UIDeviceOrientationPortrait:
//        case UIDeviceOrientationPortraitUpsideDown:
//            break;
//        case UIDeviceOrientationLandscapeRight:
//        case UIDeviceOrientationLandscapeLeft:
//            break;
//        default:
//            break;
//    }
}

@end
