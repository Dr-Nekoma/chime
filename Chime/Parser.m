#import "Headers/Parser.h"
#import "Headers/Opcode.h"
#import "Headers/Utilities.h"

#define IS_LABEL YES
#define IS_NOT_LABEL NO

@implementation Parser

- (Parser *)init {
  self = [super init];
  if (self) {
    _program = [[NSArray alloc] init];
    _labels = [[NSMapTable alloc] init];
    _variables = [[NSMapTable alloc] init];
    _keywords = [[NSMapTable alloc] init];
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

- (void)handleLabelLine:(NSString *)line
        withLineCounter:(NSUInteger)nonEmptyLinesCounter {
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
                                               @(_counter)]
                 userInfo:nil];
  } else {
    [_labels setObject:@(nonEmptyLinesCounter) forKey:label];
  }
}

// TODO: Investigate modal code sections for compile time area and run time area
- (void)handleVariableLine:(NSString *)line {
  NSString *variableLabel = popFirstChar(tokenAt(line, 0));
  NSString *secondToken = tokenAt(line, 1);
  NSString *number = popFirstChar(secondToken);
  [_variables setObject:@((NSUInteger)[number integerValue])
                 forKey:variableLabel];
}

- (void)passOne {
  NSEnumerator *programEnumerator = [_program objectEnumerator];
  id lineId;
  _counter = 0;
  NSUInteger nonEmptyLinesCounter = 0;
  while (lineId = [programEnumerator nextObject]) {
    if (!isLineEmpty(lineId)) {
      if (isLabelLine(lineId)) {
        [self handleLabelLine:lineId withLineCounter:nonEmptyLinesCounter];
      } else if (isVariableLine(lineId)) {
        [self handleVariableLine:lineId];
        nonEmptyLinesCounter--;
      }
      nonEmptyLinesCounter++;
    }
    _counter++;
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
                                        label, @(_counter)]
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
                                        label, @(_counter)]
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
                                        @(_counter), string]
                 userInfo:nil];
  }
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
  } else {
    [self handleInstructions:labelInfo with:line fill:bytecodes];
  }
}

- (NSMutableArray *)passTwo {
  NSMutableArray *bytecodes = [[NSMutableArray alloc] init];
  NSEnumerator *programEnumerator = [_program objectEnumerator];
  id lineId;
  _counter = 0;
  while (lineId = [programEnumerator nextObject]) {
    if (!isLineEmpty(lineId) && !isVariableLine(lineId)) {
      if (isLabelLine(lineId)) {
        NSString *secondToken = tokenAt(lineId, 1);
        [self handleLine:lineId
               labelInfo:IS_LABEL
                checking:secondToken
                    fill:bytecodes];
      } else {
        [self handleLine:lineId
               labelInfo:IS_NOT_LABEL
                checking:lineId
                    fill:bytecodes];
      }
    }
    _counter++;
  }
  return bytecodes;
}

- (NSMutableArray *)Parse:(char *)filePath usingKeywords:(char *)keywordsPath {
  NSData *data = [[NSData alloc] initWithContentsOfFile:@(filePath)];

  if (data == nil) {
    NSLog(@"Could not read file \"%s\"", filePath);
    return nil;
  }

  NSString *stringProgram =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  _program = [stringProgram componentsSeparatedByString:@"\n"];

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
