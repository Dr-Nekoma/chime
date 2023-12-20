#ifndef VM_h
#define VM_h

#import "Stack.h"
#import <Foundation/Foundation.h>

@interface VM : NSObject

@property Stack *dataStack;
@property Stack *returnStack;
@property Stack *instructionStack;
@property NSMapTable *registers;
@property NSMutableArray *memoryRAM;

- (VM *)init;

- (void)clearCode;

- (void)printState;

- (void)Execute:(NSString *)program;

- (id)collectNextInstruction;

@end

#endif /* VM_h */
