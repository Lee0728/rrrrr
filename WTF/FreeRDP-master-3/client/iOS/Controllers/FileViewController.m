//
//  FileViewController.m
//  FreeRDP
//
//  Created by 吴 永华 on 14-4-16.
//
//

#import "FileViewController.h"
//16.07.18
#import <sys/sysctl.h>

@interface FileViewController ()

@end

@implementation FileViewController
@synthesize FileCell;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    endpacketnum = 4096;
    openmobileflag = FALSE;
    progressflag = FALSE;
    serverroot = 0;
    rootflag = 0;
    camera = 0;
    labloaded.hidden = YES;
    labsum.hidden = YES;
    //getfilename = [[NSString alloc] init];
    if (self) {
        
        // Custom initialization
        root = 0;
        UIImage* tabBarIcon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"folder" ofType:@"png"]];
        [self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Folder", @"Tabbar item Folder") image:tabBarIcon tag:0] autorelease]];
        Cellarray = [[NSMutableArray alloc] init];
        Celldic = [NSMutableDictionary dictionary];
        [Celldic setObject:@"手机相册" forKey:@"name"];
        [Celldic setObject:@"0" forKey:@"isfile"];
        NSLog(@"dictionary:%@",Celldic);

        [Cellarray addObject:Celldic];
        NSString *name =[[Cellarray objectAtIndex:0] objectForKey:@"name"];
        NSLog(@"the name is %@",name);
        //[Celldic release];
        Celldic1 = [NSMutableDictionary dictionary];
        [Celldic1 setObject:@"本地文件" forKey:@"name"];
        [Celldic1 setObject:@"0" forKey:@"isfile"];
        [Cellarray addObject:Celldic1];
        //[Celldic release];
        Celldic2 = [NSMutableDictionary dictionary];
        [Celldic2 setObject:@"服务器文件" forKey:@"name"];
        [Celldic2 setObject:@"0" forKey:@"isfile"];
        [Cellarray addObject:Celldic2];
        //[Celldic release];
    }
    return self;
}
- (void)UpdateProgress
{
           UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:selectindex];
    statuView = [[[UIView alloc] initWithFrame:CGRectMake(52, 45, 600, 17)] autorelease];
        /*UILabel *Label1 = [[[UILabel alloc] initWithFrame:CGRectMake(52, 80, 40, 15)] autorelease];
    Label1.text=@"0M";
    [Label1 setFont:[UIFont systemFontOfSize:14]];
    Label1.backgroundColor = [UIColor clearColor];
    [statuView addSubview:Label1];
    UILabel *Label2 = [[[UILabel alloc] initWithFrame:CGRectMake(52+40, 45, 40, 15)] autorelease];
    //[statuLabel setTag:4];
    Label2.text=@"/0M";
    [Label2 setFont:[UIFont systemFontOfSize:14]];
    Label2.backgroundColor = [UIColor clearColor];
    [statuView addSubview:Label2];*/
    [cell.contentView addSubview:statuView];
    progressflag = TRUE;
    labloaded.hidden = NO;
    labsum.hidden = NO;
    [labloaded setFont:[UIFont systemFontOfSize:12]];
    [labsum setFont:[UIFont systemFontOfSize:12]];
    //[labloaded setText:@"0M"];
    //[labsum setText:@"10M"];
    progress.hidden = NO;
    

}
- (void)updatejindu
{
    NSString* loadedstr;
    NSString* sumstr;
    char s[50];
    
    if(((int)(downloaddatanum/1024))<1024)
    {
    sprintf(s, "%5d", ((int)downloadednum));
    progress.progress = (float)(downloadednum/((float)(downloaddatanum/1024)));
    //loadedstr = [[NSString alloc] initWithCString:(const char*)s];
    loadedstr = [NSString stringWithUTF8String:s];
    sprintf(s,"%5d",((int)(downloaddatanum/1024)));
        sumstr = @"/";
        sumstr = [sumstr stringByAppendingString:[NSString stringWithUTF8String:s]];
    //sumstr = [NSString stringWithUTF8String:s];
    //sscanf(auth,"%x",&nValude);
    //NSLog(@"the loadedstr is %@",loadedstr);
    loadedstr = [loadedstr stringByAppendingString:@"k"];
   // NSLog(@"the loadedstr is %@",loadedstr);
        sumstr = [sumstr stringByAppendingString:@"k"];
    [labloaded setText:loadedstr];
    [labsum setText:sumstr];
    }
    else
    {
        //printf(
        sprintf(s, "%5.1f", downloadednum/1024);
        progress.progress = (float)(downloadednum/((float)(downloaddatanum/1024)));
        //printf("the progress is %f",(float)(downloadednum/downloaddatanum));
        //loadedstr = [[NSString alloc] initWithCString:(const char*)s];
        loadedstr = [NSString stringWithUTF8String:s];
        sprintf(s,"%5.1f",((float)((float)(downloaddatanum)/1024/1024)));
        printf("the sum is %lld",downloaddatanum);
        printf("the display is %s",s);
        sumstr = @"/";
        sumstr = [sumstr stringByAppendingString:[NSString stringWithUTF8String:s]];
        //sumstr = [NSString stringWithUTF8String:s];
        //sscanf(auth,"%x",&nValude);
        //NSLog(@"the loadedstr is %@",loadedstr);
        loadedstr = [loadedstr stringByAppendingString:@"M"];
        //NSLog(@"the sumstr is %@",sumstr);
        sumstr = [sumstr stringByAppendingString:@"M"];
        [labloaded setText:loadedstr];
        [labsum setText:sumstr];
    }
}
-(void) getroot
{
//[NSThread detachNewThreadSelector:@selector(listrootfile) toTarget:self withObject:nil];
    if([self listrootfile] == 1)
    {
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
                   messageStr:[[NSBundle mainBundle] localizedStringForKey:@"noprivatefile" value:@"Can not connect server!" table:nil]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
                          tag:0];
        //[self dismissModalViewControllerAnimated:YES];
        return ;
    }
    NSLog(@"The root is %@",[[privatefolder objectAtIndex:0] objectForKey:@"name"]);
