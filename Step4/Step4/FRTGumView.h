#import <UIKit/UIKit.h>

@interface FRTGumView : UIView

@property (nonatomic) BOOL shrinking;
@property (nonatomic) CGFloat distance;

- (void)shrink;

@end
