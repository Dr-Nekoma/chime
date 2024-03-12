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
}
