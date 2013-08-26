//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "CollectionCell.h"
#import "ImageDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define  kPageSize  8

@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic, assign) NSUInteger pageNumber;
@property (nonatomic, assign) BOOL requestSent;

@end

static success successHandler;

@implementation SearchViewController

-(void) showAlert : (NSString*) message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

-(void) loadPage : (NSUInteger) pageNumber forString : (NSString*) str withSuccess:(success) successHandler{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?rsz=%d&v=1.0&q=%@&start=%d", kPageSize, [str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], pageNumber * kPageSize]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"%@", JSON);
        id results = [JSON valueForKeyPath:@"responseData.results"];
        id cursor = [JSON valueForKeyPath:@"responseData.cursor"];
        if ([results isKindOfClass:[NSArray class]] && [cursor isKindOfClass:[NSDictionary class]]) {
            successHandler(YES, results, cursor, nil);
        }
        self.requestSent = NO;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        successHandler(NO, nil, nil, error);
        self.requestSent = NO;
    }];
    
    [operation start];
    self.requestSent = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
        
        successHandler = ^(BOOL success, NSArray *images, NSDictionary* cursor, NSError *error) {
            if (success){
                [self.imageResults addObjectsFromArray:images];
                [self.collectionView reloadData];
                [self.view endEditing:YES];
            }else{
                [self showAlert:@"Error fetching images from Google. Please try again."];
            }
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionCell"
                                                    bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:@"Cell"];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:0.8f];
    
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin;
}

- (void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    // Remove all images
    [self.imageResults removeAllObjects];
    
    // Load 16 images at first, then load more images on scrolling
    [self loadPage:self.pageNumber
         forString:searchBar.text
       withSuccess:^(BOOL success, NSArray *images, NSDictionary *cursor, NSError *err) {
           successHandler(success, images, cursor, err);
           if (success){
               NSUInteger estimatedResultCount = [[cursor valueForKeyPath:@"estimatedResultCount"] integerValue];
               if (estimatedResultCount > kPageSize){
                   [self loadPage:++self.pageNumber forString:searchBar.text withSuccess:successHandler];
               }
           }
       }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

#pragma mark - CollectionView delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageResults.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CollectionCell * ccell = (CollectionCell*)cell;
    
    // Add the drop shadow etc
    ccell.layer.masksToBounds = NO;
    ccell.layer.shadowOffset = CGSizeMake(0.3, 0.3);
    ccell.layer.shadowRadius = 1;
    ccell.layer.shadowOpacity = 0.3;
    CGPathRef path = [UIBezierPath bezierPathWithRect:ccell.bounds].CGPath;
    [ccell.layer setShadowPath:path];
    // Rsterize for better performance
    ccell.layer.shouldRasterize = YES;
    ccell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Set the border
    ccell.layer.borderWidth = 0.2f;
    ccell.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:0.8].CGColor;
    
    [ccell.imgView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]]
                  placeholderImage:[UIImage imageNamed:@"loading.gif"]];
    
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* imageDetails = self.imageResults[indexPath.row];
    ImageDetailsViewController* imageDetailsVC = [[ImageDetailsViewController alloc] init];
    imageDetailsVC.imageDetails = imageDetails;
    [self.navigationController pushViewController:imageDetailsVC animated:YES];
}

#pragma mark - UIColllectionViewFlowlayoutDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80.0, 80.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20.0;
}


- (void)scrollViewDidScroll: (UIScrollView*)scrollView {
    // UITableView only moves in one direction, y axis
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Load more images as you scroll down
    if ((maximumOffset - currentOffset) <= -10.0 && !self.requestSent) {
        [self loadPage:++self.pageNumber forString:self.searchBar.text withSuccess:successHandler];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

@end
