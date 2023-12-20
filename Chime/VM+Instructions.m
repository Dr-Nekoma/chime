#import "Headers/VM.h"
#import "Headers/VM+Instructions.h"
#import <Foundation/Foundation.h>

@implementation VM (Instructions)

- (void)instructionOpLiteral {
  NSUInteger valueOfPC = [[self.registers objectForKey:@"PC"] integerValue];
  NSInteger value = [[self.memoryRAM objectAtIndex:valueOfPC] integerValue];
  [self.dataStack push:@(value)];
  [self.registers setObject:@(valueOfPC + 1) forKey:@"PC"];
}

- (void)instructionOpLoadA {
  NSUInteger valueOfA = [[self.registers objectForKey:@"A"] integerValue];
  NSInteger value = [[self.memoryRAM objectAtIndex:valueOfA] integerValue];
  [self.dataStack push:@(value)];
}

- (void)instructionOpStoreA {
  NSUInteger valueOfA = [[self.registers objectForKey:@"A"] integerValue];
  id value = [self.dataStack pop];
  [self.memoryRAM setObject:value atIndexedSubscript:valueOfA];
}

- (void)instructionOpAnd {
  NSInteger value1 = [[self.dataStack pop] integerValue];
  NSInteger value2 = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(value1 & value2)];
}

- (void)instructionOpOr {
  NSInteger value1 = [[self.dataStack pop] integerValue];
  NSInteger value2 = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(value1 | value2)];
}

- (void)instructionOpNot {
  NSInteger value = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(~value)];
}

- (void)instructionOpXor {
  NSInteger value1 = [[self.dataStack pop] integerValue];
  NSInteger value2 = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(value1 ^ value2)];
}

- (void)instructionOpPlus {
  NSInteger value1 = [[self.dataStack pop] integerValue];
  NSInteger value2 = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(value1 + value2)];
}

- (void)instructionOpDouble {
  NSInteger value = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(value << 1)];
}

- (void)instructionOpHalf {
  NSInteger value = [[self.dataStack pop] integerValue];
  [self.dataStack push:@(value >> 1)];
}

- (void)instructionOpPlusStar {
  NSInteger value1 = [[self.dataStack pop] integerValue];
  NSInteger value2 = [[self.dataStack peek] integerValue];
  if (value1 % 2 == 1){
    [self.dataStack push:@(value1 + value2)];
  } else {
    [self.dataStack push:@(value1)];
  }   
}

- (void)instructionOpLoadAPlus {
  NSUInteger valueOfA = [[self.registers objectForKey:@"A"] integerValue];
  NSInteger value = [[self.memoryRAM objectAtIndex:valueOfA] integerValue];
  [self.registers setObject:@(valueOfA + 1) forKey:@"A"];
  [self.dataStack push:@(value)];
}

- (void)instructionOpStoreAPlus {
  NSUInteger valueOfA = [[self.registers objectForKey:@"A"] integerValue];
  id value = [self.dataStack pop];
  [self.registers setObject:@(valueOfA + 1) forKey:@"A"];
  [self.memoryRAM setObject:value atIndexedSubscript:valueOfA];
}

- (void)instructionOpLoadRPlus {
  NSUInteger valueOfR = [[self.returnStack pop] integerValue];
  NSInteger value = [[self.memoryRAM objectAtIndex:valueOfR] integerValue];
  [self.returnStack push:@(valueOfR + 1)];
  [self.dataStack push:@(value)];
}

- (void)instructionOpStoreRPlus {
  NSUInteger valueOfR = [[self.returnStack pop] integerValue];
  id value = [self.dataStack pop];
  [self.returnStack push:@(valueOfR + 1)];
  [self.memoryRAM setObject:value atIndexedSubscript:valueOfR];
}

@end
