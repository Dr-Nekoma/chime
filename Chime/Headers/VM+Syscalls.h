#import "VM.h"
#import <Foundation/Foundation.h>

#include <stdint.h>

typedef enum : uint64_t {
  SYSCALL_READ = 0,
  SYSCALL_WRITE = 1,
  SYSCALL_OPEN = 2,
  SYSCALL_SEMGET = 64,
  SYSCALL_SEMOP = 65,        
  SYSCALL_SEMCTL = 66,
} SYSCALL_OPCODE;

typedef enum : uint64_t {
  STDIN_FILENO = 0,  // File number of stdin;
  STDOUT_FILENO = 1, // File number of stdout;
  STDERR_FILENO = 2, // File number of stderr;
} WRITE_DEVICE_OPCODE;

@interface VM (Syscalls)

- (void)instructionSyscall;

@end
