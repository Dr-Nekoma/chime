#ifndef Utilities_h
#define Utilities_h

#include "Opcode.h"
#import <Foundation/Foundation.h>

bool findInEnumerator(NSEnumerator *, id);

uint32_t from64To32(uint64_t value);

NSInteger packWord(OPCODE *opcodes);

NSInteger packFullWord(NSArray *instructions, NSMapTable *keywords);

NSMapTable *parseCommandLine(int argc, const char *argv[]);

void errorMissingLoadFilePath();

void errorMissingSaveFilePath();

#endif /* Utilities_h */
