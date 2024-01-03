#ifndef VM_h
#define VM_h

#import "Stack.h"
#import <Foundation/Foundation.h>

@interface VM : NSObject

@property(retain) Stack *dataStack;
@property(retain) Stack *returnStack;
@property(retain) Stack *instructionStack;
@property(retain) NSMapTable *registers;
@property(retain) NSMutableArray *memoryRAM;

- (VM *)init;

- (void)clearCode;

- (void)printState;

- (void)Execute:(NSString *)program usingKeywords:(NSString *)keywords;

- (id)collectNextInstruction;

@end

#endif /* VM_h */
