// superfps.m  
// Dynamic library (dylib) for iOS FPS overlay  
#import <UIKit/UIKit.h>  
#import <QuartzCore/QuartzCore.h>  
  
// Forward declarations  
static void SuperFPS_ShowOverlay(void);  
void SuperFPS_Start(void);  
  
#pragma mark - FPS Display View  
  
@interface SuperFPSView : UIView  
@property (nonatomic, strong) CADisplayLink *displayLink;  
@property (nonatomic, strong) UILabel *fpsLabel;  
@property (nonatomic, assign) NSTimeInterval lastTimestamp;  
@property (nonatomic, assign) NSInteger frameCount;  
@end  
  
@implementation SuperFPSView  
  
- (instancetype)initWithFrame:(CGRect)frame {  
    self = [super initWithFrame:frame];  
    if (!self) return nil;  
  
    self.backgroundColor = [UIColor clearColor];  
    self.layer.cornerRadius = frame.size.height / 2.0;  
    self.layer.masksToBounds = YES;  
  
    // Create "liquid glass" gradient background  
    CAGradientLayer *gradient = [CAGradientLayer layer];  
    gradient.frame = self.bounds;  
    gradient.colors = @[  
        (id)[UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:0.8].CGColor,  
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:1.0 alpha:0.8].CGColor,  
        (id)[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:0.8].CGColor  
    ];  
    gradient.startPoint = CGPointMake(0.0, 0.0);  
    gradient.endPoint   = CGPointMake(1.0, 1.0);  
    gradient.cornerRadius = self.layer.cornerRadius;  
    [self.layer insertSublayer:gradient atIndex:0];  
  
    // Add a blur effect for liquid glass feel  
    if (@available(iOS 13.0, *)) {  
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];  
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:effect];  
        blur.frame = self.bounds;  
        blur.layer.cornerRadius = self.layer.cornerRadius;  
        blur.layer.masksToBounds = YES;  
        blur.userInteractionEnabled = NO;  
        [self addSubview:blur];  
    }  
  
    // FPS label  
    _fpsLabel = [[UILabel alloc] initWithFrame:self.bounds];  
    _fpsLabel.textAlignment = NSTextAlignmentCenter;  
    _fpsLabel.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightBold];  
    _fpsLabel.textColor = [UIColor whiteColor];  
    _fpsLabel.adjustsFontSizeToFitWidth = YES;  
    _fpsLabel.minimumScaleFactor = 0.5;  
    _fpsLabel.text = @"FPS: --";  
    [self addSubview:_fpsLabel];  
  
    // DisplayLink for FPS calculation  
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];  
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];  
  
    _lastTimestamp = 0;  
    _frameCount = 0;  
  
    return self;  
}  
  
- (void)dealloc {  
    [_displayLink invalidate];  
    _displayLink = nil;  
}  
  
- (void)layoutSubviews {  
    [super layoutSubviews];  
    self.fpsLabel.frame = self.bounds;  
    for (CALayer *layer in self.layer.sublayers) {  
        layer.frame = self.bounds;  
        layer.cornerRadius = self.layer.cornerRadius;  
    }  
}  
  
- (void)tick:(CADisplayLink *)link {  
    if (self.lastTimestamp == 0) {  
        self.lastTimestamp = link.timestamp;  
        return;  
    }  
  
    self.frameCount++;  
    NSTimeInterval delta = link.timestamp - self.lastTimestamp;  
    if (delta < 0.25) {  
        return;  
    }  
  
    CGFloat fps = (CGFloat)self.frameCount / delta;  
    self.lastTimestamp = link.timestamp;  
    self.frameCount = 0;  
  
    // Clamp between 0 and 120  
    if (fps < 0) fps = 0;  
    if (fps > 120) fps = 120;  
  
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %.0f", fps];  
  
    // Color shift based on FPS (green -> yellow -> red)  
    CGFloat progress = fps / 60.0;  
    progress = MAX(0.0, MIN(1.0, progress));  
  
    UIColor *goodColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.6 alpha:1.0];  
    UIColor *badColor  = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];  
  
    CGFloat gr, gg, gb, ga;  
    CGFloat br, bg, bb, ba;  
    [goodColor getRed:&gr green:&gg blue:&gb alpha:&ga];  
    [badColor getRed:&br green:&bg blue:&bb alpha:&ba];  
  
    CGFloat rr = br + (gr - br) * progress;  
    CGFloat rg = bg + (gg - bg) * progress;  
    CGFloat rb = bb + (gb - bb) * progress;  
  
    self.fpsLabel.textColor = [UIColor colorWithRed:rr green:rg blue:rb alpha:1.0];  
}  
  
@end  
  
#pragma mark - Overlay Window  
  
@interface SuperFPSWindow : UIWindow  
@end  
  
@implementation SuperFPSWindow  
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {  
    // Allow touches to pass through overlay  
    return NO;  
}  
@end  
  
static SuperFPSWindow *gSuperFPSWindow = nil;  
  
static void SuperFPS_ShowOverlay(void) {  
    if (gSuperFPSWindow) return;  
  
    dispatch_async(dispatch_get_main_queue(), ^{  
        CGRect screenBounds = [UIScreen mainScreen].bounds;  
  
        CGFloat width  = 140.0;  
        CGFloat height = 40.0;  
        CGFloat margin = 12.0;  
  
        CGRect frame = CGRectMake(  
            screenBounds.size.width - width - margin,  
            margin + 30.0,  
            width,  
            height  
        );  
  
        gSuperFPSWindow = [[SuperFPSWindow alloc] initWithFrame:screenBounds];  
        gSuperFPSWindow.backgroundColor = [UIColor clearColor];  
        gSuperFPSWindow.windowLevel = UIWindowLevelStatusBar + 1000;  
        gSuperFPSWindow.hidden = NO;  
  
        SuperFPSView *view = [[SuperFPSView alloc] initWithFrame:frame];  
        [gSuperFPSWindow addSubview:view];  
  
        [gSuperFPSWindow makeKeyAndVisible];  
    });  
}  
  
#pragma mark - Constructor Initializer  
  
__attribute__((constructor))  
static void SuperFPS_Initializer(void) {  
    SuperFPS_ShowOverlay();  
}  
  
// Public C function to trigger overlay manually  
void SuperFPS_Start(void) {  
    SuperFPS_ShowOverlay();  
}  