if([privatefolder count] == 0)
{
    [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
               messageStr:[[NSBundle mainBundle] localizedStringForKey:@"nofolder" value:@"Can not connect server!" table:nil]
              btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
                      tag:0];
    [self dismissModalViewControllerAnimated:YES];
}
else
{
    int mobilephotoflag = 0;
    int mobilefileflag = 0;
    ispriv = 1;
    //tmp = @"";
    tmp = [[NSMutableString alloc] initWithString:@""];

    sendfilename = [[NSString alloc] initWithString:[[privatefolder objectAtIndex:0] objectForKey:@"name"]];
    if([self listfiletest]==1)
    {
        [self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"] foldername:@"手机文件"];
        [self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"] foldername:@"手机相册"];
    }
    else
    {
    for(int i = 0;i<[arraydecription count];i++)
    {
        if([[[arraydecription objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"手机文件"])
        {
            mobilefileflag = 1;
        }
        if([[[arraydecription objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"手机相册"])
        {
            mobilephotoflag = 1;
        }
    }
    if(mobilephotoflag == 0)
    {
       [self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"] foldername:@"手机相册"];
    }
    if(mobilefileflag == 0)
    {
        [self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"] foldername:@"手机文件"];
    }
    }
    //arraydecription = [[NSMutableArray alloc]init];
    [self listrootfile];
    tmp = [[NSMutableString alloc] initWithString:@""];
}
}
- (void)ErrorMessageBox:(NSString *)titleStr messageStr:(NSString *)messageStr btnTitleStr:(NSString *)btnTitleStr tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                    message:messageStr
                                                   delegate:self
                                          cancelButtonTitle:btnTitleStr
                                          otherButtonTitles:nil];
    [alert setTag:tag];
    [alert show];
    [alert release];
}
- (void)Diddownload:(id)sender
{
    //UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:selectindex];
    //filebutton = (UIButton *)[cell viewWithTag:6];
    [self listserverfile:selectrow];
    NSLog(@"the int string is %@",tmp);
    if([tmp length] != 0)
    {
        
        NSString *str = [[tmp copy] autorelease];
        downloadpath = [[NSMutableString alloc] initWithString:str];
        //[downloadpath appendString:@"\\"];
    }
    else
    {
        //downloadpath = @"";
        downloadpath = [[NSMutableString alloc] initWithString:@""];
    }
    //downloadpath = [downloadpath stringByAppendingString:tmp];
    
    //[downloadpath appendString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];
    Downloadfilename = [[arraydecription objectAtIndex:selectrow] objectForKey:@"name"];
    [self UpdateProgress];
    [NSThread detachNewThreadSelector:@selector(downloadfile) toTarget:self withObject:nil];
    //[self downloadfile];
    
}
- (void)Didupload:(id)sender
{
    //downloadpath = tmp;
    //downloadpath = [downloadpath stringByAppendingString:tmp];
    //downloadpath = [downloadpath stringByAppendingString:@"\\"];
    //downloadpath = [downloadpath stringByAppendingString:filename];
    //NSLog(@"the uploadfile is %@",[mobilefiles1 objectAtIndex:1]);
    [self UpdateProgress];
        [NSThread detachNewThreadSelector:@selector(uploadfile) toTarget:self withObject:nil];
    //[self uploadfile];
}
- (void)Uploadfinish
{
    [tmp release];
    tmp = [[NSMutableString alloc] initWithString:@"手机文件"];
    sendfilename = privfoldername;
    root =1;
    ispriv = 1;
    folderoot =1;
    Foldertype =2;
    [self listfile];
}
- (void)Uploadphotofinish
{
    [UploadView removeFromSuperview];
    [self dismissModalViewControllerAnimated:NO];

    [tmp release];
    tmp = [[NSMutableString alloc] initWithString:@"手机相册"];
    sendfilename = privfoldername;
    Foldertype =2;
    root = 1;
    ispriv = 1;
    folderoot =1;
    [self listfile];


}
- (void)Downloadfinish
{
    [tmp release];
    tmp = [[NSMutableString alloc] initWithString:@""];//[[NSMutableString alloc] initWithString:@"手机相册"];
    //sendfilename = privfoldername;
    Foldertype =1;
    folderoot =0;
    
    [self listmobilefile];
    self.navigationItem.title = @"本地文件";
    [self.tableView reloadData];
}
- (NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[[NSScanner alloc] initWithString:hexCharStr] autorelease];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString; 
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //UIBarButtonItem* newButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New", @"New Button title") style:UIBarButtonItemStyleDone target:self action:@selector(newBookmark:)] autorelease];
    //UIBarButtonItem* backButton = [[[UIBarButtonItem alloc] INIT]]
    	//UIImage *backImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
        //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(folderback)];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"上层目录" style:UIBarButtonItemStylePlain target:self action:@selector(folderback)];
    //[backButton setTintColor:[UIColor whiteColor]];
    backButton.tintColor = [UIColor blueColor];
    /*if(IOS7)
    {
        //[backButton setTintColor:[UIColor whiteColor]];
        backButton.tintColor = [UIColor whiteColor];
        //[backButton set]
    }*/
    /*else
    {
        [backButton setTintColor:[UIColor whiteColor]];
    }*/
    UIBarButtonItem *CloseButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(popview)];
    CloseButton.tintColor = [UIColor blueColor];
    /*if(IOS7)
    {
        //[CloseButton setTintColor:[UIColor whiteColor]];
        CloseButton.tintColor = [UIColor whiteColor];

    }*/
    //[CloseButton setTintColor:[UIColor whiteColor]];
    // set edit button to allow bookmark list editing
    //UIBarButtonItem *CloseButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(popview)];
    //CloseButton.title = @"关闭";
    [[self navigationItem] setLeftBarButtonItem:backButton];
    [[self navigationItem] setRightBarButtonItem:CloseButton];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   	return 1;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(root==1)
    {
        switch (Foldertype) {
            case 1:
                return YES;
                break;
                
            case 2:
                if([arraydecription count]-1<indexPath.row)
                {
                    return NO;
                }
                filename = [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                auth1 = [[arraydecription objectAtIndex:[indexPath row]] objectForKey:@"auth"];
                NSData* authData = [auth1 dataUsingEncoding:NSUTF8StringEncoding];
                //char * auth =[auth UTF8String];
                const char* auth=[authData bytes];
                char   szValue[]  =   "0x11";
                int    nValude    =   0;
                sscanf(auth,"%x",&nValude);
                
                if((nValude&0x80000000)!=0)
                {
                    return NO;
                }
                else
                {
                    if(ispriv==0)
                    {
                        return NO;
                    }
                    else
                    {
                    return YES;
                    }
                }
                /*if((nValude&0x00000001)!=0)
                {
                    return NO;
                }
                else
                {
                    return YES;
                }*/
                break;
        }
    }
    else
    {
    return NO;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
        NSError *err;
    NSFileManager* fm=[NSFileManager defaultManager];
    NSString *RealorDirectory = [NSString stringWithFormat:@"%@/Documents/%@/", NSHomeDirectory(), @"Realor"];
    mobilefiles = [fm subpathsAtPath:RealorDirectory];
    int num = [mobilefiles count];
    if(Foldertype == 1)
    {

    NSLog(@"the num is %d",num);
    NSString* localfilename = [mobilefiles objectAtIndex:indexPath.row];
    //NSFileManager* fm=[NSFileManager defaultManager];
    //NSString *RealorDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
     FileFullPath = [RealorDirectory stringByAppendingPathComponent:localfilename];

    NSLog(@"the filpath is %@",FileFullPath);
    }
    else
    {
    delfilename = [[NSString alloc] init];

    delfilename = [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSLog(@"the delfilename is %@",delfilename);
    }
    switch(Foldertype)
    {
            case 1:
            [fm removeItemAtPath:FileFullPath error:&err];
            Foldertype = 1;

            [self listmobilefile];
            break;
             case 2:
            //[self deletefile:delfilename];
            Foldertype = 2;
            [NSThread detachNewThreadSelector:@selector(deletefile) toTarget:self withObject:nil];
            //[self.tableView reloadData];
            break;


    }
    //[self deletefile];

   /* if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataArray removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [testTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];*/
        
    }
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSInteger rowCount;
    //[self listmobilefile];
    if(root == 0)
    {return  [Cellarray count];}
    else
    {
        int count = 0;
        switch (Foldertype)//(Foldertype == 2)
        {
            case 0:
                break;
            case 1:
                //[self listmobilefile];
                count = [mobilefiles count];
                NSLog(@"the count is %d",count);
                break;
            case 2:
                /*if(serverroot == 0)
                    count = 2;
                else
                {
                if(folderoot == 0)
                {
                    if(ispriv == 0)
                    {
                        count = [sharefolder count];
                        NSLog(@"the sharefolder is %d",count);
                    }
                    else
                    {
                        count = [privatefolder count];
                        NSLog(@"the privatefolder is %d",count);
                        
                    }

                }
                else
                {*/

                    count =[arraydecription count];
                    NSLog(@"the arraydecription is %d",count);

                //}
                //}
                break;
        }
        return count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        filebutton.hidden = YES;
        filebuttonupload.hidden = YES;
        [[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:self options:NULL];
        cell = FileCell;
            if(indexPath.row == 0)
            {
            camerabutton = (UIButton *)[cell viewWithTag:10];
            [camerabutton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchDown];
            }
    //NSString *filename = [[Cellarray objectAtIndex:0] objectForKey:@"name"];
        NSLog(@"the filename is %@",filename);
    if(root == 0)
    {
        camerabutton.hidden = YES;
        filename = [[Cellarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        UILabel *appName = (UILabel *)[cell viewWithTag:1];
        appName.text = filename;
        
        UIImageView *appImg = (UIImageView *)[cell viewWithTag:2];
        fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
        camerabutton.hidden = NO;
        [appImg setImage:fileimage];

    //appImg.image = fileimage;
    }
    else
    {
        camerabutton.hidden = YES;
        UILabel *appName;
        UIImageView *appImg;
        NSFileManager* fm=[NSFileManager defaultManager];
        NSString *RealorDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
        mobilefiles = [fm subpathsAtPath:RealorDirectory];
        switch (Foldertype)//(Foldertype == 2)
        {
            case 0:
                break;
            case 1:
                filename = [mobilefiles objectAtIndex:indexPath.row];
                appName = (UILabel *)[cell viewWithTag:1];
                appName.text = filename;
                appImg = (UIImageView *)[cell viewWithTag:2];
                fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"png"]];
                [appImg setImage:fileimage];
                //filebutton = (UIButton *)[cell viewWithTag:3];
                //downloadpath = [[NSMutableString alloc] initWithString:tmp];
                
                //[filebutton addTarget:self action:@selector(Didupload:) forControlEvents:UIControlEventTouchDown];
                //uploadfile
                break;
            case 2:
                filename = [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                appName = (UILabel *)[cell viewWithTag:1];
                appName.text = filename;
                auth1 = [[arraydecription objectAtIndex:[indexPath row]] objectForKey:@"auth"];
                NSData* authData = [auth1 dataUsingEncoding:NSUTF8StringEncoding];
                //char * auth =[auth UTF8String];
                const char* auth=[authData bytes];
                char   szValue[]  =   "0x11";
                int    nValude    =   0;
                sscanf(auth,"%x",&nValude);
                
                if((nValude&0x80000000)!=0)
                {
                    appImg = (UIImageView *)[cell viewWithTag:2];
                    fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                    [appImg setImage:fileimage];
                    
                }
                else
                {
                    appImg = (UIImageView *)[cell viewWithTag:2];
                    fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"png"]];
                    [appImg setImage:fileimage];
                    
                }


                // filebutton = (UIButton *)[cell viewWithTag:3];
                
                //downloadpath = [[NSMutableString alloc] initWithString:tmp];
                /* downloadpath = tmp;
                 //downloadpath = [downloadpath stringByAppendingString:tmp];
                 downloadpath = [downloadpath stringByAppendingString:@"\\"];
                 downloadpath = [downloadpath stringByAppendingString:filename];*/
                //NSString* str = [[NSString alloc] stringByAppendingString:@"内容"];
                //[filebutton setTag:(int)str];
                
                break;
        }
    }

    }
    else
    {
        filebutton.hidden = YES;
        filebuttonupload.hidden = YES;
        if(indexPath.row == 0)
        {
            camerabutton = (UIButton *)[cell viewWithTag:10];
            [camerabutton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchDown];
        }
        if(root == 0)
        {

                camerabutton.hidden = YES;
                filename = [[Cellarray objectAtIndex:indexPath.row] objectForKey:@"name"];
                UILabel *appName = (UILabel *)[cell viewWithTag:1];
                appName.text = filename;
                
                UIImageView *appImg = (UIImageView *)[cell viewWithTag:2];
                fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                camerabutton.hidden = NO;
               [appImg setImage:fileimage];
            camerabutton.hidden = NO;
            //appImg.image = fileimage;
        }
        else
        {
            camerabutton.hidden = YES;
        UILabel *appName;
        UIImageView *appImg;
        NSFileManager* fm=[NSFileManager defaultManager];
        NSString *RealorDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
        mobilefiles = [fm subpathsAtPath:RealorDirectory];
        switch (Foldertype)//(Foldertype == 2)
        {
            case 0:
                break;
            case 1:
                filename = [mobilefiles objectAtIndex:indexPath.row];
                appName = (UILabel *)[cell viewWithTag:1];
                appName.text = filename;
                appImg = (UIImageView *)[cell viewWithTag:2];
                fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"png"]];
                [appImg setImage:fileimage];
                //[appImg setImage:fileimage];

                //filebutton = (UIButton *)[cell viewWithTag:3];
                //downloadpath = [[NSMutableString alloc] initWithString:tmp];

                //[filebutton addTarget:self action:@selector(Didupload:) forControlEvents:UIControlEventTouchDown];
                //uploadfile
                break;
            case 2:
               /* if(serverroot == 0)
                {
                    if(indexPath.row == 0)
                    {
                        filename = @"公有文件";
                        appName = (UILabel *)[cell viewWithTag:1];
                        appName.text = filename;
                        ispriv = 0;
                    }
                    else
                    {
                        filename = @"私有文件";
                        appName = (UILabel *)[cell viewWithTag:1];
                        appName.text = filename;
                        ispriv = 1;
                        //serverroot = 1;
                    }
                    appImg = (UIImageView *)[cell viewWithTag:2];
                    fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                    [appImg setImage:fileimage];
                }
                else
                {
                if(folderoot == 0)
                {
                    if(ispriv == 0)
                    {
                        filename = [[sharefolder objectAtIndex:indexPath.row] objectForKey:@"name"];
                        [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                        appName = (UILabel *)[cell viewWithTag:1];
                        appName.text = filename;
                    }
                    else
                    {
                        filename = [[privatefolder objectAtIndex:indexPath.row] objectForKey:@"name"];
                        [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                        appName = (UILabel *)[cell viewWithTag:1];
                        appName.text = filename;
                    }
                        appImg = (UIImageView *)[cell viewWithTag:2];
                        fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                    [appImg setImage:fileimage];



                    
                    //}
                }
                else
                {*/
                filename = [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                appName = (UILabel *)[cell viewWithTag:1];
                appName.text = filename;
                    auth1 = [[arraydecription objectAtIndex:[indexPath row]] objectForKey:@"auth"];
                    NSData* authData = [auth1 dataUsingEncoding:NSUTF8StringEncoding];
                    //char * auth =[auth UTF8String];
                    const char* auth=[authData bytes];
                   // char   szValue[]  =   "0x11";
                    int    nValude    =   0;
                    sscanf(auth,"%x",&nValude);
                    
                    if((nValude&0x80000000)!=0)
                    {
                        appImg = (UIImageView *)[cell viewWithTag:2];
                        fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"png"]];
                        [appImg setImage:fileimage];

                    }
                    else
                    {
                        appImg = (UIImageView *)[cell viewWithTag:2];
                        fileimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"file" ofType:@"png"]];
                        [appImg setImage:fileimage];

                    }
                break;
                }
            
                }
               // filebutton = (UIButton *)[cell viewWithTag:3];
                
                //downloadpath = [[NSMutableString alloc] initWithString:tmp];
               /* downloadpath = tmp;
                //downloadpath = [downloadpath stringByAppendingString:tmp];
                downloadpath = [downloadpath stringByAppendingString:@"\\"];
                downloadpath = [downloadpath stringByAppendingString:filename];*/
                //NSString* str = [[NSString alloc] stringByAppendingString:@"内容"];
                //[filebutton setTag:(int)str];

        
        //appImg.image = fileimage;
    }

    return cell;
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//if (([indexPath indexAtPosition:([indexPath length] - 1)] == [SelectedIndex indexAtPosition:([SelectedIndex length] - 1)]) && showTip)
        return 80.0;
	return tableView.rowHeight;
}


