@interface UIColor (Goodges)

+ (UIColor *)RGBAColorFromHexString:(NSString *)string;
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (UIColor *)inverseColor:(UIColor *)color;

@end

typedef struct SBIconCoordinate {
    long long row;
    long long col;
} SBIconCoordinate;
