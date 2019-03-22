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
#import <SpringBoard/SBFolder.h>
#import <SpringBoard/SBFolderIcon.h>
#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconLabelImage.h>
#import <SpringBoard/SBIconLabelImageParameters.h>
#import <SpringBoard/SBIconLabelView.h>
#import <SpringBoard/SBIconLegibilityLabelView.h>
#import <SpringBoard/SBIconView.h>
#import <SpringBoard/SBIconViewMap.h>
#import <SpringBoard/SBDockIconListView.h>

#pragma mark - Static variables

static const GGPrefsManager *_prefs;

#pragma mark - SpringBoard classes

@interface SBIconView (Goodges)

-(void)shakeIcon;

@end

#pragma mark - GGIconLabelImageParameters definition

@interface GGIconLabelImageParameters : SBIconLabelImageParameters

@property (nonatomic, assign) BOOL allowsBadging;
@property (nonatomic, retain) SBFolderIcon *folderIcon;
@property (nonatomic, retain) SBApplicationIcon *icon;

-(instancetype)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon;

-(SBApplicationIcon *)mainIconForFolder:(SBIcon *)folderIcon;

@end

#pragma mark - Subclasses implementation

// We create a subclass of SBIconLabelImageParameters so we can modify values more easily.
%subclass GGIconLabelImageParameters : SBIconLabelImageParameters

%property (nonatomic, assign) BOOL allowsBadging;
%property (nonatomic, retain) SBFolderIcon *folderIcon;
%property (nonatomic, retain) SBApplicationIcon *icon;

%new
-(instancetype)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon {
    self = [self initWithParameters:params];

    if(self) {
        if([icon isFolderIcon]) {
            self.folderIcon = (SBFolderIcon *)icon;
            self.icon = [self mainIconForFolder:icon];
        } else {
            self.icon = (SBApplicationIcon *)icon;
        }

        self.allowsBadging = self.icon != nil
                             && [_prefs appIsEnabledForDisplayIdentifier:[self.icon applicationBundleID]]
                             && [[%c(SBIconController) sharedInstance] iconAllowsBadging:icon]
                             && [self.icon badgeValue] > 0;
    }

    return self;
}

// This method is useful to know which icon has to be displayed for a folder.
%new
-(SBApplicationIcon *)mainIconForFolder:(SBIcon *)folderIcon {
    if(![folderIcon isKindOfClass:[%c(SBFolderIcon) class]])
        return (SBApplicationIcon *)folderIcon;

    SBApplicationIcon *ret = nil;

    SBFolder *folder = [(SBFolderIcon *)folderIcon folder];
    for(SBApplicationIcon *icon in [folder allIcons]) {
        if(![[%c(SBIconController) sharedInstance] iconAllowsBadging:icon] || ![_prefs appIsEnabledForDisplayIdentifier:[icon applicationBundleID]]) {
            continue;
        }

        if(ret == nil) {
            ret = icon;
        } else if(ret != nil && [icon badgeValue] > [ret badgeValue]) {
            ret = icon;
        }
    }

    return ret;
}

// Would be great to know why do we have to set the return value to 'NO'. If we don't do that, labels appear gray...
-(BOOL)colorspaceIsGrayscale {
    if(self.allowsBadging) {
        return NO;
    }

    return %orig();
}

-(UIColor *)textColor {
    if(self.allowsBadging && [_prefs boolForKey:kEnableLabels]) {
        if([_prefs boolForKey:kLabelsUseCB]) {
            int color = [[%c(ColorBadges) sharedInstance] colorForIcon:self.icon];

            return [UIColor RGBAColorFromHexString:[NSString stringWithFormat:@"#0x%0X", color]];
        } else if([_prefs boolForKey:kInverseColor]) {
            UIColor *color = [self focusHighlightColor];

            return [UIColor inverseColor:color];
        }

        return [UIColor RGBAColorFromHexString:[_prefs valueForKey:kLabelsColor]];
    } else if(self.allowsBadging && [_prefs boolForKey:kEnableHighlight] && [_prefs boolForKey:kHighlightUseCB]) {
        int color = [[%c(ColorBadges) sharedInstance] colorForIcon:self.icon];

        if([%c(ColorBadges) isDarkColor:color]) {
            return [UIColor whiteColor];
        } else {
            return [UIColor blackColor];
        }
    }

    return %orig();
}