- (void)popview
{
    [delegate toolbarshow];
    //[delegate extboardshow];
    //[self dismissModalViewControllerAnimated:NO];
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)folderback
{
    NSString *tmp1;
   // tmptmp = [[NSString alloc] initWithString:tmp];
    int findnum = 0;
    int findnumsum = 0;
    switch (Foldertype)//(Foldertype == 2)
    {
        case 1:
            root = 0;
            self.navigationItem.title = @"";
           [[self tableView] reloadData];
            [self listrootfile];
            break;
        case 2:
            tmp1 = [[NSMutableString alloc] initWithString:@""];
            tmp1 = [tmp1 stringByAppendingString:tmp];
            NSLog(@"the tmp1 is %@",tmp1);
         // tmp1 = [NSMutableString alloc]  tmp;
            NSLog(@"the tmp is %@",tmp);
          if([tmp length]==0)
          {
                 //root = 0;
                if(folderoot ==1)
                {
                    [self listrootfile];
                    folderoot = 0;
                    self.navigationItem.title = @"服务器文件";
                    //self.navigationItem.title = title
                    [[self tableView] reloadData];
                }
                /*else
                {
                if(serverroot == 1)
                {
                    [NSThread detachNewThreadSelector:@selector(listrootfile) toTarget:self withObject:nil];
                    serverroot = 0;
                    [[self tableView] reloadData];
                }*/
                else
                {
                    root = 0;
                    self.navigationItem.title = @"";
                [[self tableView] reloadData];
                }
                //}
          }
           else
          {
           while(1)
           {
             if([tmp1 rangeOfString:@"\\"].location!=NSNotFound)
           {
              findnum = [tmp1 rangeOfString:@"\\"].location;
               NSLog(@"the findnum1 is %d",findnum);
              tmp1 = [tmp1 substringFromIndex:findnum+1];
               NSLog(@"the tmp1 is %@",tmp1);
               findnumsum += findnum+1;
           }
           else
           {
            break;
           }
        
           }
           NSLog(@"the findnum is %d",findnum);
              NSLog(@"the tmp is %@",tmp);
              NSLog(@"temp length is %d",[tmp length]);
           //NSRange range = NSMakeRange (findnum, [tmp length]-findnum);//[tmp length]);
           //NSRange range = NSMakeRange ([tmp length]-findnum,findnum);
           //NSLog(@"the range length is %d",range.length);
           //NSLog(@"the location is %d",range.location);
              NSRange range;
              if(findnumsum == 0)
              {
                  range.location = findnumsum;
                  range.length = [tmp length]-findnumsum;
              }
              else
              {
              range.location = findnumsum-1;
              range.length = [tmp length]-findnumsum+1;
              }
              NSLog(@"the range length is %d",range.length);
              NSLog(@"the location is %d",range.location);
           [tmp deleteCharactersInRange:range];


           NSLog(@"the tmp string is %@",tmp);
           [NSThread detachNewThreadSelector:@selector(listfile) toTarget:self withObject:nil];
           }
            break;
    }
}
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*picker  = [[UIImagePickerController alloc] init];
    //picker.i
    //picker.showsCameraControls = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //picker.navigationItem.rightBarButtonItem.title=@"取消";
     NSLog(@"the view num is %@",picker.navigationItem.rightBarButtonItem.title);
    NSLog(@"the view num is %d",[[[picker toolbar] items] count]);
    picker.title=@"相册";
    //picker.editButtonItem.title = @"删除";
    //[picker setNavigationBarHidden:TRUE];
    
   // NSString *title = [[picker ] title];
    //NSString *title = [picker title];
    //[]
   // NSLog(@"the title is %@",title);
     //NSString *title = picker.view. title];
    //NSLog(@"the title is %@",title);
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];
    [picker release];*/
    /*if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *cameraVC = [[UIImagePickerController alloc] init];
        [cameraVC setSourceType:UIImagePickerControllerSourceTypeCamera];
        [cameraVC.navigationBar setBarStyle:UIBarStyleBlack];
        [cameraVC setDelegate:self];
        [cameraVC setAllowsEditing:NO];
        //显示Camera VC
        [self presentModalViewController:cameraVC animated:NO];
        picker.delegate = self;
        
    }*/
    UITableViewCell *getcell = [tableView cellForRowAtIndexPath:indexPath];
    labloaded = (UILabel *)[getcell viewWithTag:4];
    labsum = (UILabel *)[getcell viewWithTag:5];
    progress = (UIProgressView *)[getcell viewWithTag:6];
    //selectindex = [NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section]];
    selectindex = [indexPath retain];
    //selectindex = [indexPath section];
    if(root == 0)
    {
        getfilename =@"";

        //[[Cellarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        //if(indexPath.row == 0)
        tmp = [[NSMutableString alloc] initWithString:getfilename];
        
        Foldertype = indexPath.row;
       // [NSThread detachNewThreadSelector:@selector(listrootfile) toTarget:self withObject:nil];
        switch (Foldertype)//(Foldertype == 2)
        {
            case 0:
                //[self.navigationController setNavigationBarHidden:YES animated:NO];

                [self localphoto];
                break;
            case 1:
                root = 1;
                self.navigationItem.title = @"本地文件";
                [self listmobilefile];
                break;
            case 2:
                 //[self tableView:] r didSelectRowAIndexPath:<#(NSIndexPath *)#>]
                    root = 1;
                self.navigationItem.title = @"服务器文件";
                    [self.tableView reloadData];

                break;
        }
    }
    else
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        filebutton.hidden = YES;
        filebuttonupload.hidden = YES;
        filebutton = (UIButton *)[cell viewWithTag:3];

     NSFileManager* fm=[NSFileManager defaultManager];
     NSString *RealorDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
     mobilefiles1 = [fm subpathsAtPath:RealorDirectory];
    switch (Foldertype)//(Foldertype == 2)
    {
        case 0:
            break;
        case 1:
            
                filebuttonupload = (UIButton *)[cell viewWithTag:8];
                filebuttonupload.hidden = NO;
                //labloaded.hidden = NO;
                //labsum.hidden = NO;
                //progress.hidden = NO;

                //printf("%x/n",nValude);
                //return 0;
                //NSLog(@"the int string is %@",[self stringFromHexString:auth1]);
                //int intString = [auth1 intValue];
                 //uploadfilename = [[NSString alloc] init];
                 NSString *getuploadfile = [mobilefiles1 objectAtIndex:[indexPath row]];
                 uploadfilename = [[NSString alloc] initWithString:getuploadfile];
                 NSLog(@"the uploadfile is %@",uploadfilename);
                [filebuttonupload addTarget:self action:@selector(Didupload:) forControlEvents:UIControlEventTouchDown];
            
            break;
        case 2:

            /*if(serverroot == 0)
            {

                //rootflag = 1;

                
                    if(indexPath.row == 0)
                    {
                        if([sharefolder count]==0)
                        {
                            [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
                                       messageStr:[[NSBundle mainBundle] localizedStringForKey:@"nosharefile" value:@"Can not connect server!" table:nil]
                                      btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
                                              tag:0];
                        }
                        else
                        {
                         rootflag = 1;
                        ispriv = 0;
                            serverroot = 1;

                            [self.tableView reloadData];
                        }

                    }
                    else
                    {
                        if([privatefolder count]==0)
                        {
                            [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
                                       messageStr:[[NSBundle mainBundle] localizedStringForKey:@"noprivate" value:@"Can not connect server!" table:nil]
                                      btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
                                              tag:0];
                        }
                        else
                        {
                            rootflag = 1;
                            ispriv = 1;
                            serverroot = 1;

                            [self.tableView reloadData];

                        }
                        //ispriv = 1;
                    
                }
            }
            else
            {
            if(folderoot == 0)
            {
                rootflag = 1;
                //rootfilename =
                if(ispriv == 0)
                {

                    sendfilename = [[sharefolder objectAtIndex:indexPath.row] objectForKey:@"name"];
                }
                else
                {
                    if([privatefolder count]==0)
                    {
                        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
                                   messageStr:[[NSBundle mainBundle] localizedStringForKey:@"noprivatefile" value:@"Can not connect server!" table:nil]
                                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
                                          tag:0];
                    }
                    else
                    {
                    sendfilename = [[privatefolder objectAtIndex:indexPath.row] objectForKey:@"name"];
                   // }
                }
               }*/
                //[filebutton addTarget:self action:@selector(listfile:) forControlEvents:UIControlEventTouchDown];
                //[self.tableView reloadData];
            /*if(filebutton.hidden == NO)
            {
                [self folderback];
            }*/

                       auth1 = [[arraydecription objectAtIndex:[indexPath row]] objectForKey:@"auth"];

                NSLog(@"the folderroot is %d",folderoot);

            NSLog(@"the auth is %@",auth1);
            NSData* authData = [auth1 dataUsingEncoding:NSUTF8StringEncoding];
             //char * auth =[auth UTF8String];
            const char* auth=[authData bytes];
            char   szValue[]  =   "0x11";
            int    nValude    =   0;
            sscanf(auth,"%x",&nValude);
            
            if((nValude&0x80000000)!=0)
            {
                if(folderoot == 0)
                {
                    sendfilename = [[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
                    folderoot = 1;
                    rootflag =0;
                    NSData* authData = [auth1 dataUsingEncoding:NSUTF8StringEncoding];
                    //char * auth =[auth UTF8String];
                    const char* auth=[authData bytes];
                    char   szValue[]  =   "0x11";
                    int    nValude    =   0;
                    sscanf(auth,"%x",&nValude);
                    
                    //if((nValude&0x80000000)!=0)
                    if((nValude&0x40000000)==0)
                    {
                        ispriv = 0;
                    }
                    else
                    {
                        ispriv = 1;
                    }
                    
                }
                else
                {
                    [self listserverfile:indexPath.row];
                }
                filebutton.hidden = YES;
                /*if(folderoot == 1)
                {
                   [self listserverfile:indexPath.row]; 
                }*/

                [NSThread detachNewThreadSelector:@selector(listfile) toTarget:self withObject:nil];


            }
            else
            {
                filebutton.hidden = NO;
                //printf("%x/n",nValude);
                //return 0;
                //NSLog(@"the int string is %@",[self stringFromHexString:auth1]);
                //int intString = [auth1 intValue];
                selectrow = [indexPath row];
                NSLog(@"the downloadpath is %@",downloadpath);
                [filebutton addTarget:self action:@selector(Diddownload:) forControlEvents:UIControlEventTouchDown];
                //[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"];
            
            //}
            }
            break;
    }
    /*if([tmp length]==0)
    {
        //getfilename = [getfilename stringByAppendingString:@"\\"];
        [tmp appendString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];
        //getfilename = [getfilename stringByAppendingString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];
    }
    else
    {
        [tmp appendString:@"\\"];
        [tmp appendString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];
        //getfilename = [getfilename stringByAppendingString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];*/
       // getname =[NSString stringWithString:tmp];
    
    }

}

