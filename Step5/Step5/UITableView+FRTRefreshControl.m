#import "UITableView+FRTRefreshControl.h"
#import "FRTMethodSwizzling.h"
#import "FRTRefreshControl.h"
#import <objc/runtime.h>

@implementation UITableView (FRTRefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
            FRTSwizzleInstanceMethod([self class], @selector(initWithCoder:), @selector(_initWithCoder:));
        }
    }
}

- (id)_initWithCoder:(NSCoder *)coder
{
    self = [self _initWithCoder:coder];
    if (self) {
        FRTRefreshControl *refreshControl = [coder decodeObjectForKey:@"UIRefreshControl"];
        [self addSubview:refreshControl];
    }
    return self;
}

@end
