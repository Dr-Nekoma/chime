#ifndef Parser_h
#define Parser_h

#import <Foundation/Foundation.h>
#include <stdint.h>

NSMapTable *loadKeywords(char *filePath);

NSMutableArray *parse(char *filePath, char *keywordsPath);

NSString *tokenAt(NSString *string, NSInteger index);

BOOL isStringStartingWith(NSString *line, NSString *target);

static inline BOOL isLineEmpty(id line);

BOOL isNumberLine(NSString *line);

BOOL isAddressLine(NSString *line);

BOOL isDerefLine(NSString *line);

BOOL isLabelLine(NSString *line);

BOOL isVariableLine(NSString *line);

NSString *popFirstChar(NSString *string);

void passOne(NSArray *program, NSMapTable *labels, NSMapTable *variables);

NSMutableArray *passTwo(NSArray *program, NSMapTable *labels,
                        NSMapTable *variables, NSMapTable *keywords);

#endif // Parser_h