- (void) localphoto
{
   /* pickercontroller = [[UIImagePickerController alloc] init];
    pickercontroller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickercontroller.delegate = self;
    //pickercontroller.allowsMultipleSelection = YES;
   
    //设置选择后的图片可被编辑
    pickercontroller.allowsEditing = YES;
    [self presentModalViewController:pickercontroller animated:YES];
    [pickercontroller release];*/
    imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
    [imagePickerController release];
    [navigationController release];

}
- (void) listmobilefile
{
    NSFileManager* fm=[NSFileManager defaultManager];
    NSString *RealorDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
    mobilefiles = [[NSArray alloc] initWithArray:[fm subpathsAtPath:RealorDirectory]];
    //mobilefiles = [fm subpathsAtPath:RealorDirectory];
    //[self performSelectorOnMainThread:@selector(gotoreload) withObject:nil waitUntilDone:YES];
    Foldertype = 1;
    [[self tableView] reloadData];
    openmobileflag = TRUE;
    //NSLog(@"the realordirectory is %@",[files objectAtIndex:0]);

}
- (void)setvirtualinfo:(NSString *)Vdvd Userid:(NSString *)Vdusrid vdsp:(NSString *)Vdvdsp
{
    vd = [[NSString alloc] initWithString:Vdvd];
    Userid =[[NSString alloc] initWithString:Vdusrid];
    vdsp = [[NSString alloc] initWithString:Vdvdsp];
    //vd = Vdvd;
    //Userid = Vdusrid;
    // vdsp = Vdvdsp;
    NSLog(@"the vd is %@,the Userid is %@,the vdsp is %@",vd,Userid,vdsp);
}
-(void)takePhoto:(id) sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    camera = 1;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
       // [picker release];
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }

}

-(void)cancelCamera{
    //[picker dismissModalViewControllerAnimated:YES];
}
-(void)savePhoto{
    //拍照，会自动回调- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info，对于自定义照相机界面，拍照后回调可以不退出实现连续拍照效果
    //[picker takePicture];
    //[picker ]
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"Image Picker Controller canceled.");
    //Cancel以后将ImagePicker删除
    [self dismissModalViewControllerAnimated:NO];
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
- (void)Adduploadview:(int)width height:(int)height
{

    UploadView.backgroundColor = [UIColor clearColor];
   // UploadView.alpha=0.8;
    NSString *machinename = [self getMachine];
    machinename=[machinename substringWithRange:NSMakeRange(0, 4)];
    NSLog(@"the machinename is %@",machinename);
    int leftwidth = 0;
    UIImage *uploadimage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connectimage" ofType:@"png"]];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:uploadimage];
    [imageview setFrame:CGRectMake((width-128)/2, (height-128)/2, 128, 128)];
    UILabel *uploadlabel = [[UILabel alloc] initWithFrame:CGRectMake((width-128)/2+32,(height-128)/2+66,80,40)];
    [uploadlabel setBackgroundColor:[UIColor clearColor]];
    uploadlabel.text = @"正在上传";
    uploadlabel.textColor = [UIColor whiteColor];
    UIActivityIndicatorView *ActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    ActivityIndicator.center = CGPointMake((width-128)/2+63, (height-128)/2+46);
    [ActivityIndicator startAnimating];
    
    
    [UploadView addSubview:imageview];
    [UploadView addSubview:uploadlabel];
    [UploadView addSubview:ActivityIndicator];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(id)info {
    //picker.showsCameraControls  = NO;
    if(camera == 1)
    //if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIView *PLCameraView=[self findView:picker.view withName:@"PLCropOverlay"];
        UploadView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,PLCameraView.frame.size.width,PLCameraView.frame.size.height)]autorelease];
        [self Adduploadview:PLCameraView.frame.size.width height:PLCameraView.frame.size.height];
       // [UploadView addSubview:mybutton];
        [PLCameraView addSubview:UploadView];
        //[PLCameraView addSubview:mybutton];
               //[self performSelectorOnMainThread:@selector(Uploadprogress) withObject:nil waitUntilDone:YES];
       NSDictionary *mediaInfo = info;
        UIImage *image = [mediaInfo objectForKey:@"UIImagePickerControllerOriginalImage"];
        //[self dismissModalViewControllerAnimated:NO];
        //[self.view addSubview:UploadView];
        [NSThread detachNewThreadSelector:@selector(Uploadphoto:) toTarget:self withObject:(id) image];

            //UIImage *compressedImage = [UIImage imageWithData:imageData];
            //把自定义的view设置到imagepickercontroller的overlay属性中
            //[picker.view addSubview:tool];// = tool;
            /*NSFileManager *fileManager = [NSFileManager defaultManager];
             BOOL isDir = YES;
             NSString *documentDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
             BOOL existed = [fileManager fileExistsAtPath:documentDirectory isDirectory:&isDir];
             if ( !(isDir == YES && existed == YES) )
             {
             [fileManager createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
             }
             int *numrecieve = malloc(sizeof(int));
             // DBNAME 是要查找的文件名字，文件全名
             long long int sum = 0;
             /*NSString *documentDir = [documentDirectory stringByAppendingPathComponent:@"tupian.jpg"];
             [self writefiledata:documentDir writedata:imageData];*/
            camera = 0;
            //[PhotoFilename release];
    }
    else
    {
        //UIView *PLCameraView=[self findView:picker.view withName:@"PLCropOverlay"];
        //UploadView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,picker.cameraOverlayView.frame.size.width,picker.cameraOverlayView.frame.size.height)]autorelease];
        UploadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imagePickerController.view.frame.size.width, imagePickerController.view.frame.size.height)];
        [self Adduploadview:imagePickerController.view.frame.size.width height:imagePickerController.view.frame.size.height];
        // [UploadView addSubview:mybutton];
        //QBAssetCollectionViewController *assetview = [imagePickerController GetassetviewController];
        [imagePickerController assetaddsubview:UploadView];
        //[assetview.view addSubview:UploadView];
    NSArray *mediaInfoArray = (NSArray *)info;

    [NSThread detachNewThreadSelector:@selector(UploadMultiplephoto:) toTarget:self withObject:(id) mediaInfoArray];
    NSLog(@"Selected %d photos", mediaInfoArray.count);

    NSLog(@"Image Picker Controller did finish picking media.");
    //TODO:选择照片或者照相完成以后的处理
    }
    //[self dismissModalViewControllerAnimated:NO];


}
- (void)Uploadprogress
{
    //UploadView.hidden = NO;
}
- (void)timerFired1
{
       //[self performSelectorOnMainThread:@selector(Uploadphotofinish) withObject:nil waitUntilDone:YES];
    [self Uploadphotofinish];
    [EscTimer invalidate];
}
- (void) listserverfile:(int)row
{
    if([tmp length]==0)
    {
        //getfilename = [getfilename stringByAppendingString:@"\\"];
        [tmp appendString:[[arraydecription objectAtIndex:row] objectForKey:@"name"]];
        NSLog(@"the tmp is %@",tmp);
        //getfilename = [getfilename stringByAppendingString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];
    }
    else
    {
        [tmp appendString:@"\\"];
        [tmp appendString:[[arraydecription objectAtIndex:row] objectForKey:@"name"]];
        NSLog(@"the tmp is %@",tmp);
        /* NSString *tmp1;
         int findnum = 0;
         tmp1 = tmp;
         while(1)
         {
         if([tmp1 rangeOfString:@"\\"].location!=NSNotFound)
         {
         findnum = [tmp1 rangeOfString:@"\\"].location;
         tmp1 = [tmp1 substringFromIndex:findnum+1];
         }
         else
         {
         break;
         }
         
         }
         NSLog(@"the findnum is %d",findnum);
         tmp1 = [tmp substringToIndex:findnum];
         NSLog(@"the tmp string is %@",tmp1);*/
        //getfilename = [getfilename stringByAppendingString:[[arraydecription objectAtIndex:indexPath.row] objectForKey:@"name"]];
    }
}
-(int) listrootfile
{
    NSString *Virtualcmd = @"usr=";
    Virtualcmd = [Virtualcmd stringByAppendingString:Userid];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"root="];
    Virtualcmd = [Virtualcmd stringByAppendingString:@""];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    
    Virtualcmd = [Virtualcmd stringByAppendingString:@"priv="];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"1"];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    
    Virtualcmd = [Virtualcmd stringByAppendingString:@"name="];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"\""];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"\""];
    int num = [Virtualcmd length];
    NSLog(@"the num is %d",num);
    unichar *Cmdchar = (unichar *)malloc(num*sizeof(unichar));
    int i=0;
    for(i = 0 ; i < num ; i++)
    {
        *Cmdchar = [Virtualcmd characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar);
        //Cmdchar++;
        Cmdchar++;
    }
    int length = 2*[Virtualcmd length]+10;
    printf("the hostname is%s",gethostname);
    if((Sendcmd(length,Cmdchar-num,list,gethostname,[vdsp intValue])!=-1))
       {
//           16.07.18
//    int numread = readgetstrlength(10);
           int numread = 10;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSLog(@"the num read is %d",numread);
    if(numread - 10 == 0)
    {
        return 1;
    }
    unsigned short * unistr = readcmdstr(numread);
    //char * getstr = malloc(50);
    char *getstr = unicode_to_utf8(unistr,numread-10);
    printf("the getstr is %s",getstr);
    NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];
    NSMutableArray *getarraystring = [self SplitString:encrypted];
    [self Getsharename];
    return 0;
       }
    else
    {
        [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
                   messageStr:[[NSBundle mainBundle] localizedStringForKey:@"connect virtualdisk error" value:@"Can not connect server!" table:nil]
                  btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
                          tag:0];
        return 0;
    }
    //[self performSelectorOnMainThread:@selector(gotoreload) withObject:nil waitUntilDone:YES];
}

