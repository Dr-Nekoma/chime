#ifndef Utilities_h
#define Utilities_h

#include "Opcode.h"
#import <Foundation/Foundation.h>

#define DEVELOPER_MODE 0
#if DEVELOPER_MODE
#define LOG(str) NSLog(@str)
#else
#define LOG(_)
#endif

typedef struct {
  NSUInteger remainder;
  NSUInteger howManyWords;
  BOOL trailingWord;
} Word_Manager;

bool findInEnumerator(NSEnumerator *, id);

uint32_t from64To32(uint64_t value);

NSInteger packWord(OPCODE *opcodes);

NSInteger packFullWord(NSArray *instructions, NSMapTable *keywords);

NSMapTable *parseCommandLine(int argc, const char *argv[]);

void errorMissingProgramFilePath();

void errorMissingDialectFilePath();

void errorMissingLoadFilePath();

void errorMissingSaveFilePath();

NSArray *padWords(NSMutableArray *words, NSUInteger desiredSize);

Word_Manager howManyWords(NSUInteger length);

NSMutableArray *packString(NSString *string);

NSMutableData *unpackString(id startPointer, NSMutableArray *array);

#endif /* Utilities_h */