-(UIColor *)focusHighlightColor {
    // If highlighting is enabled
    if(self.allowsBadging && [_prefs boolForKey:kEnableHighlight]) {
        if([_prefs boolForKey:kHighlightUseCB]) {
            int color = [[%c(ColorBadges) sharedInstance] colorForIcon:self.icon];

            return [UIColor RGBAColorFromHexString:[NSString stringWithFormat:@"#0x%0X", color]];
        }

        return [UIColor RGBAColorFromHexString:[_prefs valueForKey:kHighlightColor]];
    }

    return %orig();
}

-(NSString *)text {
    NSInteger badgeValue = (self.folderIcon != nil) ? [self.folderIcon badgeValue] : [self.icon badgeValue];

    if(self.allowsBadging) {
        if([_prefs boolForKey:kShowOnlyNumbers]) {
            return [NSString stringWithFormat:@"%ld", (long)badgeValue];
        } else {
            NSString *appLabel;
            if(badgeValue == 1 && badgeValue == [self.icon badgeValue]) {
                appLabel = [_prefs valueForKey:kSingularLabel forDisplayIdentifier:[self.icon applicationBundleID]];
                if(appLabel == nil) {
                    appLabel = kDefaultNotification;
                }

                appLabel = [_prefs localizedStringForKey:appLabel];
            } else if(badgeValue > 1 && badgeValue == [self.icon badgeValue]) {
                appLabel = [_prefs valueForKey:kPluralLabel forDisplayIdentifier:[self.icon applicationBundleID]];
                if(appLabel == nil) {
                    appLabel = kDefaultNotifications;
                }

                appLabel = [_prefs localizedStringForKey:appLabel];
            } else {
                appLabel = [_prefs localizedStringForKey:kDefaultNotifications];
            }

            if([_prefs boolForKey:kCapitalizeFirstLetter]) {
                appLabel = [NSString stringWithFormat:@"%@%@", [[appLabel substringToIndex:1] uppercaseString], [appLabel substringFromIndex:1]];
            }

            return [NSString stringWithFormat:@"%ld %@", (long)badgeValue, appLabel];
        }
    } else if(!self.allowsBadging && [_prefs boolForKey:kHideAllLabels]) {
        return nil;
    }

    return %orig();
}

-(void)dealloc {
    self.icon = nil;

    %orig();
}

%end    // 'GGIconLabelImageParameters' subclass


#pragma mark - Hooks

%hook SBDockIconListView

// Move icons in the dock up to make space for the labels
-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1 {
    if (![_prefs boolForKey:kUseBadgesForDock]) {
        CGPoint point = %orig;
        CGPoint newPoint = CGPointMake(point.x, point.y - 7);
        return newPoint;
    } else {
        return %orig;
    }
}

%end    // 'SBDockIconListView' hook

%hook SBIconView

// Don't hide labels in the dock
-(void)setContentType:(unsigned long long)arg1 {
    if (arg1 == 1 && ![_prefs boolForKey:kUseBadgesForDock]) {
        %orig(0);
    } else {
        %orig;
    }
}

// Set label parameters to what we want.
-(SBIconLabelImageParameters *)_labelImageParameters {
    SBIconLabelImageParameters *params = %orig();

    SBIcon *icon = [self icon];

    // We check that the parameters are not nil.
    if(params != nil) {
        params = [[%c(GGIconLabelImageParameters) alloc] initWithParameters:params icon:icon];
    }

    return params;
}