-(void) Getsharename
{
    sharefolder = [[NSMutableArray alloc]init];
    privatefolder = [[NSMutableArray alloc]init];
    for(int i=0;i<[arraydecription count];i++)
    {
        NSString *auth1 = [[arraydecription objectAtIndex:i] objectForKey:@"auth"];
        NSData* authData = [auth1 dataUsingEncoding:NSUTF8StringEncoding];
        //char * auth =[auth UTF8String];
        const char* auth=[authData bytes];
        char   szValue[]  =   "0x11";
        int    nValude    =   0;
        sscanf(auth,"%x",&nValude);
        if((nValude&0x40000000)==0)
        {
            [sharefolder addObject:[arraydecription objectAtIndex:i]];
        }
        else
        {
            [privatefolder addObject:[arraydecription objectAtIndex:i]];
        }
    }
    //rootflag = 1;
    
    if([privatefolder count] != 0)
    {
           privfoldername = [[NSString alloc] initWithString:[[privatefolder objectAtIndex:0] objectForKey:@"name"]];
    }

    NSLog(@"the foldername is %@",privfoldername);
    //[self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"]] foldername:@"手机相册"]];
    /*[self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"] foldername:@"手机相册"];
    [self newfold:[[privatefolder objectAtIndex:0] objectForKey:@"name"] foldername:@"手机文件"];*/

    
}
- (void) gethost:(char *)host;
{
    gethostname = host;
    printf("the hostname is %s",gethostname);
}
- (void) folderempty
{
    [self ErrorMessageBox:[[NSBundle mainBundle] localizedStringForKey:@"AlertTitle" value:@"Error Infomation" table:nil]
     messageStr:[[NSBundle mainBundle] localizedStringForKey:@"folderempty" value:@"Can not connect server!" table:nil]
     btnTitleStr:[[NSBundle mainBundle] localizedStringForKey:@"OkBtnCaption" value:@"OK" table:nil]
     tag:0];
    [self folderback];
}
-(void) listfile
{
    //NSString *Virtualcmd = @"usr=usr00000001,root=11,priv=1,name=\"\"";
    NSLog(@"the listfile name is%@",tmp);
    //NSString *immutableString = [NSString stringWithString:yourMutableString];

    NSString *Virtualcmd = @"usr=";
    Virtualcmd = [Virtualcmd stringByAppendingString:Userid];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"root="];
    Virtualcmd = [Virtualcmd stringByAppendingString:sendfilename];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    
    Virtualcmd = [Virtualcmd stringByAppendingString:@"priv="];
    Virtualcmd = [Virtualcmd stringByAppendingString:[NSString stringWithFormat:@"%d",ispriv]];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    //NSString *stringInt = [NSString stringWithFormat:@"%d",intString]
    Virtualcmd = [Virtualcmd stringByAppendingString:@"name="];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"\""];
    Virtualcmd = [Virtualcmd stringByAppendingString:tmp];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"\""];
    NSLog(@"the string is %@",Virtualcmd);
    //NSString *me = @"by";
    int num = [Virtualcmd length];
    NSLog(@"the num is %d",num);
    unichar *Cmdchar = (unichar *)malloc(num*sizeof(unichar));
    int i=0;
    for(i = 0 ; i < num ; i++)
    {
        *Cmdchar = [Virtualcmd characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar);
        //Cmdchar++;
        Cmdchar++;
    }
    int length = 2*[Virtualcmd length]+10;
    Sendcmd(length,Cmdchar-num,list,gethostname,[vdsp intValue]);
//    16.07.18
//    int numread = readgetstrlength(10);
    int numread = 10;
    if(numread - 10 == 0)
    {

            [self performSelectorOnMainThread:@selector(folderempty) withObject:nil waitUntilDone:YES];
        return;
    }
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    char *getstr;
    NSLog(@"the numread is %d",numread);
    NSString *getsumstring;
    getsumstring = [[NSString alloc] init];
    for(int i=0;i<=(numread-10)/256;i++)
    {
    if(i == (numread-10)/256)
    {
        unsigned short * unistr = readcmdstr((numread - 10)%256);
        getstr = unicode_to_utf8(unistr,(numread - 10)%256);
        printf("the getstr is %s",getstr);
    }
    else
    {
    unsigned short * unistr = readcmdstr(256);
     getstr = unicode_to_utf8(unistr,256);
    printf("the getstr is %s",getstr);
    }
    NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];
        getsumstring = [getsumstring stringByAppendingString:encrypted];
        NSLog(@"the getsumstring is %@",getsumstring);

    }
    NSLog(@"the getsumstring is %@",getsumstring);
    //char * getstr = malloc(50);
    /*NSData *respData = [NSData dataWithBytes:(char *)unistr length:numread-10];
    NSString *result=[[NSString alloc]initWithData:respData encoding:NSUnicodeStringEncoding];
    NSLog(@"the result is %@",result);
    char *getstr = unicode_to_utf8(unistr,numread-10);*/
    /*int charscount = (numread-10) / sizeof(uint16_t);
    char *getstr = (char *)malloc(charscount * 3 + 1);
    memset(getstr, 0, charscount * 3 + 1);
    enc_unicode_to_utf8_one(unistr,getstr,charscount * 3 + 1);*/
    printf("the getstr is %s",getstr);
    NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];
    NSMutableArray *getarraystring = [self SplitString:getsumstring];
    [self performSelectorOnMainThread:@selector(gotoreload) withObject:nil waitUntilDone:YES];
}
-(int) listfiletest
{
    //NSString *Virtualcmd = @"usr=usr00000001,root=11,priv=1,name=\"\"";
    NSLog(@"the listfile name is%@",tmp);
    //NSString *immutableString = [NSString stringWithString:yourMutableString];
    
    NSString *Virtualcmd = @"usr=";
    Virtualcmd = [Virtualcmd stringByAppendingString:Userid];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"root="];
    Virtualcmd = [Virtualcmd stringByAppendingString:sendfilename];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    
    Virtualcmd = [Virtualcmd stringByAppendingString:@"priv="];
    Virtualcmd = [Virtualcmd stringByAppendingString:[NSString stringWithFormat:@"%d",ispriv]];
    Virtualcmd = [Virtualcmd stringByAppendingString:@","];
    //NSString *stringInt = [NSString stringWithFormat:@"%d",intString]
    Virtualcmd = [Virtualcmd stringByAppendingString:@"name="];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"\""];
    Virtualcmd = [Virtualcmd stringByAppendingString:tmp];
    Virtualcmd = [Virtualcmd stringByAppendingString:@"\""];
    NSLog(@"the string is %@",Virtualcmd);
    //NSString *me = @"by";
    int num = [Virtualcmd length];
    NSLog(@"the num is %d",num);
    unichar *Cmdchar = (unichar *)malloc(num*sizeof(unichar));
    int i=0;
    for(i = 0 ; i < num ; i++)
    {
        *Cmdchar = [Virtualcmd characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar);
        //Cmdchar++;
        Cmdchar++;
    }
    int length = 2*[Virtualcmd length]+10;
    Sendcmd(length,Cmdchar-num,list,gethostname,[vdsp intValue]);
