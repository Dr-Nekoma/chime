#import "VM.h"
#import <Foundation/Foundation.h>

@interface VM (Instructions)

- (void)instructionOpPushA;

- (void)instructionOpPopA;

- (void)instructionOpPushR;

- (void)instructionOpPopR;

- (void)instructionOpDup;

- (void)instructionOpDrop;

- (void)instructionOpOver;

- (void)instructionOpPcFetch;

- (void)instructionOpJump;

- (void)instructionOpJumpZero;

- (void)instructionOpJumpPlus;

- (void)instructionOpCall;

- (void)instructionOpRet;

- (void)instructionOpLiteral;

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

- (void)instructionOpSwap;

@end
