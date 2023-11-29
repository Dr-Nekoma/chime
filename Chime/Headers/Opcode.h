#ifndef Opcode_h
#define Opcode_h

typedef enum : uint64_t {
    // Flow Control
    OP_PC_FETCH = 0,
    OP_JUMP,
    OP_JUMP_ZERO,
    OP_JUMP_PLUS,
    OP_CALL,
    OP_RET,
    // Stack Manipulations
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
