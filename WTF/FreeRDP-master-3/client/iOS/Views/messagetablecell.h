//
//  messagetablecell.h
//  FreeRDP
//
//  Created by 吴 永华 on 14-3-13.
//
//

#import <UIKit/UIKit.h>

@interface messagetablecell : UITableViewCell
{
	IBOutlet UILabel* _mytitle;
    IBOutlet UILabel* _mycontent;
    UILabel *title;
}
- (UILabel *)getlabeltitle;
- (UILabel *)getlabelcontent;
@end