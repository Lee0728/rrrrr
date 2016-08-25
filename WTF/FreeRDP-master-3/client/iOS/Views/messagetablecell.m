//
//  messagetablecell.m
//  FreeRDP
//
//  Created by 吴 永华 on 14-3-13.
//
//

#import "messagetablecell.h"


@implementation messagetablecell
//@synthesize mytitle = _mytitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    
    //[label setNumberOfLines:n]
    //[_mycontent setNumberOfLines:5];
    [_mycontent setFrame:CGRectMake(179, 20, 50, 100)];
    _mycontent.numberOfLines = 0;
//    [self.V]
    return self;
}
//- (id)initwithFrame:

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (UILabel *)getlabeltitle
{
    return _mytitle;
}

- (UILabel *)getlabelcontent
{
    return _mycontent;
}
- (void)dealloc {
    [super dealloc];
}

@end
