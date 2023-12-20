#include "Headers/Instructions.h"
#import <Foundation/Foundation.h>

void instruction_op_fetch(NSMapTable* _registers, Stack *_dataStack, NSMutableArray *_ram){
    NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
    NSInteger value = [[_ram objectAtIndex:valueOfPC] integerValue];
    [_dataStack push:@(value)];
    [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
    return;
}

void instruction_op_load_a(NSMapTable* _registers, Stack *_dataStack, NSMutableArray *_ram){
    NSUInteger valueOfA = [[_registers objectForKey:@"A"] integerValue];
    NSInteger value = [[_ram objectAtIndex:valueOfA] integerValue];
    [_dataStack push:@(value)];
    return;
}

void instruction_op_store_a(NSMapTable* _registers, Stack *_dataStack, NSMutableArray *_ram){
    NSUInteger valueOfA = [[_registers objectForKey:@"A"] integerValue];
    id value = [_dataStack pop];
    [_ram setObject:value atIndexedSubscript:valueOfA];
    return;
}

void instruction_op_and(Stack *_dataStack){
    NSInteger value1 = [[_dataStack pop] integerValue];
    NSInteger value2 = [[_dataStack pop] integerValue];
    [_dataStack push:@(value1 & value2)];
    return;
}

void instruction_op_or(Stack *_dataStack){ 
      NSInteger value1 = [[_dataStack pop] integerValue];
    NSInteger value2 = [[_dataStack pop] integerValue];
    [_dataStack push:@(value1 | value2)];
    return;
}

void instruction_op_not(Stack *_dataStack){ NSInteger value = [[_dataStack pop] integerValue];
    [_dataStack push:@(!value)];
    return;
}

void instruction_op_xor(Stack *_dataStack){
    NSInteger value1 = [[_dataStack pop] integerValue];
    NSInteger value2 = [[_dataStack pop] integerValue];
    [_dataStack push:@(value1 ^ value2)];
    return;
}

void instruction_op_plus(Stack *_dataStack){
    NSInteger value1 = [[_dataStack pop] integerValue];
    NSInteger value2 = [[_dataStack pop] integerValue];
    [_dataStack push:@(value1 + value2)];
    return;
}

void instruction_op_double(Stack *_dataStack){
    NSInteger value = [[_dataStack pop] integerValue];
    [_dataStack push:@(value << 1)];
    return;
}

void instruction_op_half(Stack *_dataStack){
    NSInteger value = [[_dataStack pop] integerValue];
    [_dataStack push:@(value >> 1)];
    return;
}

void instruction_op_plus_star(Stack *_dataStack){
    NSInteger value1 = [[_dataStack pop] integerValue];
    NSInteger value2 = [[_dataStack peek] integerValue];
    if (value1 % 2 == 1){
        [_dataStack push:@(value1 + value2)];
    } else {
        [_dataStack push:@(value1)];
    }
    
    return;
}

void instruction_op_load_a_plus(NSMapTable* _registers, Stack* _dataStack, NSMutableArray* _ram){
    NSUInteger valueOfA = [[_registers objectForKey:@"A"] integerValue];
    NSInteger value = [[_ram objectAtIndex:valueOfA] integerValue];
    [_registers setObject:@(valueOfA + 1) forKey:@"A"];
    [_dataStack push:@(value)];
    return;
}

void instruction_op_store_a_plus(NSMapTable* _registers, Stack* _dataStack, NSMutableArray* _ram){
    NSUInteger valueOfA = [[_registers objectForKey:@"A"] integerValue];
    id value = [_dataStack pop];
    [_registers setObject:@(valueOfA + 1) forKey:@"A"];
    [_ram setObject:value atIndexedSubscript:valueOfA];
    return;
}

void instruction_op_load_r_plus(Stack* _returnStack, Stack* _dataStack, NSMutableArray* _ram){
    NSUInteger valueOfR = [[_returnStack pop] integerValue];
    NSInteger value = [[_ram objectAtIndex:valueOfR] integerValue];
    [_returnStack push:@(valueOfR + 1)];
    [_dataStack push:@(value)];
    return;
}

void instruction_op_store_r_plus(Stack* _returnStack, Stack* _dataStack, NSMutableArray* _ram){
    NSUInteger valueOfR = [[_returnStack pop] integerValue];
    id value = [_dataStack pop];
    [_returnStack push:@(valueOfR + 1)];
    [_ram setObject:value atIndexedSubscript:valueOfR];
    return;
}
