//
//  main.m
//  Chime
//
//  Created by Marcos Magueta on 15/11/23.
//

#import "Headers/Parser.h"
#import "Headers/VM+Instructions.h"
#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
  // @autoreleasepool {
  //   VM *vm = [VM new];
  //   [vm Execute:@""];
  // }
  parse("samples/sum.chf");
  return 0;
}
