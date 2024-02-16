#ifndef Utilities_h
#define Utilities_h

#include "Opcode.h"
#import <Foundation/Foundation.h>

typedef struct {
  NSUInteger remainder;
  NSUInteger howManyWords;
  BOOL trailingWord;
} Word_Manager;

bool findInEnumerator(NSEnumerator *, id);

uint32_t from64To32(uint64_t value);

NSInteger packWord(OPCODE *opcodes);

NSInteger packFullWord(NSArray *instructions, NSMapTable *keywords);

NSArray *padWords(NSMutableArray *words, NSUInteger desiredSize);

Word_Manager howManyWords(NSUInteger length);

NSMutableArray *packString(NSString *string);

NSString *unpackString(id startPointer, NSMutableArray *array);


#endif /* Utilities_h */