//    16.07.18
//    int numread = readgetstrlength(10);
    int numread = 10;
    if(numread== 10)
    {
        return 1;
    }
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    char *getstr;
    NSLog(@"the numread is %d",numread);
    NSString *getsumstring;
    getsumstring = [[NSString alloc] init];
    for(int i=0;i<=(numread-10)/256;i++)
    {
        if(i == (numread-10)/256)
        {
            unsigned short * unistr = readcmdstr((numread - 10)%256);
            getstr = unicode_to_utf8(unistr,(numread - 10)%256);
            printf("the getstr is %s",getstr);
        }
        else
        {
            unsigned short * unistr = readcmdstr(256);
            getstr = unicode_to_utf8(unistr,256);
            printf("the getstr is %s",getstr);
        }
        NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];
        getsumstring = [getsumstring stringByAppendingString:encrypted];
        NSLog(@"the getsumstring is %@",getsumstring);
        
    }
    NSLog(@"the getsumstring is %@",getsumstring);
    //char * getstr = malloc(50);
    /*NSData *respData = [NSData dataWithBytes:(char *)unistr length:numread-10];
     NSString *result=[[NSString alloc]initWithData:respData encoding:NSUnicodeStringEncoding];
     NSLog(@"the result is %@",result);
     char *getstr = unicode_to_utf8(unistr,numread-10);*/
    /*int charscount = (numread-10) / sizeof(uint16_t);
     char *getstr = (char *)malloc(charscount * 3 + 1);
     memset(getstr, 0, charscount * 3 + 1);
     enc_unicode_to_utf8_one(unistr,getstr,charscount * 3 + 1);*/
    printf("the getstr is %s",getstr);
    NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];
    NSMutableArray *getarraystring = [self SplitString:getsumstring];
    return 0;
    //[self performSelectorOnMainThread:@selector(gotoreload) withObject:nil waitUntilDone:YES];
}
- (void) newfold:(NSString *)foldername foldername:(NSString *)name
{
    NSString *newfolder = @"usr=";
    newfolder = [newfolder stringByAppendingString:Userid];
    newfolder = [newfolder stringByAppendingString:@","];
    newfolder = [newfolder stringByAppendingString:@"root="];
    newfolder = [newfolder stringByAppendingString:foldername];
    newfolder = [newfolder stringByAppendingString:@","];
    
    newfolder = [newfolder stringByAppendingString:@"priv="];
    newfolder = [newfolder stringByAppendingString:[NSString stringWithFormat:@"%d",ispriv]];
    newfolder = [newfolder stringByAppendingString:@","];
    
    newfolder = [newfolder stringByAppendingString:@"name="];
    newfolder = [newfolder stringByAppendingString:@"\""];
    newfolder = [newfolder stringByAppendingString:name];
    newfolder = [newfolder stringByAppendingString:@"\\"];

    newfolder = [newfolder stringByAppendingString:@"\""];


    
    
    //NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"ios测试\\ios测试1\"";
    int num1 = [newfolder length];
    NSLog(@"the num is %d",num1);
    unichar *Cmdchar1 = (unichar *)malloc(num1*sizeof(unichar));
    
    for(int i = 0 ; i < num1 ; i++)
    {
        *Cmdchar1 = [newfolder characterAtIndex:i];
        //printf("the cmdchar is %d \n",*Cmdchar1);
        //Cmdchar++;
        Cmdchar1++;
    }
    
    //printf("the reader length is %d",[reader length]);
    unsigned char *senddata =malloc(4);
    senddata[0]=25;
    senddata[1]=100;
    senddata[2]=200;
    senddata[3]=300;
    int length1 = 2*[newfolder length]+10;
    printf("the uploadstr is %d",length1);
    //length1+= [reader length];
    //Sendcmdupload(length1,Cmdchar1-num1);
    Sendcmd(length1,Cmdchar1-num1,newfoldcmd,gethostname,[vdsp intValue]);
//    16.07.18
//    int numread3 = readgetstrlength(11);
    
    //NSLog(@"the dir is %@",documentDir);
}
- (void) deletefile
{
    //NSString *cmddelete = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990486.MOV\"";
    NSString *cmddelete = @"usr=";
    cmddelete = [cmddelete stringByAppendingString:Userid];
    cmddelete = [cmddelete stringByAppendingString:@","];
    cmddelete = [cmddelete stringByAppendingString:@"root="];
    NSLog(@"the foldername is %@",@"11\\手机文件");
    cmddelete = [cmddelete stringByAppendingString:sendfilename];
    cmddelete = [cmddelete stringByAppendingString:@","];
    
    cmddelete = [cmddelete stringByAppendingString:@"priv="];
    cmddelete = [cmddelete stringByAppendingString:@"1"];
    cmddelete = [cmddelete stringByAppendingString:@","];
    
    cmddelete = [cmddelete stringByAppendingString:@"name="];
    cmddelete = [cmddelete stringByAppendingString:@"\""];
    cmddelete = [cmddelete stringByAppendingString:tmp];
    cmddelete = [cmddelete stringByAppendingString:@"\\"];

    cmddelete = [cmddelete stringByAppendingString:delfilename];

    cmddelete = [cmddelete stringByAppendingString:@"\""];
    NSLog(@"the string is %@",cmddelete);
    //NSString *me = @"by";
    int numdelete = [cmddelete length];
    NSLog(@"the num is %d",numdelete);
    unichar *Cmdchardelete = (unichar *)malloc(numdelete*sizeof(unichar));
    int j=0;
    for(j = 0 ; j < numdelete ; j++)
    {
        *Cmdchardelete = [cmddelete characterAtIndex:j];
        printf("the cmdchar is %d \n",*Cmdchardelete);
        //Cmdchar++;
        Cmdchardelete++;
    }
    int lengthdelete = 2*[cmddelete length]+10;
    Sendcmd(lengthdelete,Cmdchardelete-numdelete,1,gethostname,[vdsp intValue]);
//    16.07.18
//    int numread3 = readgetstrlength(11);
    [self performSelectorOnMainThread:@selector(deletefinish) withObject:nil waitUntilDone:YES];
    //[self listfile];
}
- (void) deletefinish
{
    [self listfile];
}
//- (void) down
- (void) uploadfile
{
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"the uploadfile is %@",uploadfilename);
    NSString *documentDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
    NSString *documentDir = [documentDirectory stringByAppendingPathComponent:uploadfilename];
    long long int filelength = [self getfilelength:documentDir];
    NSString *strfilelength = [NSString stringWithFormat:@"%lld",filelength];
    //NSLog(@"the uploadfile is %@",uploadfilename);
    //NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990486.MOV\",size=38538403";
    NSString *Uploadstr = @"usr=";
    Uploadstr = [Uploadstr stringByAppendingString:Userid];
    Uploadstr = [Uploadstr stringByAppendingString:@","];
    Uploadstr = [Uploadstr stringByAppendingString:@"root="];
    NSLog(@"the foldername is %@",@"11\\手机文件");
    Uploadstr = [Uploadstr stringByAppendingString:privfoldername];
    Uploadstr = [Uploadstr stringByAppendingString:@","];
    
    Uploadstr = [Uploadstr stringByAppendingString:@"priv="];
    Uploadstr = [Uploadstr stringByAppendingString:@"1"];
    Uploadstr = [Uploadstr stringByAppendingString:@","];
    
    Uploadstr = [Uploadstr stringByAppendingString:@"name="];
    Uploadstr = [Uploadstr stringByAppendingString:@"\""];
    Uploadstr = [Uploadstr stringByAppendingString:@"手机文件\\"];
    Uploadstr = [Uploadstr stringByAppendingString:uploadfilename];
    Uploadstr = [Uploadstr stringByAppendingString:@"\""];
    Uploadstr = [Uploadstr stringByAppendingString:@","];
    
    Uploadstr = [Uploadstr stringByAppendingString:@"size="];
    Uploadstr = [Uploadstr stringByAppendingString:strfilelength];
    Uploadstr = [Uploadstr stringByAppendingString:@","];
    
    //NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"ios测试\\ios测试1\"";
    int num1 = [Uploadstr length];
    NSLog(@"the num is %d",num1);
    unichar *Cmdchar1 = (unichar *)malloc(num1*sizeof(unichar));
    
    for(int i = 0 ; i < num1 ; i++)
    {
        *Cmdchar1 = [Uploadstr characterAtIndex:i];
        //printf("the cmdchar is %d \n",*Cmdchar1);
        //Cmdchar++;
        Cmdchar1++;
    }
    
    //printf("the reader length is %d",[reader length]);
    unsigned char *senddata =malloc(4);
    senddata[0]=25;
    senddata[1]=100;
    senddata[2]=200;
    senddata[3]=300;
    int length1 = 2*[Uploadstr length]+10;
    printf("the uploadstr is %d",length1);
    //length1+= [reader length];
    //Sendcmdupload(length1,Cmdchar1-num1);
    Sendcmd(length1,Cmdchar1-num1,upload,gethostname,[vdsp intValue]);
    NSLog(@"the dir is %@",documentDir);
    //NSData* reader = [NSData dataWithContentsOfFile:documentDir1];
    //NSData* reader ;//= [[NSData alloc] initWithContentsOfFile:documentDir1];
    //getreader = (unsigned char *)[reader bytes];
    //int filelength = [reader length];
    //NSLog(@"the length is %d",filelength);
    int partnum = 38538403/4096;
    unsigned long long fileoffset = 0;
    downloaddatanum = filelength;
    labloaded.hidden = NO;
    labsum.hidden = NO;
    //readHandle = [NSFileHandle fileHandleForReadingAtPath:documentDir1];
    //for(int i=0;i<=partnum;i++)
        while(endpacketnum == 4096)
        {
            //[readHandle release];
            getreader = malloc(4096);
            endpacketnum = [self readfiledata:documentDir offset:fileoffset length:4096];
            writefile(endpacketnum,getreader);
            
            fileoffset+=4096;
            //printf("the endpacketnum is %d",endpacketnum);
            free(getreader);
            downloadednum+=4;
            [self performSelectorOnMainThread:@selector(updatejindu) withObject:nil waitUntilDone:YES];
            
            
        }
    endpacketnum = 4096;
    readcommand(11);
    labloaded.hidden = YES;
    labsum.hidden = YES;
    progress.hidden = YES;
    filebuttonupload.hidden = YES;
    //Foldertype =1;
    downloadednum = 0;
        [self performSelectorOnMainThread:@selector(Uploadfinish) withObject:nil waitUntilDone:YES];

    
    //[self listmobilefile];
}
- (void)UploadMultiplephoto:(id)imagearray
{
    NSArray *mediaInfoArray = imagearray;
    for(int i=0;i<mediaInfoArray.count;i++)
    {
        NSDictionary *mediaInfo  = [mediaInfoArray objectAtIndex:i];
        NSLog(@"Selected: %@", mediaInfo);
        UIImage *image = [mediaInfo objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSURL *refURL = [mediaInfo valueForKey:UIImagePickerControllerReferenceURL];
        NSString *URL=[refURL absoluteString];
        NSRange getrange = [URL rangeOfString:@"id="];
        NSRange getextrange = [URL rangeOfString:@"&ext="];
        NSLog(@"the url is %@",URL);
        NSLog(@"the location is %d",getrange.location);
        NSLog(@"the location is %d",getextrange.location);
        NSLog(@"the url string is %@",[URL substringWithRange:NSMakeRange(getrange.location+3,getrange.location+3)]);
        // PhotoFilename =[[NSString alloc] initWithString:[URL substringWithRange:NSMakeRange(getrange.location,getextrange.location)]];
        //PhotoFilename =[[NSString alloc] initWithString:[URL substringWithRange:NSMakeRange(33,50)]];
        // NSLog(@"the PhotoFilename is %@",PhotoFilename);
        NSLog(@"the location is %d",getrange.location);
        NSLog(@"the url is %@",URL);
        PhotoFilename =[URL substringWithRange:NSMakeRange(getrange.location+3,getrange.location+3)];
        NSLog(@"the filename is %@",PhotoFilename);
        //NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        int mydata = [imageData length];
        NSLog(@"the mydata is %d",mydata);
        
        unsigned char *testByte = (unsigned char *)[imageData bytes];
        //UIImage *compressedImage = [UIImage imageWithData:imageData];
        //把自定义的view设置到imagepickercontroller的overlay属性中
        //[picker.view addSubview:tool];// = tool;
        if([self Uploadphotodata:testByte length:mydata]==-1)
        {
                [self performSelectorOnMainThread:@selector(photofail) withObject:nil waitUntilDone:YES];
            return;
        }
        //[PhotoFilename release];
        // define the block to call when we get the asset based on the url (below)
        /*ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
         {
         ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
         PhotoFilename =[[NSString alloc] initWithString:[imageRep filename]];
         NSLog(@"the filename is %@",PhotoFilename);
         //NSLog(@"[imageRep filename] : %@", [imageRep filename]);
         NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
         int mydata = [imageData length];
         NSLog(@"the mydata is %d",mydata);
         
         unsigned char *testByte = (unsigned char *)[imageData bytes];
         //UIImage *compressedImage = [UIImage imageWithData:imageData];
         //把自定义的view设置到imagepickercontroller的overlay属性中
         //[picker.view addSubview:tool];// = tool;
         [self Uploadphotodata:testByte length:mydata];
         [PhotoFilename release];
         };
         ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
         [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];*/
        //UIImage *image = [mediaInfo UIImagePickerControllerOriginalImage];
        // UIImageJPEGRepresentation(image, 1.0);
        //userImageView.image = image;
        
        
        
    }
    [self performSelectorOnMainThread:@selector(photofinish) withObject:nil waitUntilDone:YES];
}
- (void)Uploadphoto:(id)getimage
{
NSDate *Date = [NSDate date];
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];

[formatter setDateFormat:@"yyyyMMddhhmmss"];
PhotoFilename = [NSString stringWithFormat:@"%@", [formatter stringFromDate:Date]];
//PhotoFilename =[[NSString alloc] initWithString:@"currentimage.jpg"];
NSLog(@"the filename is %@",PhotoFilename);
//NSLog(@"[imageRep filename] : %@", [imageRep filename]);
    UIImage *image = getimage;
NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

int mydata = [imageData length];
NSLog(@"the mydata is %d",mydata);

unsigned char *testByte = (unsigned char *)[imageData bytes];
if([self Uploadphotodata:testByte length:mydata]==-1)
{
        [self performSelectorOnMainThread:@selector(photofail) withObject:nil waitUntilDone:YES];
    return;
}
    [self performSelectorOnMainThread:@selector(photofinish) withObject:nil waitUntilDone:YES];
}
- (void) photofail
{
   [UploadView removeFromSuperview];
    PGToast *toast = [PGToast makeToast:@"连接服务器失败"];
    [toast show];
}
- (void) photofinish
{
    EscTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired1) userInfo:nil repeats:NO];

}
- (int) Uploadphotodata:(unsigned char *)data length:(int)num
//- (void) Uploadphotodata:(id)getdata (id):getnum

