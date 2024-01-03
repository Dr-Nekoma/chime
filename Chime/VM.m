//
//  VM.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import "Headers/Utilities.h"
#import "Headers/Parser.h" 
#import "Headers/VM+Instructions.h"

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

- (void)Execute:(NSString *)program usingKeywords:(NSString *)keywordSet{
  _memoryRAM = parse(strdup([program UTF8String]), strdup([keywordSet UTF8String]));
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
  while (true) {
    id opcode = [self collectNextInstruction];
    if ([opcode isEqualTo:@(OP_HALT)]) {
      NSLog(@"HALTING");
      NSLog(@"%lu", [[_dataStack peek] integerValue]);
      return;
    } else if ([opcode isEqualTo:@(OP_PUSH_A)]) {
      NSLog(@"PUSHING TO A");
      [self instructionOpPushA];
    } else if ([opcode isEqualTo:@(OP_POP_A)]) {
      NSLog(@"POP TO A");
      [self instructionOpPopA];
    } else if ([opcode isEqualTo:@(OP_PUSH_R)]) {
      NSLog(@"PUSHING TO R");
      [self instructionOpPushR];
    } else if ([opcode isEqualTo:@(OP_POP_R)]) {
      NSLog(@"POP R");
      [self instructionOpPopR];
    } else if ([opcode isEqualTo:@(OP_DUP)]) {
      NSLog(@"DUP");
      [self instructionOpDup];
    } else if ([opcode isEqualTo:@(OP_DROP)]) {
      NSLog(@"DROP");
      [self instructionOpDrop];
    } else if ([opcode isEqualTo:@(OP_OVER)]) {
      NSLog(@"OVER");
      [self instructionOpOver];
    } else if ([opcode isEqualTo:@(OP_PC_FETCH)]) {
      NSLog(@"PC FETCH");
      [self instructionOpPcFetch];
    } else if ([opcode isEqualTo:@(OP_JUMP)]) {
      NSLog(@"JUMPING");
      [self instructionOpJump];
    } else if ([opcode isEqualTo:@(OP_JUMP_ZERO)]) {
      NSLog(@"JUMPING ZERO");
      [self instructionOpJumpZero];
    } else if ([opcode isEqualTo:@(OP_JUMP_PLUS)]) {
      NSLog(@"JUMPING PLUS");
      [self instructionOpJumpPlus];
    } else if ([opcode isEqualTo:@(OP_CALL)]) {
      NSLog(@"CALLING");
      [self instructionOpCall];
    } else if ([opcode isEqualTo:@(OP_RET)]) {
      NSLog(@"RETURNING");
      [self instructionOpRet];
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
