#import "Headers/Parser.h"
#import "Headers/Opcode.h"
#import "Headers/Utilities.h"

#define IS_LABEL YES
#define IS_NOT_LABEL NO
#define MAX_STRING_SIZE 2147483647
#define WORD_SIZE 4

@implementation Parser

- (Parser *)init {
  self = [super init];
  if (self) {
    _program = [[NSArray alloc] init];
    _labels = [[NSMapTable alloc] init];
    _variables = [[NSMapTable alloc] init];
    _keywords = [[NSMapTable alloc] init];
    _physicalLinesCounter = 0;
  }
  return self;
}

- (void)loadKeywords:(char *)filepath {

  NSData *data = [[NSData alloc] initWithContentsOfFile:@(filepath)];

  if (data == nil) {
    NSLog(@"Could not read keywords from file \"%s\"", filepath);
  }

  NSString *stringKeywords =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  NSArray *keywordsArr = [stringKeywords componentsSeparatedByString:@"\n"];

  for (uint64_t i = 0; i < OP_TOTAL; i++) {
    [_keywords setObject:@(i) forKey:[keywordsArr objectAtIndex:i]];
  }
}

BOOL isStringStartingWith(NSString *line, NSString *target) {
  return [line hasPrefix:target];
}

static inline BOOL isLineEmpty(id line) {
  return line == nil ||
         ([line respondsToSelector:@selector(length)] &&
          [(NSData *)line length] == 0) ||
         ([line respondsToSelector:@selector(count)] &&
          [(NSArray *)line count] == 0);
}

BOOL isNumberLine(NSString *line) { return isStringStartingWith(line, @"#"); }

BOOL isLabelLine(NSString *line) { return isStringStartingWith(line, @":"); }

BOOL isVariableLine(NSString *line) {
  return isStringStartingWith(line, @">") &&
         isStringStartingWith(tokenAt(line, 1), @"#");
}

BOOL isAddressLine(NSString *line) { return isStringStartingWith(line, @"&"); }

BOOL isDerefLine(NSString *line) { return isStringStartingWith(line, @"*"); }

NSString *tokenAt(NSString *string, NSInteger index) {
  NSArray *line = [string componentsSeparatedByString:@" "];
  if ([line count] <= index) {
    @throw [NSException
        exceptionWithName:@"Line index out of bounds"
                   reason:[NSString
                              stringWithFormat:@"Could not find token at "
                                               @"position %lu in line \"%@\"",
                                               index, line]
                 userInfo:nil];
  } else {
    return [line objectAtIndex:index];
  }
}

NSString *popFirstChar(NSString *string) {
  return [string substringFromIndex:1];
}

NSString *popLastChar(NSString *string) {
  return [string substringToIndex:(string.length - 1)];
}

NSString *popBothEnds(NSString *string) {
  NSString *withoutFirst = popFirstChar(string);
  return popLastChar(withoutFirst);
}

- (void)handleLabelLine:(NSString *)line
        withLineCounter:(NSUInteger)logicalLinesCounter {
  NSString *labelColon = tokenAt(line, 0);
  NSString *label = popFirstChar(labelColon);
  if (findInEnumerator([_labels keyEnumerator], label)) {
    @throw [NSException
        exceptionWithName:@"Label Collision"
                   reason:[NSString
                              stringWithFormat:@"Found label \"%@\" more than "
                                               @"once. Lines %lu and %@.",
                                               label,
                                               [[_labels objectForKey:label]
                                                   integerValue],
                                               @(_physicalLinesCounter)]
                 userInfo:nil];
  } else {
    [_labels setObject:@(logicalLinesCounter) forKey:label];
  }
}

- (void)handleVariableLine:(NSString *)line {
  NSString *variableLabel = popFirstChar(tokenAt(line, 0));
  NSString *secondToken = tokenAt(line, 1);
  NSString *number = popFirstChar(secondToken);
  [_variables setObject:@((NSUInteger)[number integerValue])
                 forKey:variableLabel];
}

BOOL isChimeString(NSString *string) {
  return isStringStartingWith(string, @"\"");
}

