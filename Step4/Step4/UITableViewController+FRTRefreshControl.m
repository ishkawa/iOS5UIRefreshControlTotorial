#import "UITableViewController+FRTRefreshControl.h"
#import "FRTRefreshControl.h"
#import "FRTMethodSwizzling.h"
#import <objc/runtime.h>

static const char FRTRefreshControlKey;

@implementation UITableViewController (FRTRefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
            FRTSwizzleInstanceMethod([self class], @selector(refreshControl),     @selector(_refreshControl));
            FRTSwizzleInstanceMethod([self class], @selector(setRefreshControl:), @selector(_setRefreshControl:));
            FRTSwizzleInstanceMethod([self class], @selector(viewDidLoad),        @selector(_viewDidLoad));
        }
    }
}

- (void)_viewDidLoad
{
    [self _viewDidLoad];
    
    if (self.refreshControl) {
        [self.view addSubview:self.refreshControl];
    }
}

- (FRTRefreshControl *)_refreshControl
{
    return objc_getAssociatedObject(self.tableView, &FRTRefreshControlKey);
}

- (void)_setRefreshControl:(FRTRefreshControl *)refreshControl
{
    if (self.isViewLoaded) {
        FRTRefreshControl *oldRefreshControl = objc_getAssociatedObject(self, &FRTRefreshControlKey);
        [oldRefreshControl removeFromSuperview];
        [self.view addSubview:refreshControl];
    }
    
    objc_setAssociatedObject(self.tableView, &FRTRefreshControlKey, refreshControl, OBJC_ASSOCIATION_RETAIN);
}

@end
