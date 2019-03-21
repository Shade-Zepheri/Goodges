#import <GGPrefsManager.h>

#import <Preferences/PSSpecifier.h>

#import "GGDeveloperCellActive.h"

@interface GGDeveloperCellActive ()

@property (nonatomic, retain) NSBundle *bundle;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;

- (void)openReddit;

@end


@implementation GGDeveloperCellActive

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if(self) {
        _bundle = [NSBundle bundleWithPath:BUNDLE_PATH];
        [_bundle load];

        // Labels
        self.textLabel.text = @"NoisyFlake";
        self.detailTextLabel.text = @"u/NoisyFlake";
        self.detailTextLabel.textColor = [UIColor colorWithRed:1.00 green:0.34 blue:0.00 alpha:1.0];

        // Right image
        UIImage *redditLogo = [UIImage imageNamed:@"images/reddit" inBundle:_bundle compatibleWithTraitCollection:nil];
        self.accessoryView = [[[UIImageView alloc] initWithImage:redditLogo] autorelease];

        [specifier setTarget:self];
        [specifier setButtonAction:@selector(openReddit)];
    }

    return self;
}

-(void)openReddit {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"reddit:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"reddit:///u/NoisyFlake"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"apollo:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"apollo://www.reddit.com/u/NoisyFlake"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/u/NoisyFlake"]];
    }
}

@end
