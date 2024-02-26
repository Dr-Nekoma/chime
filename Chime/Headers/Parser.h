#ifndef Parser_h
#define Parser_h

#import <Foundation/Foundation.h>
#include <stdint.h>

#define IS_LABEL YES
#define IS_NOT_LABEL NO
#define MAX_STRING_SIZE 2147483647
#define WORD_SIZE 4

@interface Parser : NSObject

@property(retain) NSArray *program;
@property(retain) NSMapTable *labels;
@property(retain) NSMapTable *variables;
@property(retain) NSMapTable *keywords;
@property NSUInteger physicalLinesCounter;

- (Parser *)init;

- (NSMutableArray *)Parse:(char *)filePath usingKeywords:(char *)keywordsPath;

- (void)printState;

@end

#endif // Parser_h
