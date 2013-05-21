#import "FRTRefreshControl.h"
#import "FRTGumView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const FRTRefreshControlHeight = 45.f;
static CGFloat const FRTRefreshControlThreshold = -110.f;

typedef NS_ENUM(NSInteger, FRTRefreshControlState) {
    FRTRefreshControlStateNormal,
    FRTRefreshControlStateRefreshing,
    FRTRefreshControlStateRefreshed,
};

@interface FRTRefreshControl ()

@property (nonatomic) FRTRefreshControlState refreshControlState;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) FRTGumView *gumView;

@end

@implementation FRTRefreshControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gumView = [[FRTGumView alloc] init];
        [self addSubview:self.gumView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] init];
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.indicatorView.color = [UIColor lightGrayColor];
        [self.indicatorView.layer setValue:@.7f forKeyPath:@"transform.scale"];
        [self addSubview:self.indicatorView];
    }
    return self;
}

#pragma mark - accessors

- (BOOL)isRefreshing
{
    return self.refreshControlState == FRTRefreshControlStateRefreshing;
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
        self.indicatorView.center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
        self.gumView.center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height + 7.5f);
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        [self.superview bringSubviewToFront:self];
        [self keepOnTop];
        [self updateRefreshControlState];
        [self sendDistanceToGumView];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - contentOffset actions

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

- (void)sendDistanceToGumView
{
    if (![self.superview isKindOfClass:[UIScrollView class]] || self.gumView.shrinking) {
        return;
    }
    
    CGFloat offset = [(UIScrollView *)self.superview contentOffset].y;
    self.gumView.distance = offset < -FRTRefreshControlHeight ? -offset-FRTRefreshControlHeight : 0.f;
}

- (void)updateRefreshControlState
{
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    CGFloat offset = [scrollView contentOffset].y;
    
    switch (self.refreshControlState) {
        case FRTRefreshControlStateNormal:
            if (offset < FRTRefreshControlThreshold) {
                [self beginRefreshing];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            break;
            
        case FRTRefreshControlStateRefreshed:
            if (offset >= 0.f && !scrollView.isTracking) {
                [self resetRefreshControlState];
            }
            break;
            
        default: break;
    }
}

#pragma mark - refreshControlState transitions

// FRTRefreshControlStateNormal -> FRTRefreshControlStateRefreshing,
- (void)beginRefreshing
{
    if (self.isRefreshing) {
        return;
    }
    
    self.refreshControlState = FRTRefreshControlStateRefreshing;
    [self.indicatorView startAnimating];
    [self.gumView shrink];
    
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top += FRTRefreshControlHeight;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }];
}

// FRTRefreshControlStateRefreshing -> FRTRefreshControlStateRefreshed,
- (void)endRefreshing
{
    if (!self.isRefreshing) {
        return;
    }
    
    UIScrollView *scrollView = (id)self.superview;
    CGFloat offset = scrollView.contentOffset.y;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top -= FRTRefreshControlHeight;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         if (offset < -FRTRefreshControlHeight) {
                             self.refreshControlState = FRTRefreshControlStateRefreshed;
                         } else {
                             [self resetRefreshControlState];
                         }
                         [self.indicatorView stopAnimating];
                     }];
}

// FRTRefreshControlStateRefreshed -> FRTRefreshControlStateNormal
- (void)resetRefreshControlState
{
    self.refreshControlState = FRTRefreshControlStateNormal;
    self.gumView.hidden = NO;
}

@end
