#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface MRootListController : PSListController
@end

@interface MCustomHeaderCell : UIView
@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,assign) UILabel *headerLabel;
@property (nonatomic,assign) UILabel *subHeaderLabel;
@property (nonatomic,readonly) NSArray *randomQuotes;
@end
