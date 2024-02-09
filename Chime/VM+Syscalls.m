#import "Headers/Utilities.h"
#import "Headers/VM+Syscalls.h"
#import "Headers/VM.h"
#import <Foundation/Foundation.h>

#include <unistd.h>
#include <stdio.h>
#include <sys/sem.h>

@implementation VM (Syscalls)

- (void)syscallRead {
  @try {
    id readDeviceID = [self.dataStack pop];
    id readSize = [self.dataStack pop];    
    id readContent = [self.dataStack pop];
    char stringContent[10] = {0};
    ssize_t bytesWritten = read([readDeviceID integerValue], &stringContent, 10);
    // TODO: Add support for strings, the user should have access to the read content
    printf("Read content: %s\n", &stringContent);
    [self.dataStack push:@(bytesWritten)];
  } @catch (NSException *exception) {
    @throw exception;
  }
}


- (void)syscallWrite {
  @try {
    id writeDeviceID = [self.dataStack pop];
    id writeContent = [self.dataStack pop];
    id value = [self.memoryRAM objectAtIndex:[writeContent integerValue]];
    // TODO: Add support for strings, right now only numbers work
    const char *stringContent = [[value stringValue] UTF8String];
    ssize_t bytesWritten = write([writeDeviceID integerValue], stringContent, strlen(stringContent));
    [self.dataStack push:@(bytesWritten)];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)syscallSemGet {
  @try {
    // TODO: Figure out how to properly use keys for semaphores
    id key = [self.dataStack pop];
    id nSems = [self.dataStack pop];
    id semFlag = [self.dataStack pop];
    int semId = semget((key_t) [key integerValue], (int) [nSems integerValue], (int) [semFlag integerValue]);
    [self.dataStack push:@(semId)];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

// - (void)syscallSemCtl {
//   @try {
//     id writeDeviceID = [self.dataStack pop];
//     id writeContent = [self.dataStack pop];
//     id value = [self.memoryRAM objectAtIndex:[writeContent integerValue]];
//     // TODO: Add support for strings, right now only numbers work
//     const char *stringContent = [[value stringValue] UTF8String];
//     ssize_t bytesWritten = write([writeDeviceID integerValue], stringContent, strlen(stringContent));
//     [self.dataStack push:@(bytesWritten)];
//   } @catch (NSException *exception) {
//     @throw exception;
//   }
// }

- (void)instructionSyscall {
  @try {
    id syscallOpcode = [self.dataStack pop];
    if ([syscallOpcode isEqualTo:@(SYSCALL_WRITE)]) {
      NSLog(@"WRITE SYSCALL");
      [self syscallWrite];
    } else if ([syscallOpcode isEqualTo:@(SYSCALL_READ)]) {
      NSLog(@"READ SYSCALL");
      [self syscallRead];
    } else if ([syscallOpcode isEqualTo:@(SYSCALL_SEMGET)]) {
      NSLog(@"SEMGET SYSCALL");
      [self syscallSemGet];
    } else if ([syscallOpcode isEqualTo:@(SYSCALL_SEMOP)]) {
      NSLog(@"SEMOP SYSCALL is not yet implemented");
    }else if ([syscallOpcode isEqualTo:@(SYSCALL_SEMCTL)]) {
      NSLog(@"SEMCTL SYSCALL is not yet implemented");
      // [self syscallSemCtl];
    }else {
      NSLog(@"TODO: not yet implemented");      
    }
  } @catch (NSException *exception) {
    @throw exception;
  }
}

@end
