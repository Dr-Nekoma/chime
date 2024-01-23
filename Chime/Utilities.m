#import <Foundation/Foundation.h>

#include "Headers/Utilities.h"

bool findInEnumerator(NSEnumerator *enumerator, id target) {
  bool found = false;
  for (NSString *key in enumerator) {
    if ([key isEqualToString:target]) {
      found = true;
      break;
    }
  }
  return found;
}

uint32_t from64To32(uint64_t value) { return 0xFFFFFFFF & value; }

NSInteger packWord(OPCODE *opcodes) {
  uint32_t word = 0;
  for (int i = 0; i < 6; i++) {
    word = word << 5;
    word |= opcodes[i];
  }
  word = word << 2;
  return word;
}

NSInteger packFullWord(NSArray *instructions, NSMapTable *keywordsMap) {
  OPCODE word[6] = {0};
  for (int i = 0; i < [instructions count]; i++) {
    // Generic things that you do to objects of *any* class go here.
    if (findInEnumerator([keywordsMap keyEnumerator], instructions[i])) {
      uint64_t opcode =
          (uint64_t)[[keywordsMap objectForKey:instructions[i]] integerValue];
      // NSLog(@"%lu", opcode);
      word[i] = opcode;
    } else {
      @throw [NSException
          exceptionWithName:@"Invalid instruction"
                     reason:[NSString
                                stringWithFormat:@"The instruction \"%@\" is "
                                                 @"invalid in Chime",
                                                 instructions[i]]
                   userInfo:nil];
    }
  }
  return packWord(word);
}
