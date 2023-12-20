//
//  VM.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import "Headers/VM+Instructions.h"
#import "Headers/Utilities.h">

#include <stdlib.h>

@implementation VM

- (VM *)init {
  self = [super init];
  if (self) {
    _dataStack = [Stack new];
    _returnStack = [Stack new];
    _instructionStack = [Stack new];
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

- (void)printState {
  NSLog(@"Data Stack:");
  [_dataStack printStack];
  NSLog(@"Return Stack:");
  [_returnStack printStack];
  NSLog(@"Instruction Stack:");
  [_instructionStack printStack];
  NSLog(@"Registers' Keys: %@", [[_registers keyEnumerator] allObjects]);
  NSLog(@"Registers' Values: %@", [[_registers objectEnumerator] allObjects]);  
  NSLog(@"RAM: %@", _memoryRAM);   
}

- (void)Execute:(NSString *)program {
/*
 [[call halt pc_fetch]
  3
  [add ret pc_fetch]
  [fetch fetch fetch call jump pc_fetch]
  3
  4
  5
  2
  2
 ]
*/
  OPCODE word0[6] = {OP_CALL, OP_HALT, OP_PC_FETCH, OP_PC_FETCH, OP_PC_FETCH, OP_PC_FETCH};
  OPCODE word2[6] = {OP_PLUS, OP_RET, OP_PC_FETCH, OP_PC_FETCH, OP_PC_FETCH, OP_PC_FETCH};
  OPCODE word3[6] = {OP_LITERAL, OP_LITERAL, OP_LITERAL, OP_CALL, OP_JUMP, OP_PC_FETCH};
  [_memoryRAM addObject:@(packWord(word0))]; // 0
  [_memoryRAM addObject:@3]; // 1
  [_memoryRAM addObject:@(packWord(word2))]; // 2
  [_memoryRAM addObject:@(packWord(word3))]; // 3
  [_memoryRAM addObject:@3]; // 4
  [_memoryRAM addObject:@4]; // 5
  [_memoryRAM addObject:@5]; // 6
  [_memoryRAM addObject:@2]; // 7
  [_memoryRAM addObject:@2]; // 8
  [_registers setObject:@0 forKey:@"PC"];
  return [self Evaluate];
}

- (id)collectNextInstruction {
  id opcode;
  if (findInEnumerator([_registers keyEnumerator], @"ISR")) {
    uint32_t opcodes =
      from64To32([[_registers objectForKey:@"ISR"] integerValue]);
    // This is a mask to remove the ending 2 bits of any number
    opcodes &= -8;
    opcode = @(opcodes >> 27);
    opcodes = opcodes << 5;
    [_registers setObject:@(opcodes) forKey:@"ISR"];
  } else {
    opcode = @(OP_PC_FETCH);
  }
  return opcode;
}

- (void)Evaluate {
  while(true) {
    id opcode = [self collectNextInstruction];
    if ([opcode isEqualTo:@(OP_HALT)]) {
      NSLog(@"HALTING");
      NSLog(@"%lu", [[_dataStack peek] integerValue]);
      return;
    } else if ([opcode isEqualTo:@(OP_PUSH_A)]) {
      NSLog(@"PUSHING TO A");
      if (findInEnumerator([_registers keyEnumerator], @"A")) {
        id valueOfA = [_registers objectForKey:@"A"];
        [_dataStack push:valueOfA];
      } else {
        @throw [NSException
            exceptionWithName:@"Stack Underflow"
                       reason:
                           @"Attempting to push value to undefined 'A' register"
                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_POP_A)]) {
      NSLog(@"POP TO A");
      @try {
        id valueOfA = [_dataStack pop];
        [_registers setObject:valueOfA forKey:@"A"];
      } @catch (NSException *exception) {
        @throw exception;
      }
    } else if ([opcode isEqualTo:@(OP_PUSH_R)]) {
      NSLog(@"PUSHING TO R");
      @try {
        id valueOfR = [_dataStack pop];
        [_instructionStack push:@0];
        [_returnStack push:valueOfR];
      } @catch (NSException *exception) {
        @throw exception;
      }
    } else if ([opcode isEqualTo:@(OP_POP_R)]) {
      NSLog(@"POP R");
      @try {
        id valueOfR = [_returnStack pop];
        [_instructionStack pop];
        [_dataStack push:valueOfR];
      } @catch (NSException *exception) {
        @throw exception;
      }
    } else if ([opcode isEqualTo:@(OP_DUP)]) {
      NSLog(@"DUP");
      @try {
        [_dataStack push:[_dataStack peek]];
      } @catch (NSException *exception) {
        @throw exception;
      }
    } else if ([opcode isEqualTo:@(OP_DROP)]) {
      NSLog(@"DROP");
      @try {
        [_dataStack pop];
      } @catch (NSException *exception) {
        @throw exception;
      }
    } else if ([opcode isEqualTo:@(OP_OVER)]) {
      NSLog(@"OVER");
      @try {
        id top = [_dataStack pop];
        id second = [_dataStack peek];
        [_dataStack push:top];
        [_dataStack push:second];
      } @catch (NSException *exception) {
        @throw exception;
      }
    } else if ([opcode isEqualTo:@(OP_PC_FETCH)]) {
      NSLog(@"PC FETCH");
      // Each word contains 6 instructions of 5 bits each
      // PC puts the word into a temporary buffer called ISR
      if (findInEnumerator([_registers keyEnumerator], @"PC")) {
        NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
        @try {
          [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC]
                         forKey:@"ISR"];
          [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
        } @catch (NSException *exception) {
          @throw
              [NSException exceptionWithName:@"Out of Memory"
                                      reason:@"Uh oh... we ran out of memory :("
                                    userInfo:nil];
        }
      } else {
        @throw [NSException exceptionWithName:@"Stack Underflow"
                                       reason:@"Attempting to read value to "
                                              @"undefined 'PC' register"
                                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_JUMP)]) {
      NSLog(@"JUMPING");
      if (findInEnumerator([_registers keyEnumerator], @"PC")) {
        NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
        [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC]
                       forKey:@"PC"];
      } else {
        @throw [NSException exceptionWithName:@"Stack Underflow"
                                       reason:@"Attempting to read value to "
                                              @"undefined 'PC' register"
                                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_JUMP_ZERO)]) {
      NSLog(@"JUMPING ZERO");
      if (findInEnumerator([_registers keyEnumerator], @"PC")) {
        @try {
          id poppedValue = [_dataStack pop];
          NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
          if ([poppedValue isEqualTo:@0]) {
            [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC]
                           forKey:@"PC"];
          } else {
            [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
          }
        } @catch (NSException *exception) {
          @throw exception;
        }
      } else {
        @throw [NSException exceptionWithName:@"Stack Underflow"
                                       reason:@"Attempting to read value to "
                                              @"undefined 'PC' register"
                                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_JUMP_PLUS)]) {
      NSLog(@"JUMPING PLUS");
      if (findInEnumerator([_registers keyEnumerator], @"PC")) {
        @try {
          id poppedValue = [_dataStack pop];
          NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
          if ([poppedValue isGreaterThan:@0]) {
            [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC]
                           forKey:@"PC"];
          } else {
            [_registers setObject:@(valueOfPC + 1) forKey:@"PC"];
          }
        } @catch (NSException *exception) {
          @throw exception;
        }
      } else {
        @throw [NSException exceptionWithName:@"Stack Underflow"
                                       reason:@"Attempting to read value to "
                                              @"undefined 'PC' register"
                                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_CALL)]) {
      NSLog(@"CALLING");
      if (findInEnumerator([_registers keyEnumerator], @"PC")) {
        NSUInteger valueOfPC = [[_registers objectForKey:@"PC"] integerValue];
        [_returnStack push:@(valueOfPC + 1)];
        [_instructionStack push:[_registers objectForKey:@"ISR"]];
        [_registers setObject:[_memoryRAM objectAtIndex:valueOfPC]
                       forKey:@"PC"];
        [_registers setObject:@0
                       forKey:@"ISR"];	
      } else {
        @throw [NSException exceptionWithName:@"Stack Underflow"
                                       reason:@"Attempting to read value to "
                                              @"undefined 'PC' register"
                                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_RET)]) {
      NSLog(@"RETURNING");
      if (findInEnumerator([_registers keyEnumerator], @"PC")) {
        @try {
          id poppedValue = [_returnStack pop];
          [_registers setObject:[_instructionStack pop] forKey:@"ISR"];
          [_registers setObject:poppedValue forKey:@"PC"];
        } @catch (NSException *exception) {
          @throw exception;
        }
      } else {
        @throw [NSException exceptionWithName:@"Stack Underflow"
                                       reason:@"Attempting to read value to "
                                              @"undefined 'PC' register"
                                     userInfo:nil];
      }
    } else if ([opcode isEqualTo:@(OP_LITERAL)]) {
      NSLog(@"FETCH LITERAL");      
      [self instructionOpLiteral];
    } else if ([opcode isEqualTo:@(OP_LOAD_A)]) {
      NSLog(@"LOAD A");
      [self instructionOpLoadA];
    } else if ([opcode isEqualTo:@(OP_STORE_A)]) {
      NSLog(@"STORE A");      
      [self instructionOpStoreA];
    } else if ([opcode isEqualTo:@(OP_AND)]) {
      NSLog(@"AND");      
      [self instructionOpAnd];
    } else if ([opcode isEqualTo:@(OP_OR)]) {
      NSLog(@"OR");
      [self instructionOpOr];
    } else if ([opcode isEqualTo:@(OP_NOT)]) {
      NSLog(@"NOT");      
      [self instructionOpNot];
    } else if ([opcode isEqualTo:@(OP_XOR)]) {
      NSLog(@"XOR");
      [self instructionOpXor];
    } else if ([opcode isEqualTo:@(OP_PLUS)]) {
      NSLog(@"PLUS");
      [self instructionOpPlus];
    } else if ([opcode isEqualTo:@(OP_DOUBLE)]) {
      NSLog(@"DOUBLE");
      [self instructionOpDouble];
    } else if ([opcode isEqualTo:@(OP_HALF)]) {
      NSLog(@"HALF");
      [self instructionOpHalf];
    } else if ([opcode isEqualTo:@(OP_PLUS_STAR)]) {
      NSLog(@"PLUS STAR");
      [self instructionOpPlusStar];
    } else if ([opcode isEqualTo:@(OP_LOAD_A_PLUS)]) {
      NSLog(@"LOAD A PLUS");      
      [self instructionOpLoadAPlus];
    } else if ([opcode isEqualTo:@(OP_STORE_A_PLUS)]) {
      NSLog(@"STORE A PLUS");      
      [self instructionOpStoreAPlus];
    } else if ([opcode isEqualTo:@(OP_LOAD_R_PLUS)]) {
      NSLog(@"LOAD R PLUS");      
      [self instructionOpLoadRPlus];
    } else if ([opcode isEqualTo:@(OP_STORE_R_PLUS)]) {
      NSLog(@"STORE R PLUS");      
      [self instructionOpStoreRPlus];
    } else if ([opcode isEqualTo:@(OP_NOP)]) {
      NSLog(@"NOP");      
    } else {
      NSLog(@"DEFAULT");
      return;
    }
  }
}

@end
