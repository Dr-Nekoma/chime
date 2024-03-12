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
    id contentPointer = [self.dataStack pop];
    NSUInteger pointer = [contentPointer integerValue];
    NSUInteger length = [[self.memoryRAM objectAtIndex:pointer] integerValue];
    pointer++;
    
    Word_Manager wm = howManyWords(length);
    char stringContent[length];
    ssize_t bytesWritten = read([readDeviceID integerValue], stringContent, length);
    NSUInteger upperLimit = wm.howManyWords;
    NSArray *treatedInput = padWords(packString(@(stringContent)), upperLimit);

    [self.memoryRAM replaceObjectsInRange:(NSMakeRange (pointer, upperLimit))
		     withObjectsFromArray:treatedInput];
    [self.dataStack push:@(bytesWritten)];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)syscallWrite {
  @try {
    id writeDeviceID = [self.dataStack pop];
    id contentPointer = [self.dataStack pop];
    
    NSString *content = unpackString(contentPointer, self.memoryRAM);
    const char *stringContent = [content UTF8String];
    
    ssize_t bytesWritten = write([writeDeviceID integerValue], stringContent, strlen(stringContent));
    [self.dataStack push:@(bytesWritten)];
  } @catch (NSException *exception) {
    @throw exception;
  }
}

- (void)instructionSyscall {
  @try {
    id syscallOpcode = [self.dataStack pop];
    if ([syscallOpcode isEqualTo:@(SYSCALL_WRITE)]) {
      NSLog(@"WRITE SYSCALL");
      [self syscallWrite];
    } else if ([syscallOpcode isEqualTo:@(SYSCALL_READ)]) {
      NSLog(@"READ SYSCALL");
      [self syscallRead];
    } else {
      @throw [NSException
	       exceptionWithName:@"Unrecognized syscall opcode"
			  reason:[NSString stringWithFormat:
					     @"Could not find syscall with opcode %lu", [syscallOpcode integerValue]]
			userInfo:nil];
    }
  } @catch (NSException *exception) {
    @throw exception;
  }
}

@end
