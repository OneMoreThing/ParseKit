//
//  PFQueryTableViewController.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFQueryTableViewController.m"

// Macros
#define DKSynthesize(x) @synthesize x = x##_;


@interface PFQueryTableViewController ()
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, strong, readwrite) NSMutableArray *objects;
@property (nonatomic, strong, readwrite) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchOverlay;
@property (nonatomic, assign) BOOL searchTextChanged;
@end

@interface PFQueryTableNextPageCell : PFTableViewCell
@property (nonatomic, strong) UIActivityIndicatorView *activityAccessoryView;
@end


@implementation PFQueryTableViewController 

@synthesize pullToRefreshView;

-(NSString*) className{
    return self.entityName;
}
-(void) setClassName:(NSString *)className_{
    self.entityName = className_;
}

- (id)initWithStyle:(UITableViewStyle)otherStyle{
    return [self initWithStyle:otherStyle entityName:@""];
}

- (void)objectsDidLoad:(NSError *)error{
    //[self queryTableDidReload];
}

- (PFQuery *)queryForTable{
    DKQuery *q = [DKQuery queryWithEntityName:self.entityName];
    [q orderDescendingByCreationDate];
    PFQuery* pfQuery =[PFQuery queryWithClassName:self.entityName];
    pfQuery.dkQuery = q;
    return pfQuery;
}

- (void)loadObjects{
    if(self.pullToRefreshEnabled)
        [self.pullToRefreshView startLoadingAndExpand:YES];
    [self reloadInBackground];
}