-(void)layoutSubviews {
    SBIcon *icon = [self icon];
    NSInteger badgeValue = [icon badgeValue];

    // Disable legibility settings for Goodges labels (prevents iOS from darkening the label on a bright wallpaper)
    _UILegibilitySettings* settings = badgeValue > 0 ? nil : [self legibilitySettings];

    SBIconLabelImageParameters *params = [self _labelImageParameters];
    SBIconLabelView *labelView = MSHookIvar<SBIconLabelView *>(self, "_labelView");

    if(labelView != nil) {
        // It's necessary to reload the label image every time the label is updated.
        [labelView updateIconLabelWithSettings:settings imageParameters:params];
        SBIconLabelImage *labelImage = [%c(SBIconLabelImage) _drawLabelImageForParameters:params];

        if([labelView isKindOfClass:%c(SBIconLegibilityLabelView)]) {
            [labelView setImage:labelImage];
            [labelView.imageView setImage:labelImage];

            CGRect frame = labelView.imageView.frame;
            frame.size = labelImage.size;

            [labelView.imageView setFrame:frame];
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

    BOOL allowsBadging = [[%c(SBIconController) sharedInstance] iconAllowsBadging:icon];

    BOOL labelHidden = [_prefs boolForKey:kHideAllLabels] && (badgeValue < 1 || !allowsBadging);
    [self setLabelHidden:labelHidden];

    %orig();

    // Remove badges.
    UIView *accessoryView = MSHookIvar<UIView *>(self, "_accessoryView");
    if(accessoryView && [accessoryView isKindOfClass:%c(SBIconBadgeView)] && [_prefs boolForKey:kHideBadges] &&
        ([self location] != 3 || ![_prefs boolForKey:kUseBadgesForDock])) {
            accessoryView.hidden = YES;
        }

    if([_prefs boolForKey:kEnableShaking]) {
        // Crossfade view is not nil when the application is launching. If shaking icons is enabled,
        // we must remove the animations before the launch or it will create animations issues.
        UIView *crossfadeView = MSHookIvar<UIView *>(self, "_crossfadeView");

        if(allowsBadging && badgeValue > 0 && [_prefs appIsEnabledForDisplayIdentifier:[self.icon applicationBundleID]] && crossfadeView == nil) {
            [self shakeIcon];
        } else {
            [[self layer] removeAllAnimations];
        }
    }
}

%new
-(void)shakeIcon {
    if(![[self.layer animationKeys] containsObject:@"SBIconPosition"]) {
        [self.layer addAnimation:[%c(SBIconView) _jitterRotationAnimation] forKey:@"SBIconPosition"];
    }
}

// Remove update dot for better display if labels are hidden.
-(BOOL)shouldShowLabelAccessoryView {
    if([_prefs boolForKey:kHideAllLabels]) {
        return NO;
    }

    return %orig();
}

-(void)_updateLabel {
    SBIcon *icon = [self icon];
    NSInteger badgeValue = [icon badgeValue];
    BOOL allowsBadging = [[%c(SBIconController) sharedInstance] iconAllowsBadging:icon] && badgeValue > 0;

    // Glowing icon.
    if([_prefs boolForKey:kEnableGlow]) {
        if(allowsBadging && [_prefs appIsEnabledForDisplayIdentifier:[self.icon applicationBundleID]]) {
            [self prepareDropGlow];
            [self showDropGlow:YES];
        } else {
            [self removeDropGlow];
        }
    }

    %orig();
}

%end    // 'SBIconView' hook


%hook SBIconController

-(void)removeAllIconAnimations {
    SBRootIconListView *rootView = [self currentRootIconList];
    NSArray *icons = [rootView icons];
    SBIconViewMap* map = [rootView viewMap];

    for(SBIcon *icon in icons) {
        if([self iconAllowsBadging:icon] && [icon badgeValue] > 0 && [_prefs boolForKey:kEnableShaking]) {
            continue;
        }

        SBIconView *iconView = [map mappedIconViewForIcon:icon];
        [iconView removeAllIconAnimations];
    }

    SBIconListView *dockView = [self dockListView];
    icons = [dockView icons];
    map = [dockView viewMap];

    for(SBIcon *icon in icons) {
        if([self iconAllowsBadging:icon] && [icon badgeValue] > 0 && [_prefs boolForKey:kEnableShaking]) {
            continue;
        }

        SBIconView *iconView = [map mappedIconViewForIcon:icon];
        [iconView removeAllIconAnimations];
    }
}

%end    // 'SBIconController' hook


%ctor {
    _prefs = [%c(GGPrefsManager) sharedManager];

    dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBadges.dylib", RTLD_LAZY);
    dlopen("/Library/MobileSubstrate/DynamicLibraries/Harbor.dylib", RTLD_NOW);

    if([_prefs boolForKey:kEnabled]) {
        HBLogDebug(@"Goodges enabled. Launching...");
        %init(_ungrouped);
    } else {
        HBLogDebug(@"Goodges not enabled. Doing nothing.");
    }
}
