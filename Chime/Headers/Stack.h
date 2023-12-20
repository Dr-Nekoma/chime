#ifndef Stack_h
#define Stack_h

#import "Opcode.h"
#import <Foundation/Foundation.h>

@interface Stack : NSObject

@property(assign) NSUInteger size;
@property(retain) NSMutableArray *arr;

- (Stack *)init;
- (bool)isEmpty;
- (void)push:(id)elem;
- (id)pop;
- (id)peek;
- (void)printStack;

@end

#endif /* Stack_h */
