#ifndef Stack_h
#define Stack_h

#import <Foundation/Foundation.h>
#import "Opcode.h"

@interface Stack : NSObject

@property NSUInteger size;
@property NSMutableArray* arr;

- (Stack*)init;
- (bool)isEmpty;
- (void)push:(id)elem;
- (id)pop;
- (id)peek;

@end

#endif /* Stack_h */
