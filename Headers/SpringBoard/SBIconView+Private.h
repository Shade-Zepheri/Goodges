#import <SpringBoard/SBIconView.h>

@class SBIconLabelImageParameters, _UILegibilitySettings;

@interface SBIconView ()
@property (strong, nonatomic) _UILegibilitySettings *legibilitySettings;
@property (assign, nonatomic) NSInteger location;

+ (id)_jitterRotationAnimation;

- (void)prepareDropGlow;
- (void)showDropGlow:(BOOL)show;
- (void)removeDropGlow;

- (SBIconLabelImageParameters *)_labelImageParameters;

- (void)setLabelHidden:(BOOL)hidden;

- (void)removeAllIconAnimations;

@end