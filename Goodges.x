/*
    Goodges
    Goodbye badges, hello labels!

    Copyright (C) 2017 - faku99 <faku99dev@gmail.com>
    Copyright (C) 2019 - NoisyFlake <u/NoisyFlake>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#import <version.h>

#import <GGPrefsManager.h>
#import <UIColor+Goodges.h>

#import <ColorBadges.h>
#import <MobileIcons/MobileIcons.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBDockIconListView.h>
#import <SpringBoard/SBFolder.h>
#import <SpringBoard/SBFolderIcon.h>
#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBIconController+Private.h>
#import <SpringBoard/SBIconLabelImage.h>
#import <SpringBoard/SBIconLabelImageParameters.h>
#import <SpringBoard/SBIconLabelView.h>
#import <SpringBoard/SBIconLegibilityLabelView.h>
#import <SpringBoard/SBIconListView+Private.h>
#import <SpringBoard/SBIconView+Private.h>
#import <SpringBoard/SBIconViewMap+Private.h>
#import <SpringBoard/SBRootIconListView.h>

#import <UIKit/_UILegibilitySettings.h>

#pragma mark - Static variables

static const GGPrefsManager *_prefs;
static BOOL hasFullyLoaded = NO;

#pragma mark - SpringBoard classes

@interface SBIconView (Goodges)

- (void)shakeIcon;

@end

#pragma mark - GGIconLabelImageParameters definition

@interface GGIconLabelImageParameters : SBIconLabelImageParameters

@property (nonatomic, assign) BOOL allowsBadging;
@property (nonatomic, retain) SBFolderIcon *folderIcon;
@property (nonatomic, retain) SBApplicationIcon *icon;

- (instancetype)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon;

- (SBApplicationIcon *)mainIconForFolder:(SBIcon *)folderIcon;

@end

#pragma mark - Subclasses implementation

// We create a subclass of SBIconLabelImageParameters so we can modify values more easily.
%subclass GGIconLabelImageParameters : SBIconLabelImageParameters

%property (nonatomic, assign) BOOL allowsBadging;
%property (nonatomic, retain) SBFolderIcon *folderIcon;
%property (nonatomic, retain) SBApplicationIcon *icon;

%new
- (instancetype)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon {
    self = [self initWithParameters:params];
    if (self) {
        if ([icon isFolderIcon]) {
            self.folderIcon = (SBFolderIcon *)icon;
            self.icon = [self mainIconForFolder:icon];
        } else {
            self.icon = (SBApplicationIcon *)icon;
        }

        self.allowsBadging = self.icon != nil
                             && [_prefs appIsEnabledForDisplayIdentifier:[self.icon applicationBundleID]]               // Cydia supports badges but has them turned off
                             && ([[%c(SBIconController) sharedInstance] iconAllowsBadging:icon] || [[self.icon applicationBundleID] containsString:@"com.saurik.Cydia"])
                             && [self.icon badgeValue] > 0;
    }

    return self;
}

// This method is useful to know which icon has to be displayed for a folder.
%new
- (SBApplicationIcon *)mainIconForFolder:(SBIcon *)folderIcon {
    if (![folderIcon isKindOfClass:%c(SBFolderIcon)]) {
        return (SBApplicationIcon *)folderIcon;
    }

    SBApplicationIcon *ret = nil;

    SBFolder *folder = [(SBFolderIcon *)folderIcon folder];
    for (SBApplicationIcon *icon in [folder allIcons]) {
        if (![[%c(SBIconController) sharedInstance] iconAllowsBadging:icon] || ![_prefs appIsEnabledForDisplayIdentifier:[icon applicationBundleID]]) {
            continue;
        }

        if (!ret) {
            ret = icon;
        } else if (ret && [icon badgeValue] > [ret badgeValue]) {
            ret = icon;
        }
    }

    return ret;
}

// Would be great to know why do we have to set the return value to 'NO'. If we don't do that, labels appear gray...
- (BOOL)colorspaceIsGrayscale {
    if (self.allowsBadging) {
        return NO;
    }

    return %orig;
}

- (UIColor *)textColor {
    if (self.allowsBadging && [_prefs boolForKey:kEnableLabels]) {
        if ([_prefs boolForKey:kLabelsUseCB]) {
            int color = [[%c(ColorBadges) sharedInstance] colorForIcon:self.icon];

            return [UIColor RGBAColorFromHexString:[NSString stringWithFormat:@"#0x%0X", color]];
        } else if ([_prefs boolForKey:kInverseColor]) {
            UIColor *color = [self focusHighlightColor];

            return [UIColor inverseColor:color];
        }

        return [UIColor RGBAColorFromHexString:[_prefs valueForKey:kLabelsColor]];
    } else if (self.allowsBadging && [_prefs boolForKey:kEnableHighlight] && [_prefs boolForKey:kHighlightUseCB]) {
        int color = [[%c(ColorBadges) sharedInstance] colorForIcon:self.icon];

        if ([%c(ColorBadges) isDarkColor:color]) {
            return [UIColor whiteColor];
        } else {
            return [UIColor blackColor];
        }
    }

    return %orig;
}

- (UIColor *)focusHighlightColor {
    // If highlighting is enabled
    if (self.allowsBadging && [_prefs boolForKey:kEnableHighlight]) {
        if ([_prefs boolForKey:kHighlightUseCB]) {
            int color = [[%c(ColorBadges) sharedInstance] colorForIcon:self.icon];

            return [UIColor RGBAColorFromHexString:[NSString stringWithFormat:@"#0x%0X", color]];
        }

        return [UIColor RGBAColorFromHexString:[_prefs valueForKey:kHighlightColor]];
    }

    return %orig;
}

- (NSString *)text {
    NSInteger badgeValue = (self.folderIcon != nil) ? [self.folderIcon badgeValue] : [self.icon badgeValue];

    if (self.allowsBadging) {
        if ([_prefs boolForKey:kShowOnlyNumbers]) {
            return [NSString stringWithFormat:@"%ld", (long)badgeValue];
        } else {
            NSString *appLabel;
            if (badgeValue == 1 && badgeValue == [self.icon badgeValue]) {
                appLabel = [_prefs valueForKey:kSingularLabel forDisplayIdentifier:[self.icon applicationBundleID]];
                if (!appLabel) {
                    appLabel = kDefaultNotification;
                }

                appLabel = [_prefs localizedStringForKey:appLabel];
            } else if (badgeValue > 1 && badgeValue == [self.icon badgeValue]) {
                appLabel = [_prefs valueForKey:kPluralLabel forDisplayIdentifier:[self.icon applicationBundleID]];
                if (!appLabel) {
                    appLabel = kDefaultNotifications;
                }

                appLabel = [_prefs localizedStringForKey:appLabel];
            } else {
                appLabel = [_prefs localizedStringForKey:kDefaultNotifications];
            }

            if ([_prefs boolForKey:kCapitalizeFirstLetter]) {
                appLabel = [NSString stringWithFormat:@"%@%@", [[appLabel substringToIndex:1] uppercaseString], [appLabel substringFromIndex:1]];
            }

            return [NSString stringWithFormat:@"%ld %@", (long)badgeValue, appLabel];
        }
    }

    return %orig;
}

- (void)dealloc {
    self.icon = nil;

    %orig;
}

%end    // 'GGIconLabelImageParameters' subclass


#pragma mark - Hooks

%hook SBDockIconListView

// Move icons in the dock up to make space for the labels
- (CGPoint)originForIconAtCoordinate:(SBIconCoordinate)coordinate {
    CGPoint point = %orig;
    NSArray *icons = [self icons];

    NSUInteger count = 1;
    for (SBIcon *icon in icons) {
        if (count == coordinate.col) {
            // This is the icon we are currently setting the origin for
            if (([icon badgeValue] > 0 && ![_prefs boolForKey:kUseBadgesForDock]) || [_prefs boolForKey:kShowDockLabels]) {
                CGPoint newPoint = CGPointMake(point.x, point.y - 7);
                return newPoint;
            }
        }

        count++;
    }

    return %orig;
}

%end    // 'SBDockIconListView' hook

%hook SBIconView

// Allow labels in the dock (might be hidden later in layoutSubviews though)
- (void)setContentType:(NSUInteger)type {
    if (type == 1) {
        %orig(0);
    } else {
        %orig;
    }

}

// Set label parameters to what we want.
- (SBIconLabelImageParameters *)_labelImageParameters {
    SBIconLabelImageParameters *params = %orig;

    SBIcon *icon = [self icon];

    // We check that the parameters are not nil.
    if (params) {
        params = [[%c(GGIconLabelImageParameters) alloc] initWithParameters:params icon:icon];
    }

    return params;
}

- (void)layoutSubviews {
    SBIcon *icon = [self icon];
    NSInteger badgeValue = [icon badgeValue];

    // Disable legibility settings for Goodges labels (prevents iOS from darkening the label on a bright wallpaper)
    _UILegibilitySettings *settings = badgeValue > 0 ? nil : self.legibilitySettings;

    SBIconLabelImageParameters *params = [self _labelImageParameters];
    UIView<SBIconLabelView> *labelView = [self valueForKey:@"_labelView"];

    if (labelView) {
        // It's necessary to reload the label image every time the label is updated.
        [labelView updateIconLabelWithSettings:settings imageParameters:params];
        SBIconLabelImage *labelImage = [%c(SBIconLabelImage) _drawLabelImageForParameters:params];

        if ([labelView isKindOfClass:%c(SBIconLegibilityLabelView)]) {
            [labelView setImage:labelImage];
            // [labelView.imageView setImage:labelImage];

            // CGRect frame = labelView.imageView.frame;
            // frame.size = labelImage.size;

            // [labelView.imageView setFrame:frame];
        } else if ([labelView isKindOfClass:%c(SBIconSimpleLabelView)]) {
            // SBIconSimpleLabelView (used for Dock Icons) is already a UIImageView, so no need to get imageView
            [labelView setImage:labelImage];

            CGRect frame = labelView.frame;
            frame.size = labelImage.size;

            [labelView setFrame:frame];
        } else {
            // Should only happen in future iOS versions if Apple changes the SBIconLabelView again
            HBLogWarn(@"Unable to update icon label: unsupported SBIconLabelView class detected");
        }

    }

    BOOL allowsBadging = [[%c(SBIconController) sharedInstance] iconAllowsBadging:icon] || [[icon applicationBundleID] containsString:@"com.saurik.Cydia"];
    BOOL labelHidden = [_prefs boolForKey:kHideAllLabels] && (badgeValue < 1 || !allowsBadging);

    // Special label settings when it's a dock label (3 = dock; 4 = dock suggestions)
    if (self.location == 3 || self.location == 4) {
        if ([_prefs boolForKey:kShowDockLabels]) {
            labelHidden = NO;
        } else if (![_prefs boolForKey:kShowDockLabels] && [_prefs boolForKey:kUseBadgesForDock]) {
            labelHidden = YES;
        } else if (badgeValue < 1 || !allowsBadging) {
            labelHidden = YES;
        }
    }

    [self setLabelHidden:labelHidden];

    SBIconController *controller = [%c(SBIconController) sharedInstance];

    // layoutIconsNow causes originForIconAtCoordinate to be called in order to raise or lower the icon if necessary
    // However it causes a freeze or respring when called too early or when dragging icons
    if (![_prefs boolForKey:kShowDockLabels] && ![_prefs boolForKey:kUseBadgesForDock] && hasFullyLoaded && !controller.iconDragging) {
        // Execute this a bit later because otherwise opening previously unopened apps will crash the Springboard.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
            SBDockIconListView *dockView = controller.dockListView;
            [dockView layoutIconsNow];

            SBIconListView *floatingDockView = [controller floatingDockListView];
            [floatingDockView layoutIconsNow];

            SBIconListView *floatingDockSuggestionsView = [controller floatingDockSuggestionsListView];
            [floatingDockSuggestionsView layoutIconsNow];
        });
    }

    %orig;

    // Fix compatibility with FloatingDock(Plus)
    labelView.hidden = labelHidden;

    // Remove badges.
    UIView *accessoryView = [self valueForKey:@"_accessoryView"];
    if (accessoryView && [accessoryView isKindOfClass:%c(SBIconBadgeView)] && [_prefs boolForKey:kHideBadges] &&
        (([self location] != 3 && [self location] != 4) || ![_prefs boolForKey:kUseBadgesForDock])) {
            accessoryView.hidden = YES;
        }

    if ([_prefs boolForKey:kEnableShaking]) {
        // Crossfade view is not nil when the application is launching. If shaking icons is enabled,
        // we must remove the animations before the launch or it will create animations issues.
        UIView *crossfadeView = [self valueForKey:@"_crossfadeView"];

        if (allowsBadging && badgeValue > 0 && [_prefs appIsEnabledForDisplayIdentifier:[self.icon applicationBundleID]] && !crossfadeView) {
            [self shakeIcon];
        } else {
            [[self layer] removeAllAnimations];
        }
    }
}

%new
- (void)shakeIcon {
    if (![[self.layer animationKeys] containsObject:@"SBIconPosition"]) {
        [self.layer addAnimation:[%c(SBIconView) _jitterRotationAnimation] forKey:@"SBIconPosition"];
    }
}

// Remove update dot for better display if labels are hidden.
- (BOOL)shouldShowLabelAccessoryView {
    if ([_prefs boolForKey:kHideAllLabels]) {
        return NO;
    }

    return %orig;
}

- (void)_updateLabel {
    SBIcon *icon = [self icon];
    NSInteger badgeValue = [icon badgeValue];
    BOOL allowsBadging = [[%c(SBIconController) sharedInstance] iconAllowsBadging:icon] && badgeValue > 0;

    // Glowing icon.
    if ([_prefs boolForKey:kEnableGlow]) {
        if (allowsBadging && [_prefs appIsEnabledForDisplayIdentifier:[self.icon applicationBundleID]]) {
            [self prepareDropGlow];
            [self showDropGlow:YES];
        } else {
            [self removeDropGlow];
        }
    }

    %orig;
}

%end    // 'SBIconView' hook


%hook SBIconController

- (void)removeAllIconAnimations {
    SBRootIconListView *rootView = [self currentRootIconList];
    NSArray *icons = [rootView icons];
    SBIconViewMap *map = [rootView viewMap];

    for (SBIcon *icon in icons) {
        if ([self iconAllowsBadging:icon] && [icon badgeValue] > 0 && [_prefs boolForKey:kEnableShaking]) {
            continue;
        }

        SBIconView *iconView = [map mappedIconViewForIcon:icon];
        [iconView removeAllIconAnimations];
    }

    SBIconListView *dockView = [self dockListView];
    icons = [dockView icons];
    map = [dockView viewMap];

    for (SBIcon *icon in icons) {
        if ([self iconAllowsBadging:icon] && [icon badgeValue] > 0 && [_prefs boolForKey:kEnableShaking]) {
            continue;
        }

        SBIconView *iconView = [map mappedIconViewForIcon:icon];
        [iconView removeAllIconAnimations];
    }
}

%end    // 'SBIconController' hook

%ctor {
    _prefs = [GGPrefsManager sharedManager];

    dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBadges.dylib", RTLD_LAZY);
    dlopen("/Library/MobileSubstrate/DynamicLibraries/Harbor.dylib", RTLD_NOW);

    if ([_prefs boolForKey:kEnabled]) {
        HBLogDebug(@"Goodges enabled. Launching...");
        %init;

        // Apply stuff when SB loaded
        NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
        id __block token = [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                hasFullyLoaded = YES;
            });

            // Deregister as only created once
            [center removeObserver:token];
        }];
    } else {
        HBLogDebug(@"Goodges not enabled. Doing nothing.");
    }
}