{

    
        NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"the uploadfile is %@",uploadfilename);
        NSString *documentDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
        NSString *documentDir = [documentDirectory stringByAppendingPathComponent:uploadfilename];
        long long int filelength = num;
        NSString *strfilelength = [NSString stringWithFormat:@"%lld",filelength];
        //NSLog(@"the uploadfile is %@",uploadfilename);
        //NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990486.MOV\",size=38538403";
        NSLog(@"the file name is %@",PhotoFilename);
        NSString *Uploadstr = @"usr=";
        Uploadstr = [Uploadstr stringByAppendingString:Userid];
        Uploadstr = [Uploadstr stringByAppendingString:@","];
        Uploadstr = [Uploadstr stringByAppendingString:@"root="];
        Uploadstr = [Uploadstr stringByAppendingString:privfoldername];
        Uploadstr = [Uploadstr stringByAppendingString:@","];
        
        Uploadstr = [Uploadstr stringByAppendingString:@"priv="];
        Uploadstr = [Uploadstr stringByAppendingString:@"1"];
        Uploadstr = [Uploadstr stringByAppendingString:@","];
        
        Uploadstr = [Uploadstr stringByAppendingString:@"name="];
        Uploadstr = [Uploadstr stringByAppendingString:@"\""];
        Uploadstr = [Uploadstr stringByAppendingString:@"手机相册\\"];
    Uploadstr = [Uploadstr stringByAppendingString:PhotoFilename];
    Uploadstr = [Uploadstr stringByAppendingString:@".jpg"];

        Uploadstr = [Uploadstr stringByAppendingString:@"\""];
        Uploadstr = [Uploadstr stringByAppendingString:@","];
        
        Uploadstr = [Uploadstr stringByAppendingString:@"size="];
        Uploadstr = [Uploadstr stringByAppendingString:strfilelength];
        Uploadstr = [Uploadstr stringByAppendingString:@","];
        
        //NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"ios测试\\ios测试1\"";
        int num1 = [Uploadstr length];
        NSLog(@"the num is %d",num1);
        unichar *Cmdchar1 = (unichar *)malloc(num1*sizeof(unichar));
        
        for(int i = 0 ; i < num1 ; i++)
        {
            *Cmdchar1 = [Uploadstr characterAtIndex:i];
            //printf("the cmdchar is %d \n",*Cmdchar1);
            //Cmdchar++;
            Cmdchar1++;
        }
        
        //printf("the reader length is %d",[reader length]);
        unsigned char *senddata =malloc(4);
        senddata[0]=25;
        senddata[1]=100;
        senddata[2]=200;
        senddata[3]=300;
        int length1 = 2*[Uploadstr length]+10;
        printf("the uploadstr is %d",length1);
        //length1+= [reader length];
        //Sendcmdupload(length1,Cmdchar1-num1);
        if(Sendcmd(length1,Cmdchar1-num1,upload,gethostname,[vdsp intValue])==-1)
        {
            return -1;
        }
        NSLog(@"the dir is %@",documentDir);
        //NSData* reader = [NSData dataWithContentsOfFile:documentDir1];
        //NSData* reader ;//= [[NSData alloc] initWithContentsOfFile:documentDir1];
        //getreader = (unsigned char *)[reader bytes];
        //int filelength = [reader length];
        //NSLog(@"the length is %d",filelength);
        int partnum = 38538403/4096;
        unsigned long long fileoffset = 0;
        downloaddatanum = filelength;
        writefile(downloaddatanum,data);
        readcommand(11);
        return 0;

}
- (void) downloadfile
{
    //NSString *Downloadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990488.MOV\"";
    labloaded.hidden = NO;
    labsum.hidden = NO;
    NSString *Downloadstr = @"usr=";
    Downloadstr = [Downloadstr stringByAppendingString:Userid];
    Downloadstr = [Downloadstr stringByAppendingString:@","];
    Downloadstr = [Downloadstr stringByAppendingString:@"root="];
    Downloadstr = [Downloadstr stringByAppendingString:sendfilename];
    Downloadstr = [Downloadstr stringByAppendingString:@","];
    
    Downloadstr = [Downloadstr stringByAppendingString:@"priv="];
    Downloadstr = [Downloadstr stringByAppendingString:[NSString stringWithFormat:@"%d",ispriv]];
    Downloadstr = [Downloadstr stringByAppendingString:@","];
    
    Downloadstr = [Downloadstr stringByAppendingString:@"name="];
    Downloadstr = [Downloadstr stringByAppendingString:@"\""];
    Downloadstr = [Downloadstr stringByAppendingString:downloadpath];
    Downloadstr = [Downloadstr stringByAppendingString:@"\""];
    //NSString *Downloadstr = downloadpath;
    int num2 = [Downloadstr length];
    unichar *Cmdchar2 = (unichar *)malloc(num2*sizeof(unichar));
    
    for(int i = 0 ; i < num2 ; i++)
    {
        *Cmdchar2 = [Downloadstr characterAtIndex:i];
        printf("the cmdchar is %d \n",*Cmdchar2);
        //Cmdchar++;
        Cmdchar2++;
    }
    int length2 = 2*[Downloadstr length]+10;
    //NSLog(@"the num2 is %d",num2);
    //NSLog(@"the length2 is %d",length2);
    //Sendcmddownload(length2,Cmdchar2-num2);
    Sendcmd(length2,Cmdchar2-num2,download,gethostname,[vdsp intValue]);
    downloaddatanum = readcmddownloadlength();
    printf("the downloaddatanum is %lld",downloaddatanum);
    unsigned char *data;
    //int partnum = 38538403/4096;
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *documentDirectory = [Paths objectAtIndex:0];
    //NSArray *files = [fm subpathsAtPath: [self dataFilePath] ];
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    /*NSString *documentDirectory = [Paths objectAtIndex:0];
    int *numrecieve = malloc(sizeof(int));
    // DBNAME 是要查找的文件名字，文件全名
    long int sum = 0;
    NSString *documentDir = [documentDirectory stringByAppendingPathComponent:@"IMG3.MOV"];*/
    BOOL isDir = NO;
    NSString *documentDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
    BOOL existed = [fileManager fileExistsAtPath:documentDirectory isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    int *numrecieve = malloc(sizeof(int));
    // DBNAME 是要查找的文件名字，文件全名
    long long int sum = 0;
    NSString *documentDir = [documentDirectory stringByAppendingPathComponent:Downloadfilename];
    //NSArray  *arr = [fileManager  directoryContentsAtPath:documentDirectory];
    [fileManager createFileAtPath:documentDir contents:nil attributes:nil];
    
   /* NSString *imageDir = [NSString stringWithFormat:@"%@/Caches/%@", NSHomeDirectory(), dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }*/
   // NSLog(@"the partnum is %d",partnum);
    while(sum<downloaddatanum)
    {
        //[NSThread detachNewThreadSelector:@selector(receivedata) toTarget:self withObject:nil];
        data = readcmd(4096,numrecieve);
        //printf("the numreceive is %d",*numrecieve);
        //NSData *getreaddata = [NSData dataWithBytes:data length:*numrecieve ];
        getreaddata = [[NSData alloc] initWithBytes:data length:*numrecieve];
        [self writefiledata:documentDir writedata:getreaddata];
        free(data);
        if(getreaddata!=NULL)
        {
            [getreaddata release];
        }
        sum +=*numrecieve;
                    //[_lbl_connecting setText:NSLocalizedString(@"logon", @"logon progress view - label")]
        //sum/409600
        [self performSelectorOnMainThread:@selector(updatejindu) withObject:nil waitUntilDone:YES];
        downloadednum+=4;
        //[self UpdateProgress];
    }
    root = 1;
    //Foldertype = 1;
    //tmp = [[NSMutableString alloc] initWithString:@""];
    labloaded.hidden = YES;
    labsum.hidden = YES;
    progress.hidden = YES;
    filebutton.hidden = YES;
    downloadednum = 0;
    //[self performSelectorOnMainThread:@selector(folderback) withObject:nil waitUntilDone:YES];    //[filebutton release];
    //[self performSelectorOnMainThread:@selector(gotoreload) withObject:nil waitUntilDone:YES];
    //[NSThread exit];
    //Foldertype =1;
    //[self listmobilefile];
    //[self performSelectorOnMainThread:@selector(updatejindu) withObject:nil waitUntilDone:YES];
    //[self performSelectorOnMainThread:@selector(listmobilefile) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(Downloadfinish) withObject:nil waitUntilDone:YES];
}


- (void) receivedata
{
    /*unsigned char *data;
    numrecieve = malloc(sizeof(int));
    data = readcmd(4096,numrecieve);
    //printf("the numreceive is %d",*numrecieve);
    //NSData *getreaddata = [NSData dataWithBytes:data length:*numrecieve ];
    getreaddata = [[NSData alloc] initWithBytes:data length:*numrecieve];
    [self writefiledata:documentDir writedata:getreaddata];
    free(data);
    if(getreaddata!=NULL)
    {
        [getreaddata release];
    }*/
    /*NSString *documentDirectory = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"Realor"];
    //int *numrecieve = malloc(sizeof(int));
    // DBNAME 是要查找的文件名字，文件全名
    long int sum = 0;
    NSString *documentDir = [documentDirectory stringByAppendingPathComponent:Downloadfilename];
    packetdata = readcmd(4096,numrecieve);
    [self writefiledata:documentDir writedata:getreaddata];
    free(packetdata);
    if(getreaddata!=NULL)
    {
        [getreaddata release];
    }*/
}
- (int) readfiledata: (NSString*)name offset:(unsigned long long) offset length:(int)length
{/*
  readHandle = [NSFileHandle fileHandleForReadingAtPath:filename];
  [readHandle seekToFileOffset:offset];
  //NSData *readdata = ;
  [
  return [readHandle readDataOfLength:length];*/
    //NSString* imgFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"bundle" inDirectory: dir ];
    FILE *imgFileHandle =NULL;
    //unsigned char *buff = malloc(length);
    imgFileHandle =fopen([name UTF8String],"rb");
    if (imgFileHandle != NULL)
        
    {   //long long length=ftell(imgFileHandle);
        //long idxPos = 20;
        fseek(imgFileHandle, 0L, SEEK_END);
        long long int flen = ftell(imgFileHandle);
        printf("the length is %lld",flen);
        
        fseek(imgFileHandle, 0L, 0);
        fseek(imgFileHandle, offset, 0);
        //char * buff[length];
        if((flen-offset)<4096)
        {
            length = flen-offset;
        }
        else
        {
            length = 4096;
        }
        memset(getreader,0,length);
        fread(getreader, 1, length, imgFileHandle);
        fclose(imgFileHandle);
    }
    return length;
}


- (void) writefiledata : (NSString*) name writedata:(NSData *)data
{
    NSFileHandle  *outFile;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    /*NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentDirectory = [Paths objectAtIndex:0];
     
     // DBNAME 是要查找的文件名字，文件全名
     
     NSString *MessagePath = [documentDirectory stringByAppendingPathComponent:filename];
     // NSString *NewMessagePath = [documentDirectory stringByAppendingPathComponent:@"NewMessage.xml"];*/
    if(![fileManager fileExistsAtPath:name])
    {
        [fileManager createFileAtPath:name contents:nil attributes:nil];
        [data writeToFile:name atomically:YES];
    }
    else
    {
        outFile = [NSFileHandle fileHandleForWritingAtPath:name];
        if(outFile == nil)
        {
            NSLog(@"Open of file for writing failed");
        }
        
        //找到并定位到outFile的末尾位置(在此后追加文件)
        [outFile seekToEndOfFile];
        [outFile writeData:data];
        
        //关闭读写文件
        [outFile closeFile];
        //[outFile release];
        [fileManager release];
    }
    
    
}
- (long long int)getfilelength: (NSString*)name
{
    FILE *imgFileHandle =NULL;
    long long int flen = 0;
    //unsigned char *buff = malloc(length);
    imgFileHandle =fopen([name UTF8String],"rb");
    if (imgFileHandle != NULL)
        
    {   //long long length=ftell(imgFileHandle);
        //long idxPos = 20;
        fseek(imgFileHandle, 0L, SEEK_END);
        flen = ftell(imgFileHandle);
        printf("the length is %lld",flen);
        
        fseek(imgFileHandle, 0L, 0);
        return flen;
    }
    return flen;
}
- (void) gotoreload
{
    [[self tableView] reloadData];
        NSString *title = @"服务器文件";
    if([tmp length]==0)
    {

    title = [title stringByAppendingString:@"\\"];
    title = [title stringByAppendingString:sendfilename];
    self.navigationItem.title = title;
    }
    else
    {
    //NSString *title = sendfilename;
        
    title = [title stringByAppendingString:@"\\"];
    title = [title stringByAppendingString:sendfilename];
    title = [title stringByAppendingString:@"\\"];
    title = [title stringByAppendingString:tmp];
    self.navigationItem.title = title;
    //[self.navigationController setTitle:tmp];
    }
}
- (NSMutableArray *)SplitString:(NSString*)getstr
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"n"];
    NSString *str = [getstr stringByTrimmingCharactersInSet:set];
    getstr = [getstr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"the get str is %@",getstr);
    NSArray  * arrayfile= [getstr componentsSeparatedByString:@"\n"];
    NSLog(@"the splitstring is %@",[arrayfile objectAtIndex:0]);
    arraydecription = [[NSMutableArray alloc]init];
    //[NSMutableArray A]
    for(int i=0;i<[arrayfile count]-1;i++)
    {
        NSArray *decription = [[arrayfile objectAtIndex:i] componentsSeparatedByString:@","];
        ListDic = [NSMutableDictionary dictionary];
        for(int j=0;j<[decription count];j++)
        {
            NSArray *dicdata = [[decription objectAtIndex:j] componentsSeparatedByString:@"="];
            //NSLog(()
            [ListDic setObject:[dicdata objectAtIndex:1] forKey:[dicdata objectAtIndex:0]];
            //NSLog(@"dictionary:%@",ListDic);
            //[dicdata release];
        }
        //NSLog(@"dictionary1:%@",ListDic);
        [arraydecription addObject:ListDic];
        NSString *name = [[arraydecription objectAtIndex:0] objectForKey:@"name"];
        NSLog(@"the name is %@",name);
        
        //[ListDic release];
        //NSLog(@"the string arraydecription is %@",[arraydecription objectAtIndex:i]);
    }//[array count];
   // NSLog(@"the name is %@",[[arraydecription objectAtIndex:0] objectForKey:@"name"]);
    //NSLog(@"the decription is %@",[[arraydecription objectAtIndex:0] objectAtIndex:0]);
    //NSLog(@"the decription is %@",[[arraydecription objectAtIndex:0] objectAtIndex:1]);
    //NSLog(@"the decription is %@",[[arraydecription objectAtIndex:6] objectAtIndex:0]);
    // NSLog(@"the decription is %@",[[arraydecription objectAtIndex:6] objectAtIndex:1]);
    return arraydecription;
    //NSLog(@"the splitstring is %@",array[0]);
}
/*
VirtualTcpConnect("192.168.2.108", 5890);
NSString *cmddelete = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990486.MOV\"";
NSLog(@"the string is %@",cmddelete);
//NSString *me = @"by";
int numdelete = [cmddelete length];
NSLog(@"the num is %d",numdelete);
unichar *Cmdchardelete = (unichar *)malloc(numdelete*sizeof(unichar));
int j=0;
for(j = 0 ; j < numdelete ; j++)
{
    *Cmdchardelete = [cmddelete characterAtIndex:j];
    printf("the cmdchar is %d \n",*Cmdchardelete);
    //Cmdchar++;
    Cmdchardelete++;
}
int lengthdelete = 2*[cmddelete length]+10;
Sendcmd(lengthdelete,Cmdchardelete-numdelete,1);
int numread3 = readgetstrlength(11);
VirtualTcpConnect("192.168.2.108", 5890);
NSString *Virtualcmd = @"usr=usr00000001,root=11,priv=1,name=\"\"";
NSLog(@"the string is %@",Virtualcmd);
//NSString *me = @"by";
int num = [Virtualcmd length];
NSLog(@"the num is %d",num);
unichar *Cmdchar = (unichar *)malloc(num*sizeof(unichar));
int i=0;
for(i = 0 ; i < num ; i++)
{
    *Cmdchar = [Virtualcmd characterAtIndex:i];
    printf("the cmdchar is %d \n",*Cmdchar);
    //Cmdchar++;
    Cmdchar++;
}
int length = 2*[Virtualcmd length]+10;
Sendcmd(length,Cmdchar-num,list);
int numread = readgetstrlength(10);
NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
unsigned short * unistr = readcmdstr(numread);
//char * getstr = malloc(50);
char *getstr = unicode_to_utf8(unistr,numread-10);
printf("the getstr is %s",getstr);
NSString *encrypted = [[NSString alloc] initWithCString:(const char*)getstr encoding:NSUTF8StringEncoding];
NSMutableArray *getarraystring = [self SplitString:encrypted];

//[getarraystring o]
//for (int i)
NSLog(@"the backstr is %@",encrypted);
VirtualTcpConnect("192.168.2.108", 5890);
NSString *documentDir1 = [[NSBundle mainBundle] pathForResource:@"IMG_0283_9990484" ofType:@"MOV"];
long long int filelength = [self getfilelength:documentDir1];
NSString *strfilelength = [NSString stringWithFormat:@"%lld",filelength];
//NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990486.MOV\",size=38538403";
NSString *Uploadstr = @"usr=";
Uploadstr = [Uploadstr stringByAppendingString:@"usr00000001"];
Uploadstr = [Uploadstr stringByAppendingString:@","];
Uploadstr = [Uploadstr stringByAppendingString:@"root="];
Uploadstr = [Uploadstr stringByAppendingString:@"11"];
Uploadstr = [Uploadstr stringByAppendingString:@","];

Uploadstr = [Uploadstr stringByAppendingString:@"priv="];
Uploadstr = [Uploadstr stringByAppendingString:@"1"];
Uploadstr = [Uploadstr stringByAppendingString:@","];

Uploadstr = [Uploadstr stringByAppendingString:@"name="];
Uploadstr = [Uploadstr stringByAppendingString:@"\""];
Uploadstr = [Uploadstr stringByAppendingString:@"IMG_0283_9990486.MOV"];
Uploadstr = [Uploadstr stringByAppendingString:@"\""];
Uploadstr = [Uploadstr stringByAppendingString:@","];

Uploadstr = [Uploadstr stringByAppendingString:@"size="];
Uploadstr = [Uploadstr stringByAppendingString:strfilelength];
Uploadstr = [Uploadstr stringByAppendingString:@","];

//NSString *Uploadstr = @"usr=usr00000001,root=11,priv=1,name=\"ios测试\\ios测试1\"";
int num1 = [Uploadstr length];
NSLog(@"the num is %d",num1);
unichar *Cmdchar1 = (unichar *)malloc(num1*sizeof(unichar));

for(int i = 0 ; i < num1 ; i++)
{
    *Cmdchar1 = [Uploadstr characterAtIndex:i];
    //printf("the cmdchar is %d \n",*Cmdchar1);
    //Cmdchar++;
    Cmdchar1++;
}

//printf("the reader length is %d",[reader length]);
unsigned char *senddata =malloc(4);
senddata[0]=25;
senddata[1]=100;
senddata[2]=200;
senddata[3]=300;
int length1 = 2*[Uploadstr length]+10;
printf("the uploadstr is %d",length1);
//length1+= [reader length];
//Sendcmdupload(length1,Cmdchar1-num1);
Sendcmd(length1,Cmdchar1-num1,upload);
NSLog(@"the dir is %@",documentDir1);
//NSData* reader = [NSData dataWithContentsOfFile:documentDir1];
//NSData* reader ;//= [[NSData alloc] initWithContentsOfFile:documentDir1];
//getreader = (unsigned char *)[reader bytes];
//int filelength = [reader length];
//NSLog(@"the length is %d",filelength);
int partnum = 38538403/4096;
unsigned long long fileoffset = 0;
//readHandle = [NSFileHandle fileHandleForReadingAtPath:documentDir1];
for(int i=0;i<=partnum;i++)
while(endpacketnum == 4096)
{
    //[readHandle release];
    getreader = malloc(4096);
    endpacketnum = [self readfiledata:documentDir1 offset:fileoffset length:4096];
    writefile(endpacketnum,getreader);
    
    fileoffset+=4096;
    printf("the endpacketnum is %d",endpacketnum);
    free(getreader);
    
}
readcommand(11);
VirtualTcpConnect("192.168.2.108", 5890);
NSString *Downloadstr = @"usr=usr00000001,root=11,priv=1,name=\"IMG_0283_9990486.MOV\"";
int num2 = [Downloadstr length];
unichar *Cmdchar2 = (unichar *)malloc(num2*sizeof(unichar));

for(int i = 0 ; i < num2 ; i++)
{
    *Cmdchar2 = [Downloadstr characterAtIndex:i];
    printf("the cmdchar is %d \n",*Cmdchar2);
    //Cmdchar++;
    Cmdchar2++;
}
int length2 = 2*[Downloadstr length]+10;
//NSLog(@"the num2 is %d",num2);
//NSLog(@"the length2 is %d",length2);
//Sendcmddownload(length2,Cmdchar2-num2);
Sendcmd(length2,Cmdchar2-num2,download);
readcmdhead(18);
unsigned char *data;
//int partnum = 38538403/4096;
NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentDirectory = [Paths objectAtIndex:0];
int *numrecieve = malloc(sizeof(int));
// DBNAME 是要查找的文件名字，文件全名
long int sum = 0;
NSString *documentDir = [documentDirectory stringByAppendingPathComponent:@"IMG3.MOV"];
[fileManager createFileAtPath:documentDir contents:nil attributes:nil];

NSLog(@"the partnum is %d",partnum);
while(sum<38538403)
{
    data = readcmd(4096,numrecieve);
    
    //NSData *getreaddata = [NSData dataWithBytes:data length:*numrecieve ];
    getreaddata = [[NSData alloc] initWithBytes:data length:*numrecieve];
    [self writefiledata:documentDir writedata:getreaddata];
    free(data);
    if(getreaddata!=NULL)
    {
        [getreaddata release];
    }
    sum +=*numrecieve;
    
}*/
/*
 // Override to support conditional editing of the table view.
 */
