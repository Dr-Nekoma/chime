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

/* - (void)instructionOpFetch; */

/* - (void)instructionOpLoadA; */

/* - (void)instructionOpStoreA; */

/* - (void)instructionOpAnd; */

/* - (void)instructionOpOr; */

/* - (void)instructionOpNot; */

/* - (void)instructionOpXor; */

/* - (void)instructionOpPlus; */

/* - (void)instructionOpDouble; */

/* - (void)instructionOpHalf; */

/* - (void)instructionOpPlusStar; */

/* - (void)instructionOpLoadAPlus; */

/* - (void)instructionOpStoreAPlus; */

/* - (void)instructionOpLoadRPlus; */

/* - (void)instructionOpStoreRPlus; */

@end

#endif /* VM_h */
