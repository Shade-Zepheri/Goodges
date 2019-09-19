#import <SpringBoard/SBIconController.h>

@class SBIcon, SBIconListView;

@interface SBIconController ()
@property (getter=isIconDragging, readonly, nonatomic) BOOL iconDragging;
@property (readonly, nonatomic) SBIconListView *floatingDockListView;
@property (readonly, nonatomic) SBIconListView *floatingDockSuggestionsListView;

- (BOOL)iconAllowsBadging:(SBIcon *)icon;

@end