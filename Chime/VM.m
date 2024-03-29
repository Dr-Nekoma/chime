//
//  VM.m
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#import "Headers/Parser.h"
#import "Headers/Utilities.h"
#import "Headers/VM+Instructions.h"
#import "Headers/VM+Syscalls.h"

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

- (void)prepareRegisters {
  [_registers setObject:@0 forKey:@"PC"];
  [_registers setObject:@0 forKey:@"A"];
}

- (void)LoadProgram:(NSString *)program usingKeywords:(NSString *)keywordSet {
  Parser *parser = [Parser new];
  _memoryRAM = [parser ParseProgram:strdup([program UTF8String])
                      usingKeywords:strdup([keywordSet UTF8String])];
  [self prepareRegisters];
  return;
}

- (void)SaveProgram:(NSString *)filepath {
  NSError *error = nil;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[_memoryRAM copy]];
  [data writeToFile:filepath options:NSDataWritingAtomic error:&error];
  if (error != nil) {
    NSLog(@"Write returned error: %@", [error localizedDescription]);
  }
  return;
}

- (void)LoadBytecode:(NSString *)bytecode {
  Parser *parser = [Parser new];
  _memoryRAM = [parser ParseBytecode:strdup([bytecode UTF8String])];
  [self prepareRegisters];
  return;
}

- (id)collectNextInstruction {
  id opcode;
  if (findInEnumerator([_registers keyEnumerator], @"ISR")) {
    uint32_t opcodes =
        from64To32([[_registers objectForKey:@"ISR"] integerValue]);
    // This is a mask to remove the ending 2 bits of any number
    opcodes &= -(1 << 2);
    opcode = @(opcodes >> 27);
    opcodes = opcodes << 5;
    [_registers setObject:@(opcodes) forKey:@"ISR"];
  } else {
    opcode = @(OP_PC_FETCH);
  }
  return opcode;
}

- (void)Evaluate {
  while (YES) {
    id opcode = [self collectNextInstruction];
    if ([opcode isEqualTo:@(OP_HALT)]) {
      LOG("HALTING");
      // NSLog(@"%ld", [[_dataStack peek] integerValue]);
      return;
    } else if ([opcode isEqualTo:@(OP_PUSH_A)]) {
      LOG("PUSHING TO A");
      [self instructionOpPushA];
    } else if ([opcode isEqualTo:@(OP_POP_A)]) {
      LOG("POP TO A");
      [self instructionOpPopA];
    } else if ([opcode isEqualTo:@(OP_PUSH_R)]) {
      LOG("PUSHING TO R");
      [self instructionOpPushR];
    } else if ([opcode isEqualTo:@(OP_POP_R)]) {
      LOG("POP R");
      [self instructionOpPopR];
    } else if ([opcode isEqualTo:@(OP_DUP)]) {
      LOG("DUP");
      [self instructionOpDup];
    } else if ([opcode isEqualTo:@(OP_DROP)]) {
      LOG("DROP");
      [self instructionOpDrop];
    } else if ([opcode isEqualTo:@(OP_OVER)]) {
      LOG("OVER");
      [self instructionOpOver];
    } else if ([opcode isEqualTo:@(OP_PC_FETCH)]) {
      LOG("PC FETCH");
      [self instructionOpPcFetch];
    } else if ([opcode isEqualTo:@(OP_JUMP)]) {
      LOG("JUMPING");
      [self instructionOpJump];
    } else if ([opcode isEqualTo:@(OP_JUMP_ZERO)]) {
      LOG("JUMPING ZERO");
      [self instructionOpJumpZero];
    } else if ([opcode isEqualTo:@(OP_JUMP_PLUS)]) {
      LOG("JUMPING PLUS");
      [self instructionOpJumpPlus];
    } else if ([opcode isEqualTo:@(OP_CALL)]) {
      LOG("CALLING");
      [self instructionOpCall];
    } else if ([opcode isEqualTo:@(OP_RET)]) {
      LOG("RETURNING");
      [self instructionOpRet];
    } else if ([opcode isEqualTo:@(OP_LITERAL)]) {
      LOG("FETCH LITERAL");
      [self instructionOpLiteral];
    } else if ([opcode isEqualTo:@(OP_LOAD_A)]) {
      LOG("LOAD A");
      [self instructionOpLoadA];
    } else if ([opcode isEqualTo:@(OP_STORE_A)]) {
      LOG("STORE A");
      [self instructionOpStoreA];
    } else if ([opcode isEqualTo:@(OP_AND)]) {
      LOG("AND");
      [self instructionOpAnd];
    } else if ([opcode isEqualTo:@(OP_OR)]) {
      LOG("OR");
      [self instructionOpOr];
    } else if ([opcode isEqualTo:@(OP_NOT)]) {
      LOG("NOT");
      [self instructionOpNot];
    } else if ([opcode isEqualTo:@(OP_XOR)]) {
      LOG("XOR");
      [self instructionOpXor];
    } else if ([opcode isEqualTo:@(OP_PLUS)]) {
      LOG("PLUS");
      [self instructionOpPlus];
    } else if ([opcode isEqualTo:@(OP_DOUBLE)]) {
      LOG("DOUBLE");
      [self instructionOpDouble];
    } else if ([opcode isEqualTo:@(OP_HALF)]) {
      LOG("HALF");
      [self instructionOpHalf];
    } else if ([opcode isEqualTo:@(OP_PLUS_STAR)]) {
      LOG("PLUS STAR");
      [self instructionOpPlusStar];
    } else if ([opcode isEqualTo:@(OP_LOAD_A_PLUS)]) {
      LOG("LOAD A PLUS");
      [self instructionOpLoadAPlus];
    } else if ([opcode isEqualTo:@(OP_STORE_A_PLUS)]) {
      LOG("STORE A PLUS");
      [self instructionOpStoreAPlus];
    } else if ([opcode isEqualTo:@(OP_LOAD_R_PLUS)]) {
      LOG("LOAD R PLUS");
      [self instructionOpLoadRPlus];
    } else if ([opcode isEqualTo:@(OP_STORE_R_PLUS)]) {
      LOG("STORE R PLUS");
      [self instructionOpStoreRPlus];
    } else if ([opcode isEqualTo:@(OP_NOP)]) {
      LOG("NOP");
    } else if ([opcode isEqualTo:@(OP_SYSCALL)]) {
      LOG("SYSCALL");
      [self instructionSyscall];
    } else if ([opcode isEqualTo:@(OP_SWAP)]) {
      LOG("SWAP");
      [self instructionOpSwap];
    } else {
      LOG("DEFAULT");
      return;
    }
  }
}

@end
