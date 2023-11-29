//
//  Opcode.h
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#ifndef Opcode_h
#define Opcode_h

typedef enum : NSUInteger {
    // Stack Manipulations
    OP_HALT,
    OP_PUSH_A,
    OP_POP_A,
    OP_PUSH_R,
    OP_POP_R,
    OP_OVER,
    OP_DUP,
    OP_DROP,
    // Flow Control
    OP_PC_FETCH,
    OP_JUMP,
    OP_JUMP_ZERO,
    OP_JUMP_PLUS,
    OP_CALL,
    OP_RET
} OPCODE;



#endif /* Opcode_h */
