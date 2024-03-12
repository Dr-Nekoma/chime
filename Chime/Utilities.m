#import <Foundation/Foundation.h>

#include "Headers/Utilities.h"
#include "Headers/Parser.h"

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

void errorMissingProgramFilePath() {
  @throw [NSException
      exceptionWithName:@"Missing program in command line"
                 reason:[NSString
                            stringWithFormat:
                                @"Expected the filepath of a program alonside "
                                @"the flag \"-p\" or \"--program\""]
               userInfo:nil];
}

void errorMissingDialectFilePath() {
  @throw [NSException
      exceptionWithName:@"Missing dialect set in command line"
                 reason:[NSString
                            stringWithFormat:
                                @"Expected the filepath of a dialect alongside "
                                @"the flag \"-d\" or \"--dialect\""]
               userInfo:nil];
}

void errorMissingLoadFilePath() {
  @throw [NSException
      exceptionWithName:@"Missing file path to load a compiled program"
                 reason:[NSString stringWithFormat:
                                      @"Loading operation expects a filepath "
                                      @"to exist alongside the flag"]
               userInfo:nil];
}

void errorMissingSaveFilePath() {
  @throw [NSException
      exceptionWithName:@"Missing file path to save a compiled program"
                 reason:[NSString stringWithFormat:
                                      @"Saving operation expects a filepath to "
                                      @"exist alongside the flag"]
               userInfo:nil];
}

void errorExtraArguments(char *arg) {
  @throw [NSException
      exceptionWithName:@"Extra Arguments Provided"
                 reason:[NSString
                            stringWithFormat:
                                @"Unexpected argument provided: \"%s\"", arg]
               userInfo:nil];
}

NSMapTable *parseCommandLine(int argc, const char *argv[]) {
#define SaveArg(keyName, errorMessageFunc)                                     \
  if (argv[i + 1] == NULL) {                                                   \
    errorMessageFunc;                                                          \
  } else {                                                                     \
    [cmds setObject:@(argv[i + 1]) forKey:@keyName];                           \
    i++;                                                                       \
  }
  NSMapTable *cmds = [[NSMapTable alloc] init];

  // Jumping the program in argv
  for (int i = 1; i < argc; i++) {
    if ((strcmp(argv[i], "-l") == 0) || (strcmp(argv[i], "--load") == 0)) {
      SaveArg("LoadFilePath", errorMissingLoadFilePath());
    } else if ((strcmp(argv[i], "-s") == 0) ||
               (strcmp(argv[i], "--save") == 0)) {
      SaveArg("SaveFilePath", errorMissingSaveFilePath());
    } else if ((strcmp(argv[i], "-p") == 0) ||
               (strcmp(argv[i], "--program") == 0)) {
      SaveArg("ProgramFilePath", errorMissingProgramFilePath());
    } else if ((strcmp(argv[i], "-d") == 0) ||
               (strcmp(argv[i], "--dialect") == 0)) {
      SaveArg("DialectFilePath", errorMissingDialectFilePath());
    } else {
      errorExtraArguments(argv[i]);
    }
  }

  return cmds;

NSArray *padWords(NSMutableArray *words, NSUInteger desiredSize) {
  while ([words count] < desiredSize) {
    [words addObject:@((uint32_t)0)];
  }
  return [words copy];
}

Word_Manager howManyWords(NSUInteger length) {
  NSUInteger remainder = length % WORD_SIZE;
  NSUInteger trailingWord = remainder ? 1 : 0;
  NSUInteger howManyWords = (length / WORD_SIZE) + trailingWord;
  return (Word_Manager) {
    .remainder = remainder,
    .trailingWord = trailingWord,
    .howManyWords = howManyWords,
  };
}

NSMutableArray *packString(NSString *string) {
  NSMutableArray *pack = [[NSMutableArray alloc] init];
  NSUInteger counter = 0;
  uint32_t buffer = 0;
  NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
  const char *bytes = [stringData bytes];
  for (int i = 0; i < [stringData length]; i++) {
    buffer = buffer << 8;
    buffer |= (char)bytes[i];
    counter++;
    if (counter == WORD_SIZE) {
      [pack addObject:@(buffer)];
      buffer = 0;
      counter = 0;
    }
  }
  if (counter != 0) {
    [pack addObject:@(buffer << (8 * (WORD_SIZE - counter)))];
  }

  return pack;
}

uint32_t bigEndian(uint32_t word) {
  char bytes[4];
  bytes[0] = word >> 24;
  bytes[1] = word >> 16;
  bytes[2] = word >> 8;
  bytes[3] = word;

  uint32_t *magic = (uint32_t*) bytes;
  return *magic;
}

NSString *unpackString(id startPointer, NSMutableArray *array) {
  NSUInteger counter = [startPointer integerValue];
  NSUInteger length = [[array objectAtIndex:counter] integerValue];
  counter++; // Jump length word;

  Word_Manager wm = howManyWords(length);
  NSMutableData *data = [NSMutableData dataWithLength:length];
  
  NSUInteger byteCounter = 0;
  for (int i = 0; i < wm.howManyWords; i++) {
    // This is changing the endianness of the sequence of bytes in order for us to get an array of chars in the correct order
    uint32_t bigEndianedChunk = bigEndian([array[i + counter] integerValue]);
    char *stringChunk = (char *) &bigEndianedChunk;
    
    NSUInteger bytesInTheWord = (i == wm.howManyWords - 1 && wm.trailingWord) ? wm.remainder : WORD_SIZE;
    
    [data replaceBytesInRange:(NSMakeRange (byteCounter, byteCounter + bytesInTheWord))  withBytes:stringChunk];
    byteCounter += WORD_SIZE;
  }
  return [NSString stringWithUTF8String:[data bytes]];
}