-(UIView *)findView:(UIView *)aView withName:(NSString *)name{
    Class cl = [aView class];
    NSString *desc = [cl description];
    NSLog(@"the desc is %@",desc);
    if ([name isEqualToString:desc])
        return aView;
    
    for (NSUInteger i = 0; i < [aView.subviews count]; i++)
    {
        UIView *subView = [aView.subviews objectAtIndex:i];
        subView = [self findView:subView withName:name];
        if (subView)
            return subView;
    }
    return nil;
}
-(void)addSomeElements:(UIViewController *)viewController{
    
    
    UIView *PLCameraView=[self findView:viewController.view withName:@"PLCropOverlay"];
   // PLCameraView.hidden = YES;
    UploadView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,PLCameraView.frame.size.width,PLCameraView.frame.size.height)]autorelease];
    UploadView.backgroundColor = [UIColor darkGrayColor];
    UploadView.alpha=0.5;
    UIButton *mybutton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    [mybutton setBackgroundColor:[UIColor redColor]];
    [mybutton setTitle:@"上传" forState:0];
    [UploadView addSubview:mybutton];
    [PLCameraView addSubview:UploadView];
    UploadView.hidden = YES;
    UIView *bottomBar=[self findView:PLCameraView withName:@"PLCropOverlayBottomBar"];
    
    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:0];
    //UIButton *retakeButton=[bottomBarImageForSave.subviews objectAtIndex:0];
    //[retakeButton setTitle:@"wo" forState:UIControlStateNormal];  //左下角按钮
    UIButton *useButton=[bottomBarImageForSave.subviews objectAtIndex:1];
    [useButton setTitle:@"上传" forState:UIControlStateNormal];  //右下角按钮
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    [self addSomeElements:viewController];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    NSLog(@"the toolbar num is %d",[[navigationController toolbarItems] count]);
    
    NSLog(@"the editbutton title is %@",[[[[viewController navigationItem] rightBarButtonItems] objectAtIndex:0] title]);
}
/*-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //int picturenum = [[picker.cameraOverlayView subviews] count];
    NSLog(@"the picturenum is %@",info);
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    //NSLog(@"the toolbar num is %d",[[picker toolbarItems] count]);
}*/


@end
