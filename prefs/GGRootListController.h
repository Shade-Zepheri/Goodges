#import <GGPrefsManager.h>

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface GGRootListController : PSListController

@property (nonatomic, retain) GGPrefsManager *prefs;

- (void)respring;

@end

@interface GoodgesLogo : PSTableCell {
	UILabel *background;
	UILabel *tweakName;
	UILabel *version;
}
@end
