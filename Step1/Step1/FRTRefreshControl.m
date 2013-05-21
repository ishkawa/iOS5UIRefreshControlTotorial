#import "FRTRefreshControl.h"

static CGFloat const FRTRefreshControlHeight = 50.f;

@implementation FRTRefreshControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

#pragma mark - UIView events

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)didMoveToSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
        
        self.frame = CGRectMake(0.f, -FRTRefreshControlHeight, self.superview.frame.size.width, FRTRefreshControlHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        [self.superview bringSubviewToFront:self];
        [self keepOnTop];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

- (void)keepOnTop
{
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    CGFloat offset = [(UIScrollView *)self.superview contentOffset].y;
    if (offset < -FRTRefreshControlHeight) {
        self.frame = CGRectMake(0.f, offset, self.frame.size.width, self.frame.size.height);
    } else {
        self.frame = CGRectMake(0.f, -FRTRefreshControlHeight, self.frame.size.width, self.frame.size.height);
    }
}

@end
