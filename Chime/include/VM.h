//
//  VM.h
//  Chime
//
//  Created by Marcos Magueta on 17/11/23.
//

#ifndef VM_h
#define VM_h

#import <Foundation/Foundation.h>
#import "Stack.h"

@interface VM : NSObject

@property Stack* dataStack;
@property Stack* returnStack;
@property NSMapTable* registers;

- (VM*)init;

- (void)clearCode;

- (void)Execute:(NSString*) program;

@end

#endif /* VM_h */
