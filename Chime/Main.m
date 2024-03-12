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
    [candidateProgram setString:[cmds objectForKey:@"ProgramFilePath"]];
    [candidateDialect setString:[cmds objectForKey:@"DialectFilePath"]];

    NSString *candidateLoad = [cmds objectForKey:@"LoadFilePath"];

    if (candidateLoad != nil) {
      [vm LoadBytecode:candidateLoad];
    } else {
      if ([candidateProgram length] == 0) {
        errorMissingProgramFilePath();
      }

      if ([candidateDialect length] == 0) {
        errorMissingDialectFilePath();
      }

      [vm LoadProgram:[NSString stringWithString:candidateProgram]
          usingKeywords:[NSString stringWithString:candidateDialect]];
    }

    NSString *candidateSave = [cmds objectForKey:@"SaveFilePath"];
    if (candidateSave != nil) {
      [vm SaveProgram:candidateSave];
    } else {
      [vm Evaluate];
    }
  }
  return 0;
}
