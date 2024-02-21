//
//  main.m
//  Chime
//
//  Created by Marcos Magueta on 15/11/23.
//

#import "Headers/Utilities.h"
#import "Headers/VM+Instructions.h"
#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    VM *vm = [VM new];
    NSMapTable *cmds = parseCommandLine(argc, argv);

    NSMutableString *candidateProgram = [[NSMutableString alloc] init];
    NSMutableString *candidateDialect = [[NSMutableString alloc] init];
    handleProgramAndDialect(cmds, candidateProgram, candidateDialect);

    NSString *candidateLoad = [cmds objectForKey:@"LoadFilePath"];

    if (candidateLoad != nil) {
      [vm LoadBytecode:candidateLoad];
    } else {
      [vm LoadProgram:[NSString stringWithString:candidateProgram]
          usingKeywords:[NSString stringWithString:candidateDialect]];
    }

    NSString *candidateSave = [cmds objectForKey:@"SaveFilePath"];
    if (candidateSave != nil) {
      [vm SaveProgram:candidateSave];
    }

    [vm Evaluate];
  }
  return 0;
}
