#include "MeteoroidRootListController.h"
#include <spawn.h>

#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;
@end

@interface MeteoroidTitleCell : PSTableCell <PreferencesTableCustomView> {
    UIView *bgView;
    UILabel *packageNameLabel;
    UILabel *developerLabel;
    UILabel *versionLabel;
}
@end

@implementation MeteoroidTitleCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		int width = self.contentView.bounds.size.width;

    // CGRect frame = CGRectMake(0, 0, width, 215);
    CGRect nameFrame = CGRectMake(20, 90, width, 60);
    CGRect developerFrame = CGRectMake(22, 50, width, 50);
    CGRect versionFrame = CGRectMake(22, 130, width, 50);

    packageNameLabel = [[UILabel alloc] initWithFrame:nameFrame];
    [packageNameLabel setFont:[UIFont systemFontOfSize:50 weight: UIFontWeightSemibold] ];
    packageNameLabel.textColor = [UIColor whiteColor];
    packageNameLabel.text = @"Meteoroid";

    developerLabel = [[UILabel alloc] initWithFrame:developerFrame];
    [developerLabel setFont:[UIFont systemFontOfSize:25 weight: UIFontWeightMedium] ];
    developerLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
    developerLabel.text = @"JeffResc";

    versionLabel = [[UILabel alloc] initWithFrame:versionFrame];
    [versionLabel setFont:[UIFont systemFontOfSize:22 weight: UIFontWeightMedium] ];
    versionLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    versionLabel.text = @"2.0";

    bgView.backgroundColor = [UIColor colorWithRed:0.46 green:0.72 blue:0.84 alpha:1.0];

    [self addSubview:packageNameLabel];
    [self addSubview:developerLabel];
    [self addSubview:versionLabel];
  }
  return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WotsitBetaTitleCell" specifier:specifier];
}

- (void)setFrame:(CGRect)frame {
	frame.origin.x = 0;
	[super setFrame:frame];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
    return 215.0f;
}

-(void)layoutSubviews{
	[super layoutSubviews];
	int width = self.contentView.bounds.size.width;
    CGRect frame = CGRectMake(0, 0, width, 215);

    bgView = [[UIView alloc] initWithFrame:frame];

    UIColor *topColor = UIColorFromRGB(0xf27121);
    UIColor *bottomColor = UIColorFromRGB(0xf27121);

    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.startPoint = CGPointMake(0.0, 0.0);
    theViewGradient.endPoint = CGPointMake(1.0, 1.0);
    theViewGradient.frame = bgView.bounds;

    [bgView.layer insertSublayer:theViewGradient atIndex:0];
    [self insertSubview:bgView atIndex:0];

}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
	return [self preferredHeightForWidth:width];
}

@end
