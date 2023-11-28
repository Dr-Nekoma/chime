//
//  main.m
//  Chime
//
//  Created by Marcos Magueta on 15/11/23.
//

#import <Foundation/Foundation.h>
#import "VM.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
      VM* vm = [VM new];
      [vm Execute:@""];
    }
    return 0;
}