BOOL checkBothStringEnds(NSString *string) {
  return ('\"' == [string characterAtIndex:0]) &&
         ('\"' == [string characterAtIndex:(string.length - 1)]);
}

- (void)handleStringCase:(NSString *)line
         withLineCounter:(NSUInteger *)logicalLinesCounter {
  NSString *stringCandidate = tokenAt(line, 1);
  if (!isChimeString(stringCandidate)) {
    return;
  }

  if (!checkBothStringEnds(stringCandidate)) {
    @throw [NSException
        exceptionWithName:@"Invalid String"
                   reason:[NSString
                              stringWithFormat:
                                  @"Found string unbalanced delimiter at %lu",
                                  _physicalLinesCounter]
                 userInfo:nil];
  }
  NSString *stringContent = popBothEnds(stringCandidate);
  NSUInteger length = stringContent.length;
  NSUInteger lengthByte = 1;
  NSUInteger howManyWords = (length / WORD_SIZE) + (length % WORD_SIZE ? 1 : 0);
  // This minus is to account with the existent logic of incrementing the logical counter for the next round.
  *logicalLinesCounter += howManyWords + lengthByte - 1;
  return;
}

- (void)passOne {
  NSEnumerator *programEnumerator = [_program objectEnumerator];
  id lineId;
  _physicalLinesCounter = 0;
  NSUInteger logicalLinesCounter = 0;
  while (lineId = [programEnumerator nextObject]) {
    if (!isLineEmpty(lineId)) {
      if (isLabelLine(lineId)) {
        [self handleLabelLine:lineId withLineCounter:logicalLinesCounter];
        [self handleStringCase:lineId withLineCounter:&logicalLinesCounter];
      } else if (isVariableLine(lineId)) {
        [self handleVariableLine:lineId];
        logicalLinesCounter--;
      }
      logicalLinesCounter++;
    }
    _physicalLinesCounter++;
  }
}

NSArray *popFirstToken(NSArray *stream) {
  return [stream
      objectsAtIndexes:[NSIndexSet
                           indexSetWithIndexesInRange:NSMakeRange(
                                                          1,
                                                          [stream count] - 1)]];
}

- (uint32_t)validateInstructions:(BOOL)isLabel with:(NSString *)line {
  NSArray *tokens = [line componentsSeparatedByString:@" "];
  if (isLabel) {
    tokens = popFirstToken(tokens);
  }
  uint32_t word = packFullWord(tokens, _keywords);
  return word;
}

- (void)handleNumberLine:(NSString *)string fill:(NSMutableArray *)bytecodes {
  NSString *number = popFirstChar(string);
  [bytecodes addObject:@([number integerValue])];
}

- (void)handleDerefLine:(NSString *)string fill:(NSMutableArray *)bytecodes {
  NSString *label = popFirstChar(string);
  if (findInEnumerator([_variables keyEnumerator], label)) {
    id valueOfLabel = [_variables objectForKey:label];
    [bytecodes addObject:@([valueOfLabel integerValue])];
  } else {
    @throw [NSException
        exceptionWithName:@"Variable Label Not Found"
                   reason:[NSString stringWithFormat:
                                        @"Could not find variable label "
                                        @"\"%@\" in current scope at line %@",
                                        label, @(_physicalLinesCounter)]
                 userInfo:nil];
  }
}

- (void)handleAddressLine:(NSString *)string fill:(NSMutableArray *)bytecodes {
  NSString *label = popFirstChar(string);
  if (findInEnumerator([_labels keyEnumerator], label)) {
    id valueOfLabel = [_labels objectForKey:label];
    [bytecodes addObject:@([valueOfLabel integerValue])];
  } else {
    @throw [NSException
        exceptionWithName:@"Address Label Not Found"
                   reason:[NSString stringWithFormat:
                                        @"Could not find address label "
                                        @"\"%@\" in current scope at line %@",
                                        label, @(_physicalLinesCounter)]
                 userInfo:nil];
  }
}

