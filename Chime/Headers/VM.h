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

- (void)LoadProgram:(NSString *)program usingKeywords:(NSString *)keywordSet;

- (void)SaveProgram:(NSString *)filepath;

- (void)LoadBytecode:(NSString *)bytecode;

- (void)Evaluate;

@end

#endif /* VM_h */
