//
//  VM.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import "Headers/VM.h"
#import "Headers/Utilities.h"

#include <stdlib.h>

@implementation VM

- (VM*)init{
    self = [super init];
    if(self) {
        _dataStack = [Stack new];
        _returnStack = [Stack new];
        _registers = [[NSMapTable alloc] init];
        _memoryRAM = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)clearCode {
    _dataStack = [Stack new];
    _returnStack = [Stack new];
    _registers = [[NSMapTable alloc] init];
    _memoryRAM = [[NSMutableArray alloc] init];
}

- (void)Execute:(NSString *)program {
    OPCODE opcodes[6] = { OP_HALT, OP_HALT, OP_HALT, OP_HALT, OP_HALT, OP_HALT};
    [_memoryRAM addObject:@(packWord(opcodes))];
    [_registers setObject:@0 forKey:@"PC"];
    return [self Evaluate];
}

- (void)Evaluate {
    id opcode;
    while(true){
        if(findInEnumerator([_registers keyEnumerator], @"ISR")){
            uint32_t opcodes = from64To32([[_registers objectForKey:@"ISR"] integerValue]);
            // This is a mask to remove the ending 2 bits of any number
            opcodes &= -8;
            opcode = @(opcodes >> 27);
            opcodes = opcodes << 5;
            [_registers setObject:@(opcodes) forKey:@"ISR"];
        }else{
            opcode = @(OP_PC_FETCH);
        }
        //id opcode = [_dataStack pop];
        if ([opcode isEqualTo:@(OP_HALT)]){
            NSLog(@"HALTING");
            //return;
        }else if ([opcode isEqualTo:@(OP_PUSH_A)]){
            NSLog(@"PUSHING TO A");
            if (findInEnumerator([_registers keyEnumerator], @"A")){
                id valueOfA = [_registers objectForKey:@"A"];
                [_dataStack push:valueOfA];
            }else{
                @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to push value to undefined 'A' register" userInfo:nil];
            }
        }else if ([opcode isEqualTo:@(OP_POP_A)]){
            NSLog(@"POP TO A");
            @try {
                id valueOfA = [_dataStack pop];
                [_registers setObject:valueOfA forKey:@"A"];
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else if ([opcode isEqualTo:@(OP_PUSH_R)]){
            NSLog(@"PUSHING TO R");
            @try {
                id valueOfR = [_dataStack pop];
                [_returnStack push:valueOfR];
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else if ([opcode isEqualTo:@(OP_POP_R)]){
            NSLog(@"POP TO R");
            @try {
                id valueOfR = [_returnStack pop];
                [_dataStack push:valueOfR];
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else if ([opcode isEqualTo:@(OP_DUP)]){
            NSLog(@"DUP");
            @try {
                [_dataStack push:[_dataStack peek]];
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else if ([opcode isEqualTo:@(OP_DROP)]){
            NSLog(@"DROP");
            @try {
                [_dataStack pop];
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else if ([opcode isEqualTo:@(OP_OVER)]){
            NSLog(@"OVER");
            @try {
                id top = [_dataStack pop];
                id second = [_dataStack peek];
                [_dataStack push:top];
                [_dataStack push:second];
            } @catch (NSException *exception) {
                @throw exception;
            }
	}else if ([opcode isEqualTo:@(OP_PC_FETCH)]){
        NSLog(@"PC FETCH");
	    // Each word contains 6 instructions of 5 bits each
	    // PC puts the word into a temporary buffer called ISR
	    if (findInEnumerator([_registers keyEnumerator], @"PC")){
            NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
            @try {
                [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC] forKey:@"ISR"];
                [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
            } @catch (NSException *exception) {
                @throw [NSException exceptionWithName:@"Out of Memory" reason:@"Uh oh... we ran out of memory :(" userInfo:nil];
            }
        }else{
            @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to read value to undefined 'PC' register" userInfo:nil];
        }
    }else if ([opcode isEqualTo:@(OP_JUMP)]){
        NSLog(@"JUMPING");
	    if (findInEnumerator([_registers keyEnumerator], @"PC")){
            NSUInteger valueOfPC = (NSUInteger)[_registers objectForKey:@"PC"];
            [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC] forKey:@"PC"];
        }else{
            @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to read value to undefined 'PC' register" userInfo:nil];
        }
    }else if ([opcode isEqualTo:@(OP_JUMP_ZERO)]){
        NSLog(@"JUMPING ZERO");
	    if (findInEnumerator([_registers keyEnumerator], @"PC")){
            @try {
                id poppedValue = [_dataStack pop];
                NSInteger valueOfPC = (NSInteger)[_registers objectForKey:@"PC"];
                if([poppedValue isEqualTo:@0]){
                    [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC] forKey:@"PC"];
                } else {
                    [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
                }
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else{
            @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to read value to undefined 'PC' register" userInfo:nil];
        }
    }else if ([opcode isEqualTo:@(OP_JUMP_PLUS)]){
        NSLog(@"JUMPING PLUS");
	    if (findInEnumerator([_registers keyEnumerator], @"PC")){
            @try {
                id poppedValue = [_dataStack pop];
                NSUInteger valueOfPC = (NSUInteger)[_registers objectForKey:@"PC"];
                if([poppedValue isGreaterThan:@0]){
                    [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC] forKey:@"PC"];
                } else {
                    [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
                }
            } @catch (NSException *exception) {
                @throw exception;
            }
        }else{
            @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to read value to undefined 'PC' register" userInfo:nil];
        }
    }else if ([opcode isEqualTo:@(OP_CALL)]){
        NSLog(@"CALLING");
	    if (findInEnumerator([_registers keyEnumerator], @"PC")){
            NSUInteger valueOfPC = (NSUInteger)[_registers objectForKey:@"PC"];
            [_returnStack push:@(valueOfPC)];
            [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC] forKey:@"PC"];
        }else{
            @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to read value to undefined 'PC' register" userInfo:nil];
        }
    }else if ([opcode isEqualTo:@(OP_RET)]){
            NSLog(@"RETURNING");
	    if (findInEnumerator([_registers keyEnumerator], @"PC")){
	      @try {
                id poppedValue = [_returnStack pop];
		[_registers setObject:poppedValue forKey:@"PC"];
	      } @catch (NSException *exception) {
                @throw exception;
	      }	
            }else{
                @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to read value to undefined 'PC' register" userInfo:nil];
            }
        }else {
            NSLog(@"DEFAULT");
            return;
        }
    }
}

@end
