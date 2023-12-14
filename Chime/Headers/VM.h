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

- (void)Execute:(NSString *)program;

@end

#endif /* VM_h */
