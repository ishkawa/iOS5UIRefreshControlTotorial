#import "FRTScalingActivityIndicatorView.h"

@implementation FRTScalingActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if (self) {
        self.color = [UIColor colorWithRed:.607f green:.635f blue:.670f alpha:1.f];
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    }
    return self;
}

- (void)startAnimating
{
    [super startAnimating];
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGAffineTransform rotation = CGAffineTransformMakeRotation(-M_PI_2);
        CGAffineTransform scale = CGAffineTransformMakeScale(0.01f, 0.01f);
        self.transform = CGAffineTransformConcat(rotation, scale);
        
        [UIView animateWithDuration:.2
                         animations:^{
                             self.transform =  CGAffineTransformMakeScale(.8f, 0.8f);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  self.transform = CGAffineTransformMakeScale(.7f, .7f);
                                              }];
                         }];
    });
}

- (void)stopAnimating
{
    [UIView animateWithDuration:.225
                     animations:^{
                         CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI_2);
                         CGAffineTransform scale = CGAffineTransformMakeScale(0.01f, 0.01f);
                         self.transform = CGAffineTransformConcat(rotation, scale);
                     }
                     completion:^(BOOL finished) {
                         [super stopAnimating];
                     }];
}

@end
