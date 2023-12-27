#ifndef Parser_h
#define Parser_h

#import <Foundation/Foundation.h>
#include <stdint.h>

id parse(char *filepath);

BOOL isLineStartingWith(NSString *line, NSString *target);

BOOL isNumberLine(NSString *line);

BOOL isLabelLine(NSString *line);

NSMapTable *passOne(NSArray *program);

NSMutableArray *passTwo(NSMapTable *labels, NSArray *program);

#endif // Parser_h
