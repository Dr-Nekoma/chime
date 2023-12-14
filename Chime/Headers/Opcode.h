#ifndef Opcode_h
#define Opcode_h

#include <stdint.h>

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
  OP_DROP,
  // Memory Access
  OP_LOAD_A,
  OP_STORE_A,
  OP_LOAD_A_PLUS,
  OP_STORE_A_PLUS,
  OP_LOAD_R_PLUS,
  OP_STORE_R_PLUS,
  OP_FETCH,
  // Arithmetic
  OP_AND,
  OP_NOT,
  OP_OR,
  OP_XOR,
  OP_PLUS,
  OP_DOUBLE,
  OP_HALF,
  OP_PLUS_STAR,
  // Other
  OP_NOP
} OPCODE;

#endif /* Opcode_h */
