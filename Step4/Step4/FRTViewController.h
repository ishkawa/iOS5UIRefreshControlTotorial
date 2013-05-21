#import <UIKit/UIKit.h>

@class FRTRefreshControl;

@interface FRTViewController : UITableViewController

@property (nonatomic, strong) NSArray *strings;
@property (nonatomic, strong) FRTRefreshControl *iOS5RefreshControl;

@end
