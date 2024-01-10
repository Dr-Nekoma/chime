#ifndef Opcode_h
#define Opcode_h

#include <stdint.h>

typedef enum : uint64_t {
  // Flow Control
  OP_PC_FETCH = 0,
  OP_JUMP = 1,
  OP_JUMP_ZERO = 2,
  OP_JUMP_PLUS = 3,
  OP_CALL = 4,
  OP_RET = 5,
  OP_HALT = 6,
  // Stack Manipulations
  OP_PUSH_A = 7,
  OP_POP_A = 8,
  OP_PUSH_R = 9,
  OP_POP_R = 10,
  OP_OVER = 11,
  OP_DUP = 12,
  OP_DROP = 13,
  // Memory Access
  OP_LOAD_A = 14,
  OP_STORE_A = 15,
  OP_LOAD_A_PLUS = 16,
  OP_STORE_A_PLUS = 17,
  OP_LOAD_R_PLUS = 18,
  OP_STORE_R_PLUS = 19,
  OP_LITERAL = 20,
  // Arithmetic
  OP_AND = 21,
  OP_NOT = 22,
  OP_OR = 23,
  OP_XOR = 24,
  OP_PLUS = 25,
  OP_DOUBLE = 26,
  OP_HALF = 27,
  OP_PLUS_STAR = 28,
  // Other
  OP_NOP = 29,
  OP_TOTAL = 30
} OPCODE;

#endif /* Opcode_h */
