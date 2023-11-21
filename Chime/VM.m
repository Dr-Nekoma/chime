//
//  VM.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import "VM.h"

@implementation VM

- (VM*)init{
    self = [super init];
    if(self) {
        _stack = [Stack new];
    }
    return self;
}

- (void)clearCode {
    _stack = [Stack new];
}

- (void)Execute:(NSString *)program {
    // Missing steps:
    // Get the AST from the program
    // Compile the program to bytecode
    
    [_stack push:OP_HALT];
    return [self Evaluate];
}

- (void)Evaluate {
    while(![_stack isEmpty]){
        id opcode = [_stack pop];
        if ([opcode isEqualTo:@(OP_HALT)]){
            NSLog(@"HALTING");
            return;
        }else if ([opcode isEqualTo:@(OP_ADD)]){
            NSLog(@"ADDING");
            return;
        } else {
            NSLog(@"DEFAULT");
            return;
        }
    }
}

@end
