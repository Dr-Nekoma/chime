//
//  Stack.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import <Foundation/Foundation.h>

#import "Stack.h"

@implementation Stack

- (Stack*) init {
    self = [super init];
    if(self) {
        _size = 0;
        _arr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)push:(id)elem {
    [_arr addObject:elem];
    _size++;
    return;
}

- (id)pop{
    if(_size == 0)
        @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Stack is empty, cannot pop." userInfo:nil];
    id elem = [_arr objectAtIndex:(_size - 1)];
    _size--;
    [_arr removeLastObject];
    return elem;
}

- (id)peek{
    if(_size == 0)
        @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Stack is empty, cannot peek." userInfo:nil];
    
    return [_arr objectAtIndex:(_size - 1)];
}

- (bool)isEmpty{
    return _size == 0;
}

@end
