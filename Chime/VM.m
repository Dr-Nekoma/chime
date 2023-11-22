//
//  VM.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import "VM.h"
#import "Utilities.h"

@implementation VM

- (VM*)init{
    self = [super init];
    if(self) {
        _dataStack = [Stack new];
        _returnStack = [Stack new];
        _registers = [[NSMapTable alloc] init];
        //[_registers setObject:0 forKey:@"A"];
    }
    return self;
}

- (void)clearCode {
    _dataStack = [Stack new];
}

- (void)Execute:(NSString *)program {
    [_dataStack push:@(OP_HALT)];
    return [self Evaluate];
}

- (void)Evaluate {
    while(![_dataStack isEmpty]){
        id opcode = [_dataStack pop];
        if ([opcode isEqualTo:@(OP_HALT)]){
            NSLog(@"HALTING");
            return;
        }else if ([opcode isEqualTo:@(OP_PUSH_A)]){
            NSLog(@"PUSHING TO A");
            if (findInEnumerator([_registers keyEnumerator], @"A")){
                id valueOfA = [_registers objectForKey:@"A"];
                [_dataStack push:valueOfA];
            }else{
                @throw [NSException exceptionWithName:@"Stack Underflow" reason:@"Attempting to push value to undefined 'A' register" userInfo:nil];
            }
        }else if ([opcode isEqualTo:@(OP_POP_A)]){
            NSLog(@"POP TO B");
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
        } else if ([opcode isEqualTo:@(OP_DROP)]){
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
        }else {
            NSLog(@"DEFAULT");
            return;
        }
    }
}

@end
