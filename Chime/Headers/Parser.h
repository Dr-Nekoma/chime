#ifndef Parser_h
#define Parser_h

#import <Foundation/Foundation.h>
#include <stdint.h>

@interface Parser : NSObject

@property(retain) NSArray *program;
@property(retain) NSMapTable *labels;
@property(retain) NSMapTable *variables;
@property(retain) NSMapTable *keywords;
@property NSUInteger physicalLinesCounter;

- (Parser *)init;

- (NSMutableArray *)ParseProgram:(char *)filePath
                   usingKeywords:(char *)keywordsPath;

- (NSMutableArray *)ParseBytecode:(char *)filePath;

- (void)printState;

@end

#endif // Parser_h
