//
//  FileViewController.h
//  FreeRDP
//
//  Created by 吴 永华 on 14-4-16.
//
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "tcp.h"
#import "packect.h"
#import "QBImagePickerController.h"
#import "PGToast.h"
#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7
@interface FileViewController : UITableViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBImagePickerControllerDelegate>{
UITableViewCell *FileCell;
    NSMutableDictionary *Celldic;
    NSMutableDictionary *Celldic1;
    NSMutableDictionary *Celldic2;
    id delegate;
    //UIImagePickerController *picker;
    UILabel *labloaded;
    UILabel *labsum;
    UIProgressView *progress;
    NSString *filename;
    UIImage *fileimage;
    UIButton *filebutton;
    UIButton *camerabutton;
    UIButton *filebuttonupload;
    NSMutableArray *Cellarray;
    NSFileHandle *readHandle;
    unsigned char *getreader;
    NSData *readdata;
    NSData *getreaddata;
    int endpacketnum;
    unsigned char *packetdata;
    NSIndexPath * selectindex;
    float loadednum;
    UIView *statuView;
    NSMutableDictionary *ListDic;
    NSMutableArray *arraydecription;
    FileViewController *fileViewController;
    UIView *UploadView;
    QBImagePickerController *imagePickerController;
    //int *numrecieve;
    //NSString *getfilename;
    NSString *getfilename;
    NSMutableString* tmp;
    NSString *delfilename;
    NSString *getname;
    int Foldertype;
    NSArray *mobilefiles;
    NSArray *mobilefiles1;
    NSMutableArray *buttonarray;
    int root;
    BOOL progressflag;
    NSString *uploadfilename;
    NSMutableString *downloadpath;
    NSString *Downloadfilename;
    BOOL openmobileflag;
    float sum;
    float downloadednum;
    long long int downloaddatanum;
    NSString *PhotoFilename;

    //UIImagePickerController *picker;
    UIImagePickerController* pickercontroller;
    NSString *vd;
    NSString *Userid;
    NSString *vdsp;
    int ispriv;
    int serverroot;
    int folderoot;
    NSString *rootfilename;
    NSMutableArray *sharefolder;
    NSMutableArray *privatefolder;
    NSString *sendfilename;
    int rootflag;
    NSString *privfoldername;
    NSString *auth1;
    int camera;
    char *gethostname;
    NSString *tmptmp;
    NSTimer *EscTimer;
    int selectrow;
    NSString *FileFullPath;
    //int endpacketnum;

}
@property (nonatomic, retain) IBOutlet UITableViewCell *FileCell;
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) UIImage *fileimage;
@property(nonatomic, copy) UIButton *filebutton;
@property(nonatomic, copy) UIButton *camerabutton;

- (void) localphoto;
- (int) Uploadphotodata:(unsigned char *)data length:(int)num;
- (void)setvirtualinfo:(NSString *)Vdvd Userid:(NSString *)Vdusrid vdsp:(NSString *)Vdvdsp;
-(void)takePhoto:(id) sender;
- (void) newfold :(NSString *)foldername foldername:(NSString *)name;
-(void) getroot;
- (void)setDelegate:(id)object;
- (id)delegate;
- (void) newfold:(NSString *)foldername foldername:(NSString *)name;
- (void) gethost:(char *)host;
-(int) listrootfile;
- (void)timerFired1;
- (void)Uploadphoto:(id)getimage;
- (void) photofail;
@end

@protocol FileViewControllerDelegate
- (void) rootfileerror;
- (void) toolbarshow;
- (void) extboardshow;
@end