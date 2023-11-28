//
//  Opcode.h
//  Chime
//
//  Created by Marcos Magueta on 18/11/23.
//

#ifndef Opcode_h
#define Opcode_h

typedef enum : NSUInteger {
    OP_HALT,
    OP_PUSH_A,
    OP_POP_A,
    OP_PUSH_R,
    OP_POP_R,
    OP_OVER,
    OP_DUP,
    OP_DROP
} OPCODE;


#endif /* Opcode_h */
