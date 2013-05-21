#import "FRTAppDelegate.h"
#import "FRTViewController.h"

@implementation FRTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[FRTViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
