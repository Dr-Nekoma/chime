#include "Opcode.h"
#import "Stack.h"
#import <Foundation/Foundation.h>

void instruction_op_fetch(NSMapTable* _registers, Stack *_dataStack, NSMutableArray *_ram);
void instruction_op_load_a(NSMapTable* _registers, Stack *_dataStack, NSMutableArray *_ram);
void instruction_op_store_a(NSMapTable* _registers, Stack *_dataStack, NSMutableArray *_ram);
void instruction_op_and(Stack *_dataStack);
void instruction_op_or(Stack *_dataStack);
void instruction_op_not(Stack *_dataStack);
void instruction_op_xor(Stack *_dataStack);
void instruction_op_plus(Stack *_dataStack);
void instruction_op_double(Stack *_dataStack);
void instruction_op_half(Stack *_dataStack);
void instruction_op_plus_star(Stack *_dataStack);
