//
//  main.m
//  Chime
//
//  Created by Marcos Magueta on 15/11/23.
//

#import "Headers/VM+Instructions.h"
#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
  if (argc < 3) {
    NSLog(@"Program and/or Keyword set is missing");
    return 1;
  }
  @autoreleasepool {
    VM *vm = [VM new];
    [vm Execute:@(argv[1]) usingKeywords:@(argv[2])];
  }
  return 0;
}
