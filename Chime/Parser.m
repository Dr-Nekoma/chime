#import "Headers/Opcode.h"
#import "Headers/Parser.h"
#import "Headers/Utilities.h"
#import <Foundation/Foundation.h>

NSMapTable *loadKeywords(char *filepath) {
  NSData *data = [[NSData alloc] initWithContentsOfFile:@(filepath)];

  if (data == nil) {
    NSLog(@"Could not read keywords from file \"%s\"", filepath);
  }

  NSString *stringKeywords =
    [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  NSArray *keywordsArr = [stringKeywords componentsSeparatedByString:@"\n"];

  NSMapTable *keywords = [[NSMapTable alloc] init];
  
  for(uint64_t i = 0; i < OP_TOTAL; i++){
    [keywords setObject:@(i) forKey:[keywordsArr objectAtIndex:i]];      
  }

  return keywords;
}

NSMutableArray *parse(char *filePath, char *keywordsPath) {
  NSData *data = [[NSData alloc] initWithContentsOfFile:@(filePath)];

  if (data == nil) {
    NSLog(@"Could not read file \"%s\"", filePath);
    return nil;
  }

  NSString *stringProgram =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  NSArray *program = [stringProgram componentsSeparatedByString:@"\n"];
  NSMapTable *labels = [[NSMapTable alloc] init];
  NSMapTable *variables = [[NSMapTable alloc] init];
  NSMapTable *keywords = loadKeywords(keywordsPath);
  passOne(program, labels, variables);
  // NSLog(@"Labels' Keys: %@", [[labels keyEnumerator] allObjects]);
  // NSLog(@"Labels' Values: %@", [[labels objectEnumerator] allObjects]);
  // NSLog(@"Variables' Keys: %@", [[variables keyEnumerator] allObjects]);
  // NSLog(@"Variables' Values: %@", [[variables objectEnumerator] allObjects]);
  // NSLog(@"Keywords' Keys: %@", [[keywords keyEnumerator] allObjects]);
  // NSLog(@"Keywords' Values: %@", [[keywords objectEnumerator] allObjects]);
  return passTwo(program, labels, variables, keywords);
}

BOOL isStringStartingWith(NSString *line, NSString *target) {
  return [line hasPrefix:target];
}

static inline BOOL isLineEmpty(id line) {
  return line == nil
    || ([line respondsToSelector:@selector(length)]
	&& [(NSData *)line length] == 0)
    || ([line respondsToSelector:@selector(count)]
	&& [(NSArray *)line count] == 0);
}


BOOL isNumberLine(NSString *line) { return isStringStartingWith(line, @"#"); }

BOOL isLabelLine(NSString *line) { return isStringStartingWith(line, @":"); }

BOOL isVariableLine(NSString *line) {
  return isStringStartingWith(tokenAt(line, 1), @"#");
}

BOOL isAddressLine(NSString *line) {
  return isStringStartingWith(line, @"&");
}

BOOL isDerefLine(NSString *line) {
  return isStringStartingWith(line, @"*");
}

NSString *tokenAt(NSString *string, NSInteger index) {
  NSArray *line = [string componentsSeparatedByString:@" "];
  if([line count] <= index) {
     @throw [NSException
            exceptionWithName:@"Line index out of bounds"
                       reason:[NSString stringWithFormat:
					  @"Could not find token at position %lu in line \"%@\"",
					index,
					line]
                     userInfo:nil];
  } else {
    return [line objectAtIndex:index];
  }
}

NSString *popFirstChar(NSString *string) {
  return [string substringFromIndex:1];
}

void passOne(NSArray *program, NSMapTable *labels, NSMapTable *variables) {
  NSEnumerator *programEnumerator = [program objectEnumerator];
  id lineId;
  NSUInteger counter = 0;
  while (lineId = [programEnumerator nextObject]) {
    if (isLabelLine(lineId)) {
      NSString *labelColon = tokenAt(lineId, 0);
      NSString *label = popFirstChar(labelColon);
      if (findInEnumerator([labels keyEnumerator], label)) {
        @throw [NSException
            exceptionWithName:@"Label Collision"
                       reason:[NSString stringWithFormat:
                                            @"Found label \"%@\" more than "
                                            @"once. Lines %lu and %@.",
                                            label,
                                            [[labels objectForKey:label]
                                                integerValue],
                                            @(counter)]
                     userInfo:nil];
      } else {
	if (isVariableLine(lineId)) {
	  NSString *secondToken = tokenAt(lineId, 1);
	  NSString *number = popFirstChar(secondToken);
	  [variables setObject:@((NSUInteger)[number integerValue]) forKey:label];	
	} else {
	  [labels setObject:@(counter) forKey:label];
	}
      }
    }
    counter++;
  }
}

NSArray *popFirstToken(NSArray *stream) {
  return [stream objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [stream count] - 1)]];
}

NSMutableArray *passTwo(NSArray *program, NSMapTable *labels, NSMapTable *variables, NSMapTable *keywords) {
  NSMutableArray *bytecodes = [[NSMutableArray alloc] init];
  NSEnumerator *programEnumerator = [program objectEnumerator];
  id lineId;
  NSUInteger counter = 0;
  while (lineId = [programEnumerator nextObject]) {
    if (!isLineEmpty(lineId)){
      if (isLabelLine(lineId)) {
      	if (!isVariableLine(lineId)) {
	  NSArray *line = [lineId componentsSeparatedByString:@" "];
	  NSArray *instructions = popFirstToken(line);
	  uint32_t word = packFullWord(instructions, keywords);
	  [bytecodes addObject:@(word)];
	}    
      } else {
	if (isNumberLine(lineId)) {
	  NSString *number = popFirstChar(lineId);
	  [bytecodes addObject:@((uint32_t)[number integerValue])];
	} else if (isAddressLine(lineId)) {
	  NSString *label = popFirstChar(lineId);
	  if (findInEnumerator([labels keyEnumerator], label)) {
	    id valueOfLabel = [labels objectForKey:label];
	    [bytecodes addObject:@((uint32_t)[valueOfLabel integerValue])];
	  } else {
	    @throw [NSException
		     exceptionWithName:@"Address Label Not Found"
				reason:[NSString stringWithFormat:
						   @"Could not find address label \"%@\" in current scope at line %@",
						 label,
						 @(counter)]
			      userInfo:nil];
	  }
	} else if (isDerefLine(lineId)) {
	  NSString *label = popFirstChar(lineId);
	  if (findInEnumerator([variables keyEnumerator], label)) {
	    id valueOfLabel = [variables objectForKey:label];
	    [bytecodes addObject:@((uint32_t)[valueOfLabel integerValue])];
	  } else {
	    @throw [NSException
		     exceptionWithName:@"Variable Label Not Found"
				reason:[NSString stringWithFormat:
						   @"Could not find variable label \"%@\" in current scope at line %@",
						 label,
						 @(counter)]
			      userInfo:nil];
	  }
	} else {
	  NSLog(@"This is a print 4");
	  @throw [NSException
		   exceptionWithName:@"Invalid line encountered"
			      reason:[NSString stringWithFormat:
						    @"\nLine %@:\n \"%@\" is invalid",
					       @(counter),
					       lineId]
			    userInfo:nil];
	}
      }
    }
    
    counter++;
  }
  return bytecodes;
}
