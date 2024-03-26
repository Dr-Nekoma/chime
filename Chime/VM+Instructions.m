#import "Headers/Utilities.h"
#import "Headers/VM+Instructions.h"
#import "Headers/VM.h"
#import <Foundation/Foundation.h>

@implementation VM (Instructions)

- (void)instructionOpPushA {
  @try {
    id valueOfA = [self.dataStack pop];
    [self.registers setObject:valueOfA forKey:@"A"];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionOpPopA {
  if (findInEnumerator([self.registers keyEnumerator], @"A")) {
    id valueOfA = [self.registers objectForKey:@"A"];
    [self.dataStack push:valueOfA];
  } else {
    @throw [NSException
        exceptionWithName:@"Stack Underflow"
                   reason:@"Attempting to push value to undefined 'A' register"
                 userInfo:nil];
  }
}

- (void)instructionOpPushR {
  @try {
    id valueOfR = [self.dataStack pop];
    [self.returnStack push:valueOfR];
    [self.instructionStack push:@0];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionOpPopR {
  @try {
    id valueOfR = [self.returnStack pop];
    [self.dataStack push:valueOfR];
    [self.instructionStack pop];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionOpDup {
  @try {
    [self.dataStack push:[self.dataStack peek]];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionOpDrop {
  @try {
    [self.dataStack pop];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionOpOver {
  @try {
    id top = [self.dataStack pop];
    id second = [self.dataStack peek];
    [self.dataStack push:top];
    [self.dataStack push:second];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionOpPcFetch {
  // Each word contains 6 instructions of 5 bits each
  // PC puts the word into a temporary buffer called ISR
  if (findInEnumerator([self.registers keyEnumerator], @"PC")) {
    NSUInteger valueOfPC = [[self.registers objectForKey:@"PC"] integerValue];
    @try {
      [self.registers setObject:[self.memoryRAM objectAtIndex:valueOfPC]
                         forKey:@"ISR"];
      [self.registers setObject:@(valueOfPC + 1) forKey:@"PC"];
    } @catch (NSException *exception) {
      @throw [NSException exceptionWithName:@"Out of Memory"
                                     reason:@"Uh oh... we ran out of memory :("
                                   userInfo:nil];
    }
  } else {
    @throw [NSException exceptionWithName:@"Stack Underflow"
                                   reason:@"Attempting to read value to "
                                          @"undefined 'PC' register"
                                 userInfo:nil];
  }
}

- (void)instructionOpJump {
  if (findInEnumerator([self.registers keyEnumerator], @"PC")) {
    NSUInteger valueOfPC = [[self.registers objectForKey:@"PC"] integerValue];
    [self.registers setObject:[self.memoryRAM objectAtIndex:valueOfPC]
                       forKey:@"PC"];
    [self.registers setObject:@0 forKey:@"ISR"];
  } else {
    @throw [NSException exceptionWithName:@"Stack Underflow"
                                   reason:@"Attempting to read value to "
                                          @"undefined 'PC' register"
                                 userInfo:nil];
  }
}

- (void)instructionOpJumpZero {
  if (findInEnumerator([self.registers keyEnumerator], @"PC")) {
    @try {
      id poppedValue = [self.dataStack pop];
      NSUInteger valueOfPC = [[self.registers objectForKey:@"PC"] integerValue];
      if ([poppedValue isEqualTo:@0]) {
        [self.registers setObject:[self.memoryRAM objectAtIndex:valueOfPC]
                           forKey:@"PC"];
        [self.registers setObject:@0 forKey:@"ISR"];
      } else {
        [self.registers setObject:@(valueOfPC + 1) forKey:@"PC"];
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
}

- (void)instructionOpJumpPlus {
  if (findInEnumerator([self.registers keyEnumerator], @"PC")) {
    @try {
      id poppedValue = [self.dataStack pop];
      NSUInteger valueOfPC = [[self.registers objectForKey:@"PC"] integerValue];
      if ([poppedValue isGreaterThan:@0]) {
        [self.registers setObject:[self.memoryRAM objectAtIndex:valueOfPC]
                           forKey:@"PC"];
        [self.registers setObject:@0 forKey:@"ISR"];
      } else {
        [self.registers setObject:@(valueOfPC + 1) forKey:@"PC"];
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
}

- (void)instructionOpCall {
  if (findInEnumerator([self.registers keyEnumerator], @"PC")) {
    NSUInteger valueOfPC = [[self.registers objectForKey:@"PC"] integerValue];
    [self.returnStack push:@(valueOfPC + 1)];
    [self.registers setObject:[self.memoryRAM objectAtIndex:valueOfPC]
                       forKey:@"PC"];
    [self.instructionStack push:[self.registers objectForKey:@"ISR"]];
    [self.registers setObject:@0 forKey:@"ISR"];
  } else {
    @throw [NSException exceptionWithName:@"Stack Underflow"
                                   reason:@"Attempting to read value to "
                                          @"undefined 'PC' register"
                                 userInfo:nil];
  }
}

- (void)instructionOpRet {
  if (findInEnumerator([self.registers keyEnumerator], @"PC")) {
    @try {
      id poppedValue = [self.returnStack pop];
      [self.registers setObject:poppedValue forKey:@"PC"];
      [self.registers setObject:[self.instructionStack pop] forKey:@"ISR"];
    } @catch (NSException *exception) {
      @throw exception;
    }
  } else {
    @throw [NSException exceptionWithName:@"Stack Underflow"
                                   reason:@"Attempting to read value to "
                                          @"undefined 'PC' register"
                                 userInfo:nil];
  }
}

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
  if (value1 % 2 == 1) {
    [self.dataStack push:@(value1 + value2)];
  } else {
    [self.dataStack push:@(value1)];
  }
}

- (void)instructionOpLoadAPlus {
  NSUInteger valueOfA = [[self.registers objectForKey:@"A"] integerValue];
  NSInteger value = [[self.memoryRAM objectAtIndex:valueOfA] integerValue];
  [self.dataStack push:@(value)];
  [self.registers setObject:@(valueOfA + 1) forKey:@"A"];
}

- (void)instructionOpStoreAPlus {
  id value = [self.dataStack pop];
  NSUInteger valueOfA = [[self.registers objectForKey:@"A"] integerValue];
  [self.memoryRAM setObject:value atIndexedSubscript:valueOfA];
  [self.registers setObject:@(valueOfA + 1) forKey:@"A"];
}

- (void)instructionOpLoadRPlus {
  NSUInteger valueOfR = [[self.returnStack pop] integerValue];
  NSInteger value = [[self.memoryRAM objectAtIndex:valueOfR] integerValue];
  [self.dataStack push:@(value)];
  [self.returnStack push:@(valueOfR + 1)];
}

- (void)instructionOpStoreRPlus {
  id value = [self.dataStack pop];
  NSUInteger valueOfR = [[self.returnStack pop] integerValue];
  [self.memoryRAM setObject:value atIndexedSubscript:valueOfR];
  [self.returnStack push:@(valueOfR + 1)];
}

- (void)instructionOpSwap {
  @try {
    NSUInteger valueA = [[self.dataStack pop] integerValue];
    NSUInteger valueB = [[self.dataStack pop] integerValue];
    [self.dataStack push:@(valueA)];
    [self.dataStack push:@(valueB)];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

@end
