//
//  NSDictionary+Pathfinding.h
//  astar
//
//  Created by Chris on 7/20/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

@interface NSDictionary ( Pathfinding )

- ( NSArray* )keysForPathFromPoint:( CGPoint )start toPoint:( CGPoint )end passingTest:( BOOL (^)( id obj ) )test;

@end
