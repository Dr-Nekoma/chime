//
//  Stack.h
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#ifndef Stack_h
#define Stack_h

#import <Foundation/Foundation.h>
#import "Opcode.h"

@interface Stack : NSObject

@property NSUInteger size;
@property NSMutableArray* arr;

- (Stack*)init;
- (bool)isEmpty;
- (void)push:(OPCODE)opcode;
- (id)pop;
- (id)peek;

@end

#endif /* Stack_h */
