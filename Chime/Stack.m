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

- (void)push:(OPCODE)opcode {
    [_arr addObject:@(opcode)];
    _size++;
    return;
}

- (OPCODE)pop{
    if(_size == 0)
        @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Stack is empty, cannot pop." userInfo:nil];
    OPCODE opcode = (OPCODE)_arr[_size - 1];
    _size--;
    //(OPCODE)[_arr objectAtIndex:(--_size)];
    [_arr removeLastObject];
    return opcode;
}

- (OPCODE)peek{
    if(_size == 0)
        @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Stack is empty, cannot pop." userInfo:nil];
    
    return (OPCODE)[_arr objectAtIndex:(_size - 1)];
    
}

- (bool)isEmpty{
    return _size == 0;
}

@end
