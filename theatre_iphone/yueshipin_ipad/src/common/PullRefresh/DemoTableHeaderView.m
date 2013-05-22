//
// DemoTableHeaderView.m
//
// @author Shiki
//

#import "DemoTableHeaderView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DemoTableHeaderView

@synthesize title,dateLabel;
@synthesize activityIndicator;
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) awakeFromNib
{
  self.backgroundColor = [UIColor clearColor];
  title.font = [UIFont boldSystemFontOfSize:15];
  title.textColor = [UIColor grayColor];
  dateLabel.font = [UIFont boldSystemFontOfSize:11];
  dateLabel.textColor = [UIColor grayColor];
  dateLabel.text = @"";
  [super awakeFromNib];
}

@end
