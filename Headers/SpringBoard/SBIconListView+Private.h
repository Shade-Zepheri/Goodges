#import <SpringBoard/SBIconListView.h>

@interface SBIconListView ()
@property (strong, nonatomic) SBIconViewMap *viewMap;

- (NSArray *)icons;
- (void)layoutIconsNow;

@end