- (void)handleInstructions:(BOOL)isLabel
                      with:(NSString *)string
                      fill:(NSMutableArray *)bytecodes {
  @try {
    uint32_t instructions = [self validateInstructions:isLabel with:string];
    [bytecodes addObject:@(instructions)];
  } @catch (NSException *exception) {
    @throw [NSException
        exceptionWithName:@"Invalid line encountered"
                   reason:[NSString stringWithFormat:
                                        @"\nLine %@:\n \"%@\" is invalid",
                                        @(_physicalLinesCounter), string]
                 userInfo:nil];
  }
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

- (void)handleStringLine:(NSString *)chimeString
                    fill:(NSMutableArray *)bytecodes {
  NSString *content = popBothEnds(chimeString);
  NSUInteger length = content.length; // TODO: Escape codes
  if (length > MAX_STRING_SIZE) {
    @throw [NSException
        exceptionWithName:@"String limit exceeded"
                   reason:[NSString
                              stringWithFormat:
                                  @"String \"%@\" exceeded max size of %d",
                                  content, MAX_STRING_SIZE]
                 userInfo:nil];
  }
  NSMutableArray *stringPayload = packString(content);
  [bytecodes addObject:@((uint32_t)length)];
  [bytecodes addObjectsFromArray:[stringPayload copy]];
}

- (void)handleLine:(NSString *)line
         labelInfo:(BOOL)labelInfo
          checking:(NSString *)check
              fill:(NSMutableArray *)bytecodes {
  if (isNumberLine(check)) {
    [self handleNumberLine:check fill:bytecodes];
  } else if (isDerefLine(check)) {
    [self handleDerefLine:check fill:bytecodes];
  } else if (isAddressLine(check)) {
    [self handleAddressLine:line fill:bytecodes];
  } else if (isChimeString(check)) {
    [self handleStringLine:check fill:bytecodes];
  } else {
    [self handleInstructions:labelInfo with:line fill:bytecodes];
  }
}

- (NSMutableArray *)passTwo {
  NSMutableArray *bytecodes = [[NSMutableArray alloc] init];
  NSEnumerator *programLines = [_program objectEnumerator];
  id line;
  _physicalLinesCounter = 0;
  while (line = [programLines nextObject]) {
    if (!isLineEmpty(line) && !isVariableLine(line)) {
      if (isLabelLine(line)) {
        NSString *secondToken = tokenAt(line, 1);
        [self handleLine:line
               labelInfo:IS_LABEL
                checking:secondToken
                    fill:bytecodes];
      } else {
        [self handleLine:line
               labelInfo:IS_NOT_LABEL
                checking:line
                    fill:bytecodes];
      }
    }
    _physicalLinesCounter++;
  }
  return bytecodes;
}

NSArray *cleanProgram(NSString *stringProgram) {
  NSMutableArray *trimmedProgram = [NSMutableArray array];
  for (NSString *line in [stringProgram componentsSeparatedByString:@"\n"]) {
    NSString *trimmedLine =
        [line stringByTrimmingCharactersInSet:[NSCharacterSet
                                                  whitespaceCharacterSet]];
    [trimmedProgram addObject:trimmedLine];
  }
  return [trimmedProgram copy];
}

- (NSMutableArray *)Parse:(char *)filePath usingKeywords:(char *)keywordsPath {
  NSData *data = [[NSData alloc] initWithContentsOfFile:@(filePath)];

  if (data == nil) {
    NSLog(@"Could not read file \"%s\"", filePath);
    return nil;
  }

  NSString *stringProgram =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  _program = cleanProgram(stringProgram);

  [self loadKeywords:keywordsPath];
  [self passOne];
  return [self passTwo];
}

- (void)printState {
  NSLog(@"Labels' Keys: %@", [[_labels keyEnumerator] allObjects]);
  NSLog(@"Labels' Values: %@", [[_labels objectEnumerator] allObjects]);
  NSLog(@"Variables' Keys: %@", [[_variables keyEnumerator] allObjects]);
  NSLog(@"Variables' Values: %@", [[_variables objectEnumerator] allObjects]);
  NSLog(@"Keywords' Keys: %@", [[_keywords keyEnumerator] allObjects]);
  NSLog(@"Keywords' Values: %@", [[_keywords objectEnumerator] allObjects]);
}

@end
