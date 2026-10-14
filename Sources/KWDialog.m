#import "KWDialog.h"
#import <objc/runtime.h>

@implementation KWDialog

+ (void)showIfNeeded {
    static BOOL presented = NO;
    if (presented) return;
    presented = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self present];
    });
}

+ (void)present {
    UIWindow *key = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *w in scene.windows) {
                if (w.isKeyWindow) { key = w; break; }
            }
            if (key) break;
        }
    }
    if (!key) key = UIApplication.sharedApplication.keyWindow;
    if (!key) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (w.windowLevel == UIWindowLevelNormal) { key = w; break; }
        }
    }
    if (!key) return;

    CGRect bounds = key.bounds;

    UIWindow *overlay = [[UIWindow alloc] initWithFrame:bounds];
    overlay.windowLevel = UIWindowLevelAlert + 10;
    overlay.backgroundColor = UIColor.clearColor;
    overlay.hidden = NO;
    UIViewController *root = [UIViewController new];
    root.view.backgroundColor = UIColor.clearColor;
    overlay.rootViewController = root;

    UIView *dim = [[UIView alloc] initWithFrame:bounds];
    dim.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
    dim.alpha = 0;
    [root.view addSubview:dim];

    CGFloat cardW = MIN(bounds.size.width - 48.0, 340.0);
    CGFloat cardH = 228.0;
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardW, cardH)];
    card.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    card.backgroundColor = [UIColor colorWithRed:0.09 green:0.10 blue:0.13 alpha:0.97];
    card.layer.cornerRadius = 20.0;
    card.layer.masksToBounds = YES;
    if (@available(iOS 13.0, *)) {
        card.layer.cornerCurve = kCACornerCurveContinuous;
    }
    card.layer.borderWidth = 1.0;
    card.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08].CGColor;
    card.transform = CGAffineTransformMakeScale(0.86, 0.86);
    card.alpha = 0;
    [root.view addSubview:card];

    UIView *accent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardW, 4)];
    accent.backgroundColor = [UIColor colorWithRed:0.45 green:0.75 blue:1.0 alpha:1.0];
    [card addSubview:accent];

    UILabel *hello = [[UILabel alloc] initWithFrame:CGRectMake(20, 28, cardW - 40, 34)];
    hello.text = @"Welcome";
    hello.textAlignment = NSTextAlignmentCenter;
    hello.textColor = UIColor.whiteColor;
    hello.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    [card addSubview:hello];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(20, 68, cardW - 40, 28)];
    sub.text = @"Hello — glad you're here.";
    sub.textAlignment = NSTextAlignmentCenter;
    sub.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.78];
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [card addSubview:sub];

    UILabel *credit = [[UILabel alloc] initWithFrame:CGRectMake(20, 108, cardW - 40, 44)];
    credit.text = @"Crafted with care by\nKwar Nu";
    credit.numberOfLines = 2;
    credit.textAlignment = NSTextAlignmentCenter;
    credit.textColor = [UIColor colorWithRed:0.55 green:0.82 blue:1.0 alpha:1.0];
    credit.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [card addSubview:credit];

    UIButton *ok = [UIButton buttonWithType:UIButtonTypeCustom];
    ok.frame = CGRectMake(24, cardH - 56, cardW - 48, 40);
    ok.backgroundColor = [UIColor colorWithRed:0.30 green:0.55 blue:0.98 alpha:1.0];
    ok.layer.cornerRadius = 12.0;
    [ok setTitle:@"Continue" forState:UIControlStateNormal];
    [ok setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    ok.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [ok addTarget:self action:@selector(onContinue:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:ok];

    static UIWindow *sOverlay;
    sOverlay = overlay;

    void (^dismiss)(void) = ^{
        [UIView animateWithDuration:0.22 animations:^{
            dim.alpha = 0;
            card.alpha = 0;
            card.transform = CGAffineTransformMakeScale(0.90, 0.90);
        } completion:^(BOOL finished) {
            sOverlay.hidden = YES;
            sOverlay = nil;
        }];
    };
    objc_setAssociatedObject(self, "kw_dismiss_block", dismiss, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [UIView animateWithDuration:0.38 delay:0 usingSpringWithDamping:0.82 initialSpringVelocity:0.55 options:0 animations:^{
        dim.alpha = 1;
        card.alpha = 1;
        card.transform = CGAffineTransformIdentity;
    } completion:nil];
}

+ (void)onContinue:(UIButton *)sender {
    void (^dismiss)(void) = objc_getAssociatedObject(self, "kw_dismiss_block");
    if (dismiss) dismiss();
}

@end
