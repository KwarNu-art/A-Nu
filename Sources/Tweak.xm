#import "KWDialog.h"

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    [KWDialog showIfNeeded];
}

%end

%ctor {
    // Also try after a short delay if SpringBoard hook timing varies
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [KWDialog showIfNeeded];
    });
}
