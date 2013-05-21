#import "FRTGumView.h"

static CGFloat const ISMaxDistance = 65.f;
static CGFloat const ISMainCircleMaxRadius = 16.f;
static CGFloat const ISMainCircleMinRadius = 10.f;
static CGFloat const ISSubCircleMaxRadius  = 16.f;
static CGFloat const ISSubCircleMinRadius  = 2.f;

@interface FRTGumView ()

@property (nonatomic) CGFloat mainRadius;
@property (nonatomic) CGFloat subRadius;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FRTGumView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, 35.f, 90.f)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.distance = 0.f;
        self.mainRadius = ISMainCircleMaxRadius;
        self.subRadius  = ISMainCircleMaxRadius;
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(0, 0, self.mainRadius*2-12, self.mainRadius*2-12);
        self.imageView.center = CGPointMake(frame.size.width/2.f, self.mainRadius);
        self.imageView.image = [UIImage imageNamed:@"ISRefresgControlIcon"];
        [self addSubview:self.imageView];
        
        [self addObserver:self forKeyPath:@"distance" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"distance"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"distance"]) {
        [self setNeedsDisplay];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.distance < 0) {
        self.distance = 0;
    }
    if (self.distance > ISMaxDistance) {
        self.distance = ISMaxDistance;
    }
    if (self.shrinking) {
        self.mainRadius = ISMainCircleMinRadius*pow((self.distance/ISMaxDistance), 0.1);
        if (self.distance > self.mainRadius) {
            CGFloat diff = fabsf(ISSubCircleMinRadius-self.mainRadius);
            self.subRadius = ISSubCircleMinRadius+diff*(1-(self.distance-self.mainRadius)/(ISMaxDistance-self.mainRadius));
        } else {
            self.subRadius  = self.mainRadius;
        }
    } else {
        self.mainRadius = ISMainCircleMaxRadius-pow(((self.distance)/ISMaxDistance), 1.1)*(ISMainCircleMaxRadius-ISMainCircleMinRadius);
        self.subRadius  = ISSubCircleMaxRadius-pow(((self.distance)/ISMaxDistance), 1.3)*(ISSubCircleMaxRadius-ISSubCircleMinRadius);
    }
    self.imageView.frame = CGRectMake(0, 0, self.mainRadius*2-5, self.mainRadius*2-5);
    self.imageView.center = CGPointMake(self.frame.size.width/2.f, self.mainRadius-2.f + self.distance * 0.03);
    
    // offset to keep center
    CGFloat offset = self.frame.size.width/2.f - self.mainRadius;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, offset, 25);
    CGPathAddArcToPoint(path, NULL,
                        offset, 0,
                        offset + self.mainRadius, 0,
                        self.mainRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        offset + self.mainRadius*2.f, 0,
                        offset + self.mainRadius*2.f, self.mainRadius,
                        self.mainRadius);

    CGPathAddCurveToPoint(path, NULL,
                          offset + self.mainRadius*2.f,            self.mainRadius*2.f,
                          offset + self.mainRadius+self.subRadius, self.mainRadius*2.f,
                          offset + self.mainRadius+self.subRadius, self.distance+self.mainRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        offset + self.mainRadius+self.subRadius, self.distance+self.mainRadius+self.subRadius,
                        offset + self.mainRadius,                self.distance+self.mainRadius+self.subRadius,
                        self.subRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        offset + self.mainRadius-self.subRadius, self.distance+self.mainRadius+self.subRadius,
                        offset + self.mainRadius-self.subRadius, self.distance+self.mainRadius,
                        self.subRadius);
    
    CGPathAddCurveToPoint(path, NULL,
                          offset + self.mainRadius-self.subRadius, self.mainRadius*2.f,
                          offset + 0, self.mainRadius*2.f,
                          offset + 0, self.mainRadius);
    
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    UIColor *color = [UIColor colorWithRed:.607f green:.635f blue:.670f alpha:1.f];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetShadow(context, CGSizeMake(0.f, .5f), 1.f);
    CGContextFillPath(context);
    CGPathRelease(path);
}

- (void)shrink
{
    self.shrinking = YES;
    
    NSInteger count = 10;
    CGFloat delta = self.distance/(CGFloat)count;
    NSTimeInterval duration = .125;
    NSTimeInterval interval = duration/(NSTimeInterval)count;
    [self shrinkWithDelta:delta interval:interval count:count];
}

- (void)shrinkWithDelta:(CGFloat)delta interval:(NSTimeInterval)interval count:(NSInteger)count
{
    if (count <= 0) {
        self.shrinking = NO;
        self.hidden = YES;
        self.alpha = 1.f;
        
        return;
    }
    self.distance -= delta;

    double delayInSeconds = interval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shrinkWithDelta:delta interval:interval count:count-1];
    });
}

@end
