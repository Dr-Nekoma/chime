#ifndef Utilities_h
#define Utilities_h

#include "Opcode.h"
#import <Foundation/Foundation.h>

bool findInEnumerator(NSEnumerator *, id);

uint32_t from64To32(uint64_t);

uint32_t packWord(OPCODE *opcodes);

#endif /* Utilities_h */