- (void)loadNextPage{
    if (self.isLoading) {
        return;
    }
    [self appendNextPageWithFinishCallback:^(NSError *error){
    }];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self reloadInBackgroundWithBlock:^(NSError *error) {
        if(self.pullToRefreshEnabled)
            self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
        else
            self.pullToRefreshView = nil;
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.pullToRefreshView = nil;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object{

    
    if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
        return [self tableViewNextPageCell:tableView];
    }
    
    static NSString *identifier = @"PFObjectTableCell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.displayedTitleKey.length > 0) {
        // DKEntity and NSDictionary both implement objectForKey
        cell.textLabel.text = [object objectForKey:self.displayedTitleKey];
    }
    if (self.displayedImageKey.length > 0) {
        // DKEntity and NSDictionary both implement objectForKey
        cell.imageView.image = [UIImage imageWithData:[object objectForKey:self.displayedImageKey]];
    }
    
    return cell;
    
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath{
    return [self.objects objectAtIndex:indexPath.row];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
        [self loadObjects];
}

//DKQueryTableViewController implementation
//
//  DKQueryTableViewController.m
//  DataKit
//
//  Created by Erik Aigner on 05.03.12.
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

DKSynthesize(entityName)
DKSynthesize(displayedTitleKey)
DKSynthesize(displayedImageKey)
DKSynthesize(objectsPerPage)
DKSynthesize(isLoading)
DKSynthesize(objects)
DKSynthesize(searchBar)
DKSynthesize(searchOverlay)
DKSynthesize(searchTextChanged)
DKSynthesize(hasMore)
DKSynthesize(currentOffset)

- (id)initWithEntityName:(NSString *)entityName {
    return [self initWithStyle:UITableViewStylePlain entityName:entityName];
}

- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName {
    self = [super initWithStyle:style];
    if (self) {
        self.objectsPerPage = 25;
        self.currentOffset = 0;
        self.entityName = entityName;
        self.objects = [NSMutableArray new];
        
        // Search bar
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.searchBar.delegate = (id)self;
        self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
        
        // Search overlay
        self.searchOverlay = [UIButton buttonWithType:UIButtonTypeCustom];
        self.searchOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        
        [self.searchOverlay addTarget:self action:@selector(dismissOverlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)processQueryResults:(NSArray *)results error:(NSError *)error callback:(void (^)(NSError *error))callback {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"query results not processed on main queue");
    
    if (results != nil && ![results isKindOfClass:[NSArray class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:NSLocalizedString(@"Query did not return a result NSArray or nil", nil)];
        return;
    } else if ([results isKindOfClass:[NSArray class]]) {
        for (id object in results) {
            if (!([object isKindOfClass:[PFObject class]] || [object isKindOfClass:[NSDictionary class]])) {
                [NSException raise:NSInternalInconsistencyException
                            format:NSLocalizedString(@"Query results contained invalid objects", nil)];
                return;
            }
        }
    }
    
    if (results.count > 0) {
        [self.objects addObjectsFromArray:results];
    }
    
    self.currentOffset += results.count;
    self.hasMore = (results.count == self.objectsPerPage);
    self.isLoading = NO;
    self.tableView.userInteractionEnabled = YES;
    
    if (error != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
    
    // Post process results
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self postProcessResults];
        
        dispatch_async(q, ^{
            [self queryTableWillReload];
            [self.tableView reloadData];
            [self queryTableDidReload];
            
            if (callback != NULL) {
                callback(error);
            }
        });
    });
}

- (void)appendNextPageWithFinishCallback:(void (^)(NSError *error))callback {
    callback = [callback copy];
    
    self.isLoading = YES;
    self.tableView.userInteractionEnabled = NO;
    
    PFQuery *q = nil;
    DKQuery *qk = nil;
    NSString *queryText = self.searchBar.text;
    
    // Form search query for text if possible
    if ([self hasSearchBar] && queryText.length > 0) {
        q = [self tableQueryForSearchText:self.searchBar.text];
    }
    
    // Otherwise use default query
    if (q == nil) {
        q = [self queryForTable];
        qk = q.dkQuery;
    }
    
    NSAssert(q != nil, @"query cannot be nil");
    
    qk.skip = self.currentOffset;
    qk.limit = self.objectsPerPage;
    
    q.dkQuery = qk;
    DKMapReduce *mr = [self tableQueryMapReduce];
    if (mr != nil) {
        [q performMapReduce:mr inBackgroundWithBlock:^(id result, NSError *error) {
            [self processQueryResults:result error:error callback:callback];
        }];
    }
    else {
        [q findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            [self processQueryResults:results error:error callback:callback];
        }];
    }
}

- (void)reloadInBackground {
    [self reloadInBackgroundWithBlock:NULL];
}

- (void)reloadInBackgroundWithBlock:(void (^)(NSError *))block {
    // Display search bar if necessary
    if ([self hasSearchBar]) {
        self.tableView.tableHeaderView = self.searchBar;
    } else {
        [self.searchOverlay removeFromSuperview];
        self.tableView.tableHeaderView = nil;
    }
    
    self.hasMore = NO;
    self.currentOffset = 0;
    
    [self.objects removeAllObjects];
    [self.tableView reloadData];
    
    [self appendNextPageWithFinishCallback:block];
}

- (void)reloadInBackgroundIfSearchTextChanged {
    if (self.searchTextChanged) {
        self.searchTextChanged = NO;
        [self reloadInBackground];
    }
}

- (void)queryTableWillReload {
    [self.pullToRefreshView startLoading];
}

- (void)queryTableDidReload {
    [self.pullToRefreshView finishLoading];
}

- (void)postProcessResults {
    // stub
    [self objectsDidLoad:nil];
}

//- (DKQuery *)tableQuery {
//    DKQuery *q = [DKQuery queryWithEntityName:self.entityName];
//    [q orderDescendingByCreationDate];
    
//    return q;
//}

- (DKMapReduce *)tableQueryMapReduce {
    return nil;
}

- (BOOL)hasSearchBar {
    return NO;
}

- (PFQuery *)tableQueryForSearchText:(NSString *)text {
    return nil;
}

- (void)loadNextPageWithNextPageCell:(PFQueryTableNextPageCell *)cell {
    if (self.isLoading) {
        return;
    }
    [cell.activityAccessoryView startAnimating];
    [cell setNeedsLayout];
    
    [self appendNextPageWithFinishCallback:^(NSError *error){
        [cell.activityAccessoryView stopAnimating];
        [cell setNeedsLayout];
    }];
}

#pragma mark UITableViewDelegate & Related

- (BOOL)tableViewCellIsNextPageCellAtIndexPath:(NSIndexPath *)indexPath {
    return (self.hasMore && (indexPath.row == self.objects.count));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count + (self.hasMore ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    return [self tableView: tableView cellForRowAtIndexPath:indexPath object:object];
}


- (PFTableViewCell *)tableViewNextPageCell:(UITableView *)tableView {
    static NSString *identifier = @"PFQueryTableNextPageCell";
    PFQueryTableNextPageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PFQueryTableNextPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i more ...", nil), self.objectsPerPage];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
        PFQueryTableNextPageCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
        [self loadNextPageWithNextPageCell:cell];
    }
    else {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath object:[self.objects objectAtIndex:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
    // stub
}

#pragma mark UISearchBarDelegate & Overlay

- (void)dismissOverlay:(UIButton *)sender {
    [sender removeFromSuperview];
    [self.searchBar resignFirstResponder];
    [self reloadInBackgroundIfSearchTextChanged];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchOverlay removeFromSuperview];
    [self.searchBar resignFirstResponder];
    [self reloadInBackgroundIfSearchTextChanged];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    CGRect bounds = self.tableView.bounds;
    CGRect barBounds = self.searchBar.bounds;
    CGRect overlayFrame = CGRectMake(CGRectGetMinX(bounds),
                                     CGRectGetMaxY(barBounds),
                                     CGRectGetWidth(barBounds),
                                     CGRectGetHeight(bounds) - CGRectGetHeight(barBounds));
    
    self.searchOverlay.frame = overlayFrame;
    
    [self.tableView addSubview:self.searchOverlay];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchTextChanged = YES;
}

@end



@implementation PFQueryTableNextPageCell
DKSynthesize(activityAccessoryView)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIActivityIndicatorView *accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        accessoryView.hidesWhenStopped = YES;
        
        self.activityAccessoryView = accessoryView;
        
        [self.contentView addSubview:self.activityAccessoryView];
        
        self.textLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        self.textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Center text label
    UIFont *font = self.textLabel.font;
    NSString *text = self.textLabel.text;
    
    CGRect bounds = self.bounds;
    CGSize textSize = [text sizeWithFont:font
                                forWidth:CGRectGetWidth(bounds)
                           lineBreakMode:UILineBreakModeTailTruncation];
    CGSize spinnerSize = self.activityAccessoryView.frame.size;
    CGFloat padding = 10.0;
    
    BOOL isAnimating = self.activityAccessoryView.isAnimating;
    
    CGRect textFrame = CGRectMake((CGRectGetWidth(bounds) - textSize.width - (isAnimating ? spinnerSize.width - padding : 0)) / 2.0,
                                  (CGRectGetHeight(bounds) - textSize.height) / 2.0,
                                  textSize.width,
                                  textSize.height);
    
    self.textLabel.frame = CGRectIntegral(textFrame);
    
    if (isAnimating) {
        CGRect spinnerFrame = CGRectMake(CGRectGetMaxX(textFrame) + padding,
                                         (CGRectGetHeight(bounds) - spinnerSize.height) / 2.0,
                                         spinnerSize.width,
                                         spinnerSize.height);
        
        self.activityAccessoryView.frame = spinnerFrame;
    }
}

@end
