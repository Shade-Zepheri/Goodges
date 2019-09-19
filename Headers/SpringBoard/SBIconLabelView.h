@protocol SBIconLabelView
@property (strong, nonatomic) UIImage *image; 

@required
- (UIImage *)image;
- (void)setImage:(UIImage *)image;

- (void)updateIconLabelWithSettings:(id)settings imageParameters:(id)parameters;
- (instancetype)initWithSettings:(id)settings;

@end