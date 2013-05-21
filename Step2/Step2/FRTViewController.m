#import "FRTViewController.h"
#import "FRTRefreshControl.h"

@implementation FRTViewController

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *strings = [NSMutableArray array];
        for (NSInteger index = 0; index < 30; index++) {
            NSString *string = [NSString stringWithFormat:@"cell %d", index];
            [strings addObject:string];
        }
        self.strings = [NSArray arrayWithArray:strings];
    }
    return self;
}

#pragma mark - UIViewController events

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.iOS5RefreshControl = [[FRTRefreshControl alloc] init];
    [self.iOS5RefreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.iOS5RefreshControl];
}

#pragma mark -

- (void)refresh
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.iOS5RefreshControl endRefreshing];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.strings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.strings objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
