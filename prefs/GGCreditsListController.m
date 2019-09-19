#import "GGCreditsListController.h"

@interface GGCreditsListController ()

@end


@implementation GGCreditsListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Credits" target:self];
    }

    return _specifiers;
}

@end
