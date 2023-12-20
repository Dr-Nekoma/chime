#import "VM.h"
#import <Foundation/Foundation.h>

@interface VM (Instructions)
- (void)instructionOpFetch;

- (void)instructionOpLoadA;

- (void)instructionOpStoreA;

- (void)instructionOpAnd;

- (void)instructionOpOr;

- (void)instructionOpNot;

- (void)instructionOpXor;

- (void)instructionOpPlus;

- (void)instructionOpDouble;

- (void)instructionOpHalf;

- (void)instructionOpPlusStar;

- (void)instructionOpLoadAPlus;

- (void)instructionOpStoreAPlus;

- (void)instructionOpLoadRPlus;

- (void)instructionOpStoreRPlus;

@end
