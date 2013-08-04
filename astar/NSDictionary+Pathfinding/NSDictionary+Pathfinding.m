//
//  NSDictionary+Pathfinding.m
//  astar
//
//  Created by Chris on 7/20/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "NSDictionary+Pathfinding.h"

#define Distance(pointOne, pointTwo) ( 10 * ( abs( pointOne.x - pointTwo.x ) + abs( pointOne.y - pointTwo.y ) ) )

@implementation NSDictionary (Pathfinding)

- (NSArray*)keysForPathFromPoint:(CGPoint)start toPoint:(CGPoint)end passingTest:(BOOL (^)(id obj))test
{
    NSDictionary        *current;
    
    NSMutableDictionary *closed = [NSMutableDictionary dictionary];
    
    NSValue             *empty = [NSValue valueWithCGPoint:CGPointMake(99, 99)];
    
    NSMutableArray      *open = [NSMutableArray arrayWithObject:@{  @"distance" : [NSNumber numberWithInt:Distance(start,end)],
                                                                    @"point" : [NSValue valueWithCGPoint:start],
                                                                    @"previous" : empty,
                                                                    @"walk" : @0, }];
    
    while (open.count)
    {
        current = open.lastObject;
        
        if ( CGPointEqualToPoint(end, [[current objectForKey:@"point"] CGPointValue]) )
        {
            NSMutableArray *path = [NSMutableArray array];
            
            while ( ![empty isEqualToValue:[current objectForKey:@"previous"]] )
            {
                [path addObject:[current objectForKey:@"point"]];
                
                current = [closed objectForKey:[current objectForKey:@"previous"]];
            }
            
            [path addObject:[current objectForKey:@"point"]];
            
            return [[path reverseObjectEnumerator] allObjects];
        }
        
        CGPoint currentPoint = [[current objectForKey:@"point"] CGPointValue];
        
        [closed setObject:current forKey:[current objectForKey:@"point"]];
        [open removeLastObject];
        
        NSMutableArray *nearestNeighbors = [NSMutableArray array];
        
        id neighbor = [self objectForKey:[NSValue valueWithCGPoint:CGPointMake(currentPoint.x - 1, currentPoint.y)]];
        
        if( neighbor && test( neighbor ) )
            [nearestNeighbors addObject:@{  @"previous" : [current objectForKey:@"point"],
                                            @"walk" : [NSNumber numberWithInt:[[current objectForKey:@"walk"] intValue] + 10],
                                            @"point" : [NSValue valueWithCGPoint:CGPointMake(currentPoint.x - 1, currentPoint.y)],
                                            @"distance" : [NSNumber numberWithInt:Distance(CGPointMake(currentPoint.x - 1, currentPoint.y),end)], }];
        
        neighbor = [self objectForKey:[NSValue valueWithCGPoint:CGPointMake(currentPoint.x, currentPoint.y - 1)]];
        
        if( neighbor && test( neighbor ) )
            [nearestNeighbors addObject:@{  @"previous" : [current objectForKey:@"point"],
                                            @"walk" : [NSNumber numberWithInt:[[current objectForKey:@"walk"] intValue] + 10],
                                            @"point" : [NSValue valueWithCGPoint:CGPointMake(currentPoint.x, currentPoint.y - 1)],
                                            @"distance" : [NSNumber numberWithInt:Distance(CGPointMake(currentPoint.x, currentPoint.y - 1),end)], }];
        
        neighbor = [self objectForKey:[NSValue valueWithCGPoint:CGPointMake(currentPoint.x + 1, currentPoint.y)]];
        
        if( neighbor && test( neighbor ) )
            [nearestNeighbors addObject:@{  @"previous" : [current objectForKey:@"point"],
                                            @"walk" : [NSNumber numberWithInt:[[current objectForKey:@"walk"] intValue] + 10],
                                            @"point" : [NSValue valueWithCGPoint:CGPointMake(currentPoint.x + 1, currentPoint.y)],
                                            @"distance" : [NSNumber numberWithInt:Distance(CGPointMake(currentPoint.x + 1, currentPoint.y),end)], }];
        
        neighbor = [self objectForKey:[NSValue valueWithCGPoint:CGPointMake(currentPoint.x, currentPoint.y + 1)]];
        
        if( neighbor && test( neighbor ) )
            [nearestNeighbors addObject:@{  @"previous" : [current objectForKey:@"point"],
                                            @"walk" : [NSNumber numberWithInt:[[current objectForKey:@"walk"] intValue] + 10],
                                            @"point" : [NSValue valueWithCGPoint:CGPointMake(currentPoint.x, currentPoint.y + 1)],
                                            @"distance" : [NSNumber numberWithInt:Distance(CGPointMake(currentPoint.x, currentPoint.y + 1),end)], }];
        
        for (neighbor in nearestNeighbors)
        {
            NSDictionary *exists = [closed objectForKey:[neighbor objectForKey:@"point"]];
            
            if(exists && [[neighbor objectForKey:@"walk"] intValue] >= [[exists objectForKey:@"walk"] intValue])
                continue;
            
            NSUInteger index = [open indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [[neighbor objectForKey:@"point"] isEqualToValue:[obj objectForKey:@"point"]];
            }];
            
            if(index == NSNotFound)
            {
                [open addObject:neighbor];
            }
            else if( [[neighbor objectForKey:@"walk"] intValue] < [[[open objectAtIndex:index] objectForKey:@"walk"] intValue] )
            {
                [open replaceObjectAtIndex:index withObject:neighbor];
            }
        }
        
        open = [NSMutableArray arrayWithArray:[open sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return  ( [[a objectForKey:@"walk"] intValue] + [[a objectForKey:@"distance"] intValue] ) <
                    ( [[b objectForKey:@"walk"] intValue] + [[b objectForKey:@"distance"] intValue] );
        }]];
    }
    
    return nil;
}

@end
