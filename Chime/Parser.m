#import "Headers/Parser.h"
#import "Headers/Utilities.h"
#import <Foundation/Foundation.h>

id parse(char *filepath) {
  NSData *data = [[NSData alloc] initWithContentsOfFile:@(filepath)];

  if (data == nil) {
    NSLog(@"Could not read file \"%s\"", filepath);
    return nil;
  }

  NSString *stringProgram =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

  NSArray *program = [stringProgram componentsSeparatedByString:@"\n"];
  NSMapTable *labels = passOne(program);
  return passTwo(labels, program);
}

BOOL isLineStartingWith(NSString *line, NSString *target) {
  return [line hasPrefix:target];
}

BOOL isNumberLine(NSString *line) { return isLineStartingWith(line, @"#"); }

BOOL isLabelLine(NSString *line) { return isLineStartingWith(line, @":"); }

NSMapTable *passOne(NSArray *program) {
  NSMapTable *labels = [[NSMapTable alloc] init];
  NSEnumerator *programEnumerator = [program objectEnumerator];
  id lineId;
  NSUInteger counter = 0;
  while (lineId = [programEnumerator nextObject]) {
    if (isLabelLine(lineId)) {
      NSArray *line = [lineId componentsSeparatedByString:@" "];
      NSString *labelColon = [line objectAtIndex:0];
      NSString *label = [labelColon substringFromIndex:1];
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
        [labels setObject:@(counter) forKey:label];
      }
    }
    counter++;
  }
  return labels;
}

NSMutableArray *passTwo(NSMapTable *labels, NSArray *program) {
  // Read line one by one. For each one that is a label line, ignore the label.
  // When parsing an & do a lookup on the map table with its label and swap it
  // with its position When parsing a # parse the line as an integer Change each
  // mnemonic with its corresponding opcode and pack it into 32 bits words Pray
  // you did everything right
  return NULL;
}
