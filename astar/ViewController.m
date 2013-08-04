//
//  ViewController.m
//  astar
//
//  Created by Chris on 7/18/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "ViewController.h"
#import "NSDictionary+Pathfinding.h"

@interface ViewController ()

- (IBAction)findNewPath:(id)sender;
- (IBAction)clearOldPath:(id)sender;
- (IBAction)didTapView:(UITapGestureRecognizer*)tapGesture;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
        CGRect screen = [[UIScreen mainScreen] bounds];
        
        if (screen.size.height > 482)
            _mapSize = CGSizeMake(8, 13);
        else
            _mapSize = CGSizeMake(8, 11);
        
        _originRect = CGRectMake(0, 0, 40, 40);
    }
    else
    {
        _mapSize = CGSizeMake(16, 20);
        
        _originRect = CGRectMake(0, 0, 48, 48);
    }
    
    _mapData = [NSMutableDictionary dictionary];
    
    for (NSInteger x = 0; x < _mapSize.width; x++)
        for (NSInteger y = 0; y < _mapSize.height; y++)
            [_mapData setObject:@{ @"state" : @0, }
                         forKey:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark    -   ViewController  -   Private

- (IBAction)findNewPath:(id)sender
{
    NSSet *start = [_mapData keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return  [[obj objectForKey:@"state"] intValue] == 2;
    }];
    
    NSSet *goal = [_mapData keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return  [[obj objectForKey:@"state"] intValue] == 3;
    }];
    
    if(!goal.count || !start.count)
        return;
    
    CGPoint startPoint = [[start anyObject] CGPointValue], goalPoint = [[goal anyObject] CGPointValue];
    
    NSInteger tag = startPoint.x; tag <<= 6; tag += startPoint.y + 6;
    
    __weak UIView *remove = [self.view viewWithTag:tag];
    
    [remove removeFromSuperview];
    
    tag = goalPoint.x; tag <<= 6; tag += goalPoint.y + 6;
    
    remove = [self.view viewWithTag:tag];
    
    [remove removeFromSuperview];
    
    NSArray *path = [_mapData keysForPathFromPoint:startPoint toPoint:goalPoint passingTest:^BOOL(id obj) {
        return [[obj objectForKey:@"state"] integerValue] != 1;
    }];
    
    for (NSValue *key in path)
    {
        CGPoint tile = [key CGPointValue];
        
        [_mapData setObject:@{ @"state" : @3, } forKey:key];
        
        UIView *tileView = [[UIView alloc] initWithFrame:CGRectMake(tile.x * _originRect.size.width,
                                                                    tile.y * _originRect.size.height,
                                                                    _originRect.size.width,
                                                                    _originRect.size.height)];
        
        tileView.backgroundColor = [UIColor yellowColor];
        tileView.tag += tile.x;
        tileView.tag <<= 6;
        tileView.tag += tile.y + 6;
        
        [self.view addSubview:tileView];
    }
}

- (IBAction)clearOldPath:(id)sender
{
    NSSet *previous = [_mapData keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return  [[obj objectForKey:@"state"] integerValue] > 1;
    }];
    
    for (NSValue *key in previous)
    {
        CGPoint tile = [key CGPointValue];
        
        NSInteger tag = tile.x; tag <<= 6; tag += tile.y + 6;
        
        __weak UIView *remove = [self.view viewWithTag:tag];
        
        [remove removeFromSuperview];
        
        [_mapData setObject:@{ @"state" : @0, } forKey:key];
    }
}

- (IBAction)didTapView:(UITapGestureRecognizer*)tapGesture
{
    CGPoint         touchPoint = [tapGesture locationInView:tapGesture.view];
    
    NSInteger       tapX = touchPoint.x / _originRect.size.width,
                    tapY = touchPoint.y / _originRect.size.height;
    
    if (tapX >= _mapSize.width || tapY >= _mapSize.height)
        return;
    
    NSDictionary    *tileDictionary = [_mapData objectForKey:[NSValue valueWithCGPoint:CGPointMake(tapX, tapY)]];
    
    if ( [[tileDictionary objectForKey:@"state"] integerValue] )
    {
        NSUInteger nextState = ( [[[_mapData objectForKey:[NSValue valueWithCGPoint:CGPointMake(tapX, tapY)]] objectForKey:@"state"] integerValue] + 1 ) % 4;
        
        [_mapData setObject:@{ @"state" : [NSNumber numberWithInteger:nextState], } forKey:[NSValue valueWithCGPoint:CGPointMake(tapX, tapY)]];
        
        NSInteger tag = tapX; tag <<= 6; tag += tapY + 6;
        
        switch (nextState)
        {
            case 0:
                {
                    __weak UIView *remove = [self.view viewWithTag:tag];
                    
                    [remove removeFromSuperview];
                }
                break;
            case 2:
                {
                    [[self.view viewWithTag:tag] setBackgroundColor:[UIColor greenColor]];
                }
                break;
            case 3:
                {
                    [[self.view viewWithTag:tag] setBackgroundColor:[UIColor redColor]];
                }
                break;
        }
    }
    else
    {
        [_mapData setObject:@{ @"state" : @1, } forKey:[NSValue valueWithCGPoint:CGPointMake(tapX, tapY)]];
        
        UIView *tileView = [[UIView alloc] initWithFrame:CGRectMake(tapX * _originRect.size.width,
                                                                    tapY * _originRect.size.height,
                                                                    _originRect.size.width,
                                                                    _originRect.size.height)];
        
        tileView.backgroundColor = [UIColor darkGrayColor];
        tileView.tag = ( tapX << 6 ) + tapY + 6;
        
        [tapGesture.view addSubview:tileView];
    }
}

@end